# Contributing

## 目的

このリポジトリは、1 つの Codex skill、1 つの release context 収集スクリプト、少数の参照資料で構成されています。変更は release notes の品質、公開の確実性、リポジトリの分かりやすさを高める方向に絞ってください。

## リポジトリ構成

| パス | 役割 |
| --- | --- |
| `SKILL.md` | Codex が直接読む中核 skill 定義 |
| `agents/openai.yaml` | skill 一覧向けメタデータ |
| `scripts/` | release-note 作業とリポジトリ QA の PowerShell helper |
| `references/` | 人間向けのドラフト指針とチェックリスト |
| `assets/` | README で共通利用するブランド資産 |

## 変更前のルール

1. 公開向けの説明を変える場合は `README.md` と `README.ja.md` を同時に更新します。
2. ワークフローを変えた場合は `SKILL.md`、helper script、reference を一緒に合わせます。
3. 新しい公開向けファイルを足したら `scripts/verify-repo-surfaces.ps1` にも検証を追加します。

## ローカル QA

次のコマンドでリポジトリ検証を実行します。

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1
```

このスクリプトでは以下を確認します。

- 必須ファイルの存在
- 相対 Markdown リンク
- README の言語切り替え
- README の asset 参照
- 同梱 PowerShell スクリプトの構文

## 編集ガイド

- 同じ説明を複数ファイルへ重複記載するより、既存の script や reference を拡張してください。
- 例示コマンドは Windows でそのまま使える `git` / `gh` を優先してください。
- `gh release create` / `gh release edit` 用の notes ファイルを書く例は、`SKILL.md` のエンコーディング説明と整合させてください。
- README と contributing ドキュメントは英日で構造を揃えてください。

## コミットスタイル

このリポジトリでは次の形式を使います。

- タイトルは英語
- タイトルの先頭に絵文字を付ける
- 本文は実施内容が分かる箇条書きを 3 行前後入れる
