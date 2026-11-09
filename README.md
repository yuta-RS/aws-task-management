# \# AWS Task Management API

# 

# AWS上に構築した、タスク管理用のREST APIです。

# 

# Python / FastAPIで開発したアプリケーションをDockerでコンテナ化し、Amazon ECS Fargateで実行しています。

# 

# インフラはTerraformで管理し、GitHub ActionsとAWS IAM OIDC認証を利用したCI/CDパイプラインを構築しました。

# 

# \## 主な実装内容

# 

# \- FastAPIによるタスク管理REST API

# \- PostgreSQLへのデータ永続化

# \- Dockerによるコンテナ化

# \- Amazon ECS Fargateでのアプリケーション実行

# \- Application Load Balancerによるリクエスト振り分け

# \- TerraformによるAWSインフラ管理

# \- GitHub ActionsによるDockerイメージのビルド・ECRへのプッシュ・ECSへのデプロイ

# \- IAM OIDC認証によるGitHub ActionsとAWSの連携

# \- CloudWatch Logsへのコンテナログ出力

# 

# \## 使用技術

# 

# | 分類 | 技術 |

# |---|---|

# | 言語 | Python |

# | Webフレームワーク | FastAPI |

# | データベース | PostgreSQL |

# | コンテナ | Docker |

# | コンテナ実行基盤 | Amazon ECS Fargate |

# | コンテナレジストリ | Amazon ECR |

# | ロードバランサー | Application Load Balancer |

# | インフラ管理 | Terraform |

# | CI/CD | GitHub Actions |

# | 認証・権限管理 | AWS IAM / OIDC |

# | シークレット管理 | AWS Systems Manager Parameter Store |

# | ログ管理 | Amazon CloudWatch Logs |

# 

# \## システム構成図

# 

# ```mermaid

# flowchart TB

# &#x20;   User\["API利用者"] --> ALB\["Application Load Balancer"]

# 

# &#x20;   subgraph AWS\["AWS / VPC"]

# &#x20;       subgraph Public\["Public Subnets（2AZ）"]

# &#x20;           ALB

# &#x20;       end

# 

# &#x20;       subgraph PrivateApp\["Application Private Subnets（2AZ）"]

# &#x20;           ECS\["Amazon ECS Fargate / FastAPI"]

# &#x20;       end

# 

# &#x20;       subgraph PrivateDB\["Database Private Subnets（2AZ）"]

# &#x20;           RDS\["Amazon RDS / PostgreSQL"]

# &#x20;       end

# 

# &#x20;       ALB --> ECS

# &#x20;       ECS --> RDS

# 

# &#x20;       SSM\["SSM Parameter Store"] -. "DB認証情報" .-> ECS

# &#x20;       ECS --> CW\["CloudWatch Logs"]

# &#x20;       ECS -. "VPC Endpoints" .-> ECR\["Amazon ECR"]

# &#x20;   end

# 

# &#x20;   GitHub\["GitHub / GitHub Actions"] --> OIDC\["AWS IAM OIDC"]

# &#x20;   OIDC --> ECR

# &#x20;   ECR -. "コンテナイメージ" .-> ECS

# ```

# 

# ※ RDSはシングルAZ構成です。DB用サブネットは2AZに配置していますが、Multi-AZ DBインスタンスではありません。

# 

# \## ネットワーク設計

# 

# VPC内にPublic Subnet、Application Private Subnet、Database Private Subnetをそれぞれ2AZ分用意しています。

# 

# | 用途 | AZ | CIDR |

# |---|---|---|

# | Public Subnet 1 | ap-northeast-1a | 10.0.1.0/24 |

# | Public Subnet 2 | ap-northeast-1c | 10.0.2.0/24 |

# | Application Private Subnet 1 | ap-northeast-1a | 10.0.11.0/24 |

# | Application Private Subnet 2 | ap-northeast-1c | 10.0.12.0/24 |

# | Database Private Subnet 1 | ap-northeast-1a | 10.0.21.0/24 |

# | Database Private Subnet 2 | ap-northeast-1c | 10.0.22.0/24 |

# 

# アプリケーションはPrivate Subnetで実行し、ALB経由でアクセスする構成です。

# 

# NAT Gatewayを使用せず、ECR・CloudWatch Logs・SSMへのアクセスにはVPCエンドポイントを利用しています。S3へのアクセスにはGateway型VPCエンドポイントを使用しています。

# 

# \## セキュリティ設計

# 

# \### ネットワーク分離

# 

# \- ALBをPublic Subnetに配置

# \- ECS FargateをApplication Private Subnetに配置

# \- RDS PostgreSQLをDatabase Private Subnetに配置

# \- RDSのパブリックアクセスを無効化

# \- Security Groupで必要な通信のみ許可

# 

# \### IAMと認証情報管理

# 

# \- ECSタスク実行ロールに必要なAWS権限を付与

# \- DBパスワードをSSM Parameter Storeから取得

# \- GitHub ActionsからAWSへの認証にOIDCを利用

# \- GitHub Actions用IAMロールにECR・ECSデプロイに必要な権限を設定

# \- AWSアクセスキーをGitHub Actionsに保存しない構成

# 

# \## CI/CD

# 

# GitHub Actionsを使用して、mainブランチへのpushまたは手動実行を契機にデプロイ処理を実行します。

# 

# ```mermaid

# flowchart LR

# &#x20;   A\["GitHub main"] --> B\["GitHub Actions"]

# &#x20;   B --> C\["OIDC認証"]

# &#x20;   C --> D\["Docker Build"]

# &#x20;   D --> E\["Amazon ECR"]

# &#x20;   E --> F\["ECSタスク定義更新"]

# &#x20;   F --> G\["ECSサービス更新"]

# ```

# 

# \### デプロイ処理

# 

# 1\. GitHubリポジトリからソースコードを取得

# 2\. OIDCを利用してAWS IAMロールを引き受け

# 3\. Dockerイメージをビルド

# 4\. GitのコミットSHAをタグとしてECRにプッシュ

# 5\. ECSタスク定義に新しいイメージを設定

# 6\. ECSサービスを更新

# 

# TerraformとGitHub Actionsが同じECSタスク定義の更新を競合しないよう、Terraform側ではECSサービスの `task\_definition` の変更を無視する設定を使用しています。

# 

# \## API一覧

# 

# | HTTPメソッド | エンドポイント | 機能 |

# |---|---|---|

# | GET | `/` | ルートエンドポイント |

# | GET | `/health` | ヘルスチェック |

# | GET | `/tasks` | タスク一覧取得 |

# | POST | `/tasks` | タスク作成 |

# | PATCH | `/tasks/{task\_id}` | タスク更新 |

# | DELETE | `/tasks/{task\_id}` | タスク削除 |

# 

# タスクにはID、タイトル、完了状態、作成日時を保持します。

# 

# \### 動作確認結果

# 

# 2026年11月9日、GitHub ActionsでデプロイしたECSタスク定義リビジョン2について、ALB経由で以下の動作を確認しました。

# 

# | 操作 | 結果 |

# |---|---|

# | GET `/health` | HTTP 200 |

# | GET `/tasks` | HTTP 200 |

# | POST `/tasks` | HTTP 200 |

# | PATCH `/tasks/6` | HTTP 200 |

# | DELETE `/tasks/6` | HTTP 200 |

# 

# POST・PATCH・DELETEによるPostgreSQLへの書き込み・更新・削除も確認済みです。

# 

# \## 監視・運用

# 

# \- ECSコンテナのログをCloudWatch Logsに出力

# \- ALBのターゲットヘルスチェックを利用

# \- ECSサービスのタスク数・稼働状態をAWS CLIで確認

# \- Terraformの `plan` と `validate` によってインフラ設定を検証

# 

# \### コスト管理

# 

# 検証環境のため、動作確認後はECSサービスのDesired Countを0に変更し、RDSを停止しています。

# 

# ALBやVPCエンドポイントなどは停止中も料金が発生するため、継続的なコスト確認が必要です。また、RDSは停止から最大7日後に自動起動します。

# 

# \## Terraform

# 

# AWSインフラの構成コードは \[`terraform/`](./terraform/) に格納しています。

# 

# 主な管理対象：

# 

# \- VPC・Subnet・Route Table

# \- Security Group

# \- Application Load Balancer

# \- Amazon ECS・ECR

# \- Amazon RDS

# \- IAMロール・ポリシー

# \- GitHub OIDC Provider

# \- VPC Endpoints

# 

# Terraformのstateファイルや認証情報はGitHubの管理対象から除外しています。

# 

# \## 開発経緯

# 

# 初期段階ではEC2上でFastAPIを実行する構成を構築しました。

# 

# その後、コンテナ運用とCI/CDを学習するため、Docker・ECR・ECS Fargateを利用する構成へ移行しました。

# 

# EC2関連のTerraformコードは初期構成の記録として残しています。現在のメイン実行環境はECS Fargateです。

# 

# \## 今後の改善点

# 

# \- 自動テストのCI/CDへの組み込み

# \- HTTPS対応と独自ドメイン設定

# \- Terraformのリモートstate管理

# \- CloudWatchアラームの追加

# \- ECSのオートスケーリング

# \- シークレット管理・運用手順の改善

# 

