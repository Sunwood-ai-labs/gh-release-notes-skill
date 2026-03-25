<div align="center">
  <img src="./assets/logo.svg" alt="GitHub Release Notes Skill logo" width="112" height="112">
  <h1>GitHub Release Notes Skill</h1>
  <p><strong>実際の git diff、tag、検証結果を根拠に GitHub Release Notes を作成し、必要なら同じ根拠から docs 記事ページまで作れる Codex skill です。</strong></p>
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

GitHub Release Notes Skill は、リポジトリの差分根拠をそのまま GitHub release 本文や docs 記事ページに落とし込むための skill です。`SKILL.md`、PowerShell の context collector、再利用できる drafting reference、repo QA をまとめているので、薄い commit 要約ではなく、実際の変更内容に基づいた成果物を作れます。

## このリポジトリでできること

- `git log --oneline` だけに頼らず、実 diff から release notes を作る
- 初回リリースと継続リリースの両方を同じ流れで扱う
- 同じ release evidence から、docs 記事ページも作る
- 既存の version 付き release header SVG がある repo では、それを流用して新しいヘッダー画像も作る
- 既存の version 付き header がまだなくても、`assets/icon.svg`、`assets/logo.svg`、ブランド入り `assets/social-card.svg` など再利用に向く SVG があれば、release にヒーロー画像が有効なときは既定で `release-header-v*.svg` を派生作成する
- 候補 SVG と生成した header SVG は、release collateral に使う前に必ず validator で有効性を確認する
- `gh release create` / `gh release edit` と公開確認までつなげる
- docs サイトがある repo では、release notes を docs にも反映する
- release collateral だけで終わらせず、README や常設の運用 docs まで code-backed に整合確認させる
- release ごとの QA inventory 証跡を残して validator で閉じる
- 日英 README と軽量 QA を備えた共有しやすい skill repo として保つ

## クイックスタート

1. 必要なツールを確認します。

   ```powershell
   git --version
   gh --version
   gh auth status
   ```

2. 必要なら tag を最新化します。

   ```powershell
   git fetch --tags --force
   ```

3. 付属スクリプトで release context を収集します。

   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/collect-release-context.ps1 -Tag v0.1.0
   ```

4. 影響の大きい差分を `git show` などで確認します。

   ```powershell
   git show --stat v0.1.0
   git show HEAD~1..HEAD
   ```

5. 集めた根拠から、必要な成果物を作ります。主張はコードが担保する command / service / surface に限定して書きます。

   ```text
   Use $gh-release-notes to inspect the real diff for this tag and draft either the GitHub release body or docs-backed article pages.
   ```

6. GitHub release を publish する場合は `gh` で反映します。

   ```powershell
   gh release create v0.1.0 --title "v0.1.0" --notes-file .\tmp\release-notes-v0.1.0.md
   gh release view v0.1.0 --json url,body
   ```

7. 記事出力を作る場合は、その場で repo の docs を正本として `docs/guide/articles/<slug>.md` と `docs/ja/guide/articles/<slug>.md` のような記事ページまで作り、Zenn / Qiita 反映は別の配信用 skill に渡します。

8. `assets/release-header-v0.2.0.svg` のような version 付き release header SVG が repo にある場合は、それを元に対象 version 用のヘッダー画像を作り、GitHub release body と関連する docs ページの先頭に載せます。まだ version 付き header がなくても、`assets/icon.svg`、`assets/logo.svg`、ブランド入り `assets/social-card.svg` のような SVG 資産があり、release にヒーロー画像が有効で再利用にも向いているなら、既定で新しい `release-header-v*.svg` をそこから派生作成します。どちらの場合も、再利用する元 SVG と生成した出力 SVG は `powershell -ExecutionPolicy Bypass -File ./scripts/verify-svg-assets.ps1 -RepoPath . -Path <svg-paths>` で検証してから使い、向いていないか validator に落ちた場合はスキップ理由を残します。

9. docs を持つ repo では、release body から参照する docs URL が live になっていることに加えて、`README` と主要な運用 docs を truth-sync してから release を仕上げます。

10. target repo に標準パス `tmp/release-qa-v0.1.0.md` で QA inventory ファイルを [references/release-qa-inventory-template.md](./references/release-qa-inventory-template.md) から作り、close 前の必須 gate として validator を実行します。

   ```powershell
   powershell -ExecutionPolicy Bypass -File D:\Prj\gh-release-notes-skill\scripts\verify-release-qa-inventory.ps1 -RepoPath . -Tag v0.1.0
   ```

11. 最後に Codex から skill を呼び出します。

## 同梱ファイル

| ファイル | 役割 |
| --- | --- |
| [`SKILL.md`](./SKILL.md) | Codex 向けの中核 skill 定義 |
| [`agents/openai.yaml`](./agents/openai.yaml) | skill discovery 用 metadata |
| [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) | tag、比較範囲、変更ファイル、diff stat、commit 履歴を収集 |
| [`scripts/verify-release-qa-inventory.ps1`](./scripts/verify-release-qa-inventory.ps1) | release ごとの QA inventory 証跡を閉じる前に検証する validator |
| [`scripts/verify-svg-assets.ps1`](./scripts/verify-svg-assets.ps1) | 候補 SVG と生成した release header SVG を再利用前に検証する validator |
| [`references/release-note-checklist.md`](./references/release-note-checklist.md) | 大きい release を見直すための checklist |
| [`references/release-note-outline.md`](./references/release-note-outline.md) | release notes の構成用 outline |
| [`references/release-qa-inventory-template.md`](./references/release-qa-inventory-template.md) | claim matrix と truth-sync 証跡を残す runtime QA template |
| [`references/release-note-template.md`](./references/release-note-template.md) | release body のたたき台 template |
| [`CONTRIBUTING.ja.md`](./CONTRIBUTING.ja.md) | 保守と QA の手順 |

## 推奨ワークフロー

1. 対象 repo の `README.md` を読む
2. 既存 release があれば `gh release view <tag>` で現状を確認する
3. `scripts/collect-release-context.ps1` で比較範囲を決める
4. 重要ファイルや user-facing change を実 diff で読む
5. 根拠に基づいて GitHub release body または docs 記事ページを draft する
6. routing / retry / model selection / defaults / env var / telemetry surface など implementation-sensitive な主張は、実装コードか test で裏を取る
7. docs surface がある repo では docs 反映と release header SVG の再利用を既定路線として扱い、version 付き header がまだない場合でも適切な SVG ブランド資産があれば初回 `release-header-v*.svg` の派生作成を検討する
8. 再利用候補の元 SVG と生成した `release-header-v*.svg` は、[`scripts/verify-svg-assets.ps1`](./scripts/verify-svg-assets.ps1) で必ず検証してから使う
9. release notes / 解説記事を release collateral として作ったうえで、`README` と主要運用 docs にも同じ変更が必要か truth-sync を行う
10. target repo に `tmp/release-qa-<tag>.md` で release QA inventory 証跡を materialize し、[`scripts/verify-release-qa-inventory.ps1`](./scripts/verify-release-qa-inventory.ps1) に repo path と tag を渡して検証する
11. 必要なら `gh release create` または `gh release edit` で publish する
12. 公開 body や docs URL、header image URL、SVG validator の結果に加えて、truth-sync した常設 docs と検証済み QA inventory も最終確認する

## セットアップと応用例

実例として扱いやすいのが [Sunwood-ai-labs/bitnet-android-lab](https://github.com/Sunwood-ai-labs/bitnet-android-lab) です。この repo の公開 README では、2026年3月23日に動いた狭い Android Termux 経路と、2026年3月25日の追跡確認が明示されていて、広い互換性主張を避けています。だからこそ `$gh-release-notes` の教材として相性がよく、「release 文面を狭く保つ」「docs と evidence を正本として扱う」「caveat を消さない」をまとめて見せられます。

この repo を使ったセットアップ兼応用パターンは次のようになります。

1. まず root README と、そこから案内されている `docs/guide/setup-termux.md` を読む
2. プロジェクト自身が根拠面として示している `docs/`, `evidence/`, `patches/`, `scripts/termux/`, `scripts/windows/` を確認する
3. 対象 clone 上で [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) を実行して、比較範囲を先に確定する
4. すでに docs を公開している repo なので、docs-backed release notes と companion walkthrough article を既定成果物として扱う
5. patched local build、checkpoint 状態、rerun coverage の限界など、repo 自身の caveat を残したまま、検証済み経路にだけ主張を絞る
6. 将来この repo に SVG header asset やブランド SVG seed が入ったら、[`scripts/verify-svg-assets.ps1`](./scripts/verify-svg-assets.ps1) で検証してから release collateral に再利用する
7. docs review、evidence review、validation command を `tmp/release-qa-<tag>.md` に残し、close 前に validator を通す

応用 prompt 例:

```text
Use $gh-release-notes for Sunwood-ai-labs/bitnet-android-lab. Treat docs-backed release notes and a companion walkthrough article as the default outcome. Inspect README.md, docs/guide/setup-termux.md, docs/results/, docs/reference/, evidence/manifest.md, patches/qvac-fabric-llm.cpp/, scripts/termux/, and scripts/windows/. Keep every claim scoped to the verified Android Termux path documented in the repo and preserve the repo's caveats instead of generalizing to broad Android compatibility.
```

## ローカル QA

この repo 自体を変更したら、次の検証を回します。

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1
```

このスクリプトは、必要ファイル、相対 Markdown link、README の言語切替、asset 配線、PowerShell script の構文、そして repo 自身の SVG asset の妥当性を確認します。

## 補足

- helper script は PowerShell ベースです。ローカル例は `powershell`、GitHub Actions では `pwsh` を想定しています。
- 一時的な notes file を Windows で作る場合は、`gh release create` / `gh release edit` の前に UTF-8 without BOM で保存してください。
- 記事ページは docs を正本にし、必要ならそこから Zenn / Qiita へ展開するのが自然です。
- version 付き release header SVG が repo にある場合は、同じデザイン系列で新 version を作り、release body と docs release/article の両方で再利用するのが自然です。
- まだ version 付き header がなくても、既存の SVG ブランド資産が release ヒーロー画像として十分に使えるなら、そこから最初の `release-header-v*.svg` を派生させるのが既定です。

## ライセンス

このリポジトリは [MIT License](./LICENSE) で公開されています。
