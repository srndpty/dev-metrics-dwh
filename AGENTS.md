# AGENTS.md

このリポジトリで作業する AI エージェント／コントリビューター向けのガイドラインです。

## 言語ポリシー

- **チャットの返答、コードのコメント、コミットメッセージ、レビューコメントなど、コード本体以外で人間が読むことを想定している文章は原則として日本語にすること。**
- 変数名・関数名・テーブル名・カラム名などの識別子は、慣習に従い英語のままにする。
- ログ出力やエラーメッセージなど、ツールやライブラリの仕様で英語が自然なものは無理に翻訳しない。

## プロジェクト概要

ローカルの開発メトリクス（コミット数・テスト結果・カバレッジ・ビルドサイズなど）を
DuckDB に取り込み、dbt で変換してプロジェクト健全性のマートを作る個人用の
アナリティクスエンジニアリングプロジェクトです。詳細は [README.md](README.md) を参照。

技術スタック:

- **Python**: 3.12（`.python-version` / `pyproject.toml` で固定）
- **パッケージ管理**: [uv](https://docs.astral.sh/uv/)
- **変換**: dbt 1.11 系（`dbt-core` / `dbt-duckdb`）
- **ストレージ**: DuckDB（`data/warehouse/dev_metrics.duckdb`）
- **タスクランナー**: [just](https://github.com/casey/just)（`justfile`）

## ディレクトリ構成

```
data/raw/         元データ（CSV など）。LF 改行で管理する
data/warehouse/   DuckDB のファイル（生成物。Git 管理外）
models/staging/   ソースを整形する staging モデル（view）
models/marts/     分析用のマートモデル（table）
models/sources.yml ソース定義
profiles.yml      dbt の接続プロファイル（リポジトリ内に同梱）
dbt_project.yml   dbt プロジェクト設定
justfile          よく使うコマンド
```

## よく使うコマンド

`just` 経由で実行する（中身は `uv run dbt ... --profiles-dir .`）:

```bash
just debug   # 接続・設定チェック
just run     # モデルの実行
just build   # run + test をまとめて実行
just test    # テストのみ
just clean   # target/ などの掃除
just duck    # DuckDB のテーブル一覧を表示
```

`just` を使わない場合は `--profiles-dir .` を必ず付けること
（プロファイルをリポジトリ内に置いているため）。例:

```bash
uv run dbt build --profiles-dir .
```

## 開発のお作法

### 環境

- 依存を変更したら `uv sync` で `.venv` と `uv.lock` を更新する。
- **Python 3.13/3.14 は使わない。** dbt-core 1.11 / mashumaro 3.14 が未対応で、
  import 時にクラッシュする（`UnserializableField` 等）。`requires-python` の上限は
  意図的に `<3.14` にしてある。

### データ

- `data/raw/` の CSV は **LF 改行で統一する**。改行が CRLF と混在すると
  DuckDB の CSV sniffer が方言を判定できず失敗する。`.gitattributes` で
  `data/raw/*.csv text eol=lf` を強制している。
- DuckDB ファイルや WAL（`data/warehouse/*.duckdb*`）はコミットしない（`.gitignore` 済み）。
- dbt が生成するマシンローカルな `.user.yml` はコミットしない（`.gitignore` 済み）。

### dbt モデル

- staging は view、marts は table をデフォルトとする（`dbt_project.yml` 参照）。
- ソースを直接参照せず、staging では `read_csv`／`source()`、下流では `ref()` を使う。
- 変更したら最低限 `just build` が通ることを確認してからコミットする。

### コミット

- 1 コミット 1 目的を心がけ、コミットメッセージは日本語で「何を・なぜ」を書く。
- メインブランチへ直接コミットせず、作業用ブランチを切って push する。
- 秘匿情報（認証情報・トークン等）はコミットしない。
