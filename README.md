# aws-task-management
AWS上に構築するタスク管理Webアプリケーション

## 概要

タスクの登録・編集・削除・完了管理を行うWebアプリケーションです。

## 使用技術

- Python
- FastAPI
- PostgreSQL
- AWS
- Terraform

## AWS構成

後日記載

## システム構成図

後日掲載

## セキュリティ設計

後日記載

## 監視

後日記載

## CI/CD

後日記載

## アプリ機能

このアプリでは、以下の機能を実装します。

- タスクの登録
- タスク一覧表示
- タスクの編集
- タスクの削除
- タスクの完了管理

各タスクは以下の情報を持ちます。

- タイトル
- 期限
- 完了状態

## AWS構成

以下の構成を予定しています。

- VPC
- Public Subnet
- Private Subnet
- Application Load Balancer
- EC2
- RDS for PostgreSQL
- IAM
- CloudWatch

通信経路は以下を想定しています。

Internet → ALB → EC2 → RDS
