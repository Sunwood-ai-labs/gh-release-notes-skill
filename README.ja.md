<div align="center">
  <img src="./assets/logo.svg" alt="GitHub Release Notes Skill logo" width="112" height="112">
  <h1>GitHub Release Notes Skill</h1>
  <p><strong>実際の git 差分、タグ、検証結果を根拠に GitHub Release Notes を下書き・公開するための Codex skill です。</strong></p>
  <p>
    <a href="./README.md">English</a>
    |
    <a href="./SKILL.md">Skill Source</a>
    |
    <a href="./CONTRIBUTING.ja.md">Contributing</a>
  </p>
  <p>
    <img src="https://img.shields.io/badge/Codex-Skill-0ea5e9.svg" alt="Codex Skill">
    <img src="https://img.shields.io/badge/PowerShell-5%2B-5391fe.svg" alt="PowerShell 5 or newer">
    <img src="https://img.shields.io/badge/GitHub%20CLI-gh-181717.svg" alt="GitHub CLI">
    <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-0f172a.svg" alt="MIT License"></a>
  </p>
</div>

![GitHub Release Notes Skill hero](./assets/hero.svg)

GitHub Release Notes Skill は、リポジトリの実データをそのまま release notes に落とし込むための skill です。`SKILL.md`、差分収集用 PowerShell スクリプト、ドラフト用リファレンス、そしてリポジトリ QA をまとめ、薄いコミット要約ではなく実際の変更内容に基づく公開文面を作りやすくします。

## このリポジトリでできること

- `git log --oneline` だけに頼らず、実際の差分から release notes を組み立てる
- 初回リリースと通常のタグリリースを同じ流れで扱う
- `gh release create` / `gh release edit` と公開後確認まで一貫して進める
- リポジトリに docs サイトがある場合や、英日ページ付き release notes が求められる場合にも対応できる
- 英日 README と軽量 QA を含む公開向け skill リポジトリとしてそのまま共有できる

## クイックスタート

1. 必要なツールを確認します。

   ```powershell
   git --version
   gh --version
   gh auth status
   ```

2. 必要なら対象リポジトリのタグを最新化します。

   ```powershell
   git fetch --tags --force
   ```

3. このリポジトリの収集スクリプトを使って、対象タグまたはターゲットの情報を集めます。

   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/collect-release-context.ps1 -Tag v0.1.0
   ```

4. 下書き前に、影響の大きい差分を `git show` で確認します。

   ```powershell
   git show --stat v0.1.0
   git show HEAD~1..HEAD
   ```

5. notes ファイルを作ったら GitHub release を作成または更新します。

   ```powershell
   gh release create v0.1.0 --title "v0.1.0" --notes-file .\tmp\release-notes-v0.1.0.md
   gh release view v0.1.0 --json url,body
   ```

6. docs 側にも載せる必要がある場合は、先に docs を更新・公開して、badge リンクの URL が生きてから GitHub release を最終更新します。

7. Codex から skill を呼び出します。

   ```text
   Use $gh-release-notes to draft or update GitHub release notes from the actual code diff for this tag.
   ```

## 同梱ファイル

| ファイル | 役割 |
| --- | --- |
| [`SKILL.md`](./SKILL.md) | Codex 向けの中核 skill 定義と release-note 作業手順 |
| [`agents/openai.yaml`](./agents/openai.yaml) | skill 一覧向けメタデータ |
| [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) | タグ、比較範囲、変更ファイル、差分統計、コミット履歴を収集 |
| [`references/release-note-checklist.md`](./references/release-note-checklist.md) | 大きいリリースや履歴が荒いケース向けの確認リスト |
| [`references/release-note-outline.md`](./references/release-note-outline.md) | release notes の下書き構成テンプレート |
| [`references/release-note-template.md`](./references/release-note-template.md) | 差分の根拠をそのまま release body に落とし込むための記入式テンプレート |
| [`CONTRIBUTING.ja.md`](./CONTRIBUTING.ja.md) | 今後の更新時に守る QA と運用ルール |

## 推奨ワークフロー

1. 対象リポジトリの `README.md` があれば先に読みます。
2. すでに release がある場合は `gh release view <tag>` で現状を確認します。
3. [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) で比較範囲を特定します。
4. 変更されたスクリプト、ワークフロー、ドキュメント、パッケージ設定、ユーザー向け資産の実差分を読みます。
5. ファイル名の列挙ではなく、実際の振る舞いとリリース範囲で文章を組み立てます。
6. docs 併記が必要な場合は、既存の docs フレームワークとロケール構成に合わせてページを追加します。
7. `gh release create` または `gh release edit` で公開します。
8. `gh release view <tag> --json url,body` で公開文面を検証し、docs URL も実際に開けるか確認します。

## ローカル QA

このリポジトリ自体の変更を確認するには、次のコマンドを実行します。

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1
```

このスクリプトは、必須ファイル、相対 Markdown リンク、README の言語切り替え、資産参照、同梱 PowerShell スクリプトの構文をまとめて確認します。

## 補足

- helper script は PowerShell ベースです。ローカル例は `powershell` を使い、GitHub Actions では `pwsh` で実行する前提にしているため CI 側はクロスプラットフォームで扱えます。
- このリポジトリは単一 skill と少数の補助ファイルが中心なので、VitePress ではなくトップレベルの README と参照資料を厚くする構成を採っています。
- Windows で一時的な notes ファイルを書き出すときは、`gh release create` / `gh release edit` 前に UTF-8 without BOM を使ってください。

## ライセンス

このリポジトリは [MIT License](./LICENSE) で公開します。
