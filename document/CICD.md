# 1. 概要

このドキュメントでは、ECS APIのCI/CDパイプラインの構成と設定について説明します。

# 2. パイプライン構成

パイプラインは以下の4つのステージで構成されています：

1. Source: GitHubリポジトリからのソースコード取得
2. Build: アプリケーションのビルドとDockerイメージの作成
3. Migration: データベースマイグレーションの実行
4. Deploy: ECSへのデプロイ

# 3. スペックファイルの構成

## 3.1 ビルドスペックファイル

- パス: `server/buildspec.yml`
- 用途: アプリケーションのビルドとDockerイメージの作成
- 参照先: `codepipeline.tf`の`aws_codebuild_project.build`リソース

## 3.2 マイグレーションスペックファイル

- パス: `server/migration-buildspec.yml`
- 用途: データベースマイグレーションの実行
- 参照先: `codepipeline.tf`の`aws_codebuild_project.migration`リソース

# 4. 注意事項

- スペックファイルのパスは`server/`ディレクトリ配下に配置する必要があります
- パイプラインの設定ファイル（`codepipeline.tf`）で指定するパスと、実際のファイルの配置場所が一致していることを確認してください
- パスの不一致がある場合、CodeBuildの実行時に`YAML_FILE_ERROR`が発生する可能性があります