import os

import psycopg2
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI()


class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)


class TaskUpdate(BaseModel):
    completed: bool


def get_db_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ["DB_PORT"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
    )


@app.get("/")
def read_root():
    return {"message": "Hello from AWS Task Management API"}


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/tasks")
def get_tasks():
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT id, title, completed, created_at
        FROM tasks
        ORDER BY id;
    """)

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return [
        {
            "id": row[0],
            "title": row[1],
            "completed": row[2],
            "created_at": row[3]
        }
        for row in rows
    ]


@app.post("/tasks")
def create_task(task: TaskCreate):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO tasks (title)
        VALUES (%s)
        RETURNING id, title, completed, created_at;
        """,
        (task.title,)
    )

    row = cur.fetchone()
    conn.commit()

    cur.close()
    conn.close()

    return {
        "id": row[0],
        "title": row[1],
        "completed": row[2],
        "created_at": row[3]
    }


@app.patch("/tasks/{task_id}")
def update_task(task_id: int, task: TaskUpdate):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute(
        """
        UPDATE tasks
        SET completed = %s
        WHERE id = %s
        RETURNING id, title, completed, created_at;
        """,
        (task.completed, task_id)
    )

    row = cur.fetchone()

    if row is None:
        cur.close()
        conn.close()
        raise HTTPException(status_code=404, detail="Task not found")

    conn.commit()
    cur.close()
    conn.close()

    return {
        "id": row[0],
        "title": row[1],
        "completed": row[2],
        "created_at": row[3]
    }


@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute(
        """
        DELETE FROM tasks
        WHERE id = %s
        RETURNING id;
        """,
        (task_id,)
    )

    row = cur.fetchone()

    if row is None:
        cur.close()
        conn.close()
        raise HTTPException(status_code=404, detail="Task not found")

    conn.commit()
    cur.close()
    conn.close()

    return {
        "message": "Task deleted",
        "id": row[0]
    }