# .claude ディレクトリの管理方針

`~/.claude` には Claude Code の設定ファイルとセッション/キャッシュ等のローカル状態が混在している。
このリポジトリで管理するのは **ユーザーが明示的に設定した内容のみ** で、セッションデータや
キャッシュの類は対象外とする。

## 判断基準

新しいファイル・ディレクトリが `~/.claude` に増えたときは、以下の基準でこのリポジトリに
含めるかどうかを判断する。

- **管理する**: ユーザーが手で書いた・意図的に選んだ設定であり、他マシンでも再現したい内容
  - 例: `settings.json`(permissions, model, statusLine, enabledPlugins など)、
    `statusline-command.sh`、`CLAUDE.md`(グローバル向けの指示があれば)、
    `agents/`, `commands/`, `skills/`, `hooks/`, `output-styles/`, `keybindings.json` など
    自作・カスタマイズしたファイル一式
- **管理しない**: Claude Code が自動生成・更新する実行時状態、キャッシュ、認証情報
  - セッション/履歴/UI状態(実行のたびに変化し、他マシンに持ち込む意味がない)
  - キャッシュ(サイズが大きい・再ダウンロード可能)
  - 認証トークンや個人の権限承認履歴を含むもの(secretsとして扱うべきもの)
  - プロジェクト単位でハーネスが自動生成するローカル設定(`settings.local.json` など)

迷った場合は「他のマシンに持って行っても意味があるか」「手で編集した覚えがあるか」を基準にする。
どちらも No ならリポジトリに含めない。

## 現在の管理対象

- `settings.json` — permissions, model, statusLine, enabledPlugins などのユーザー設定
- `statusline-command.sh` — ステータスライン表示用スクリプト
- `CLAUDE.md` — 全プロジェクト共通のグローバル指示(push前の確認方針など)
- `settings.json` の `hooks.Stop` / `hooks.PermissionRequest` — 応答完了時(Glass)・許可プロンプト表示時(Sosumi)に
  それぞれ別のシステムサウンドと通知バナーで気づけるようにする
- `agents/`, `commands/`, `skills/`, `hooks/`, `output-styles/` — 現時点では未使用だが、
  将来ここにカスタム設定を置くことを想定した空ディレクトリ(`.gitkeep` で存在だけ確保)。
  `dotfiles.sh` は `~/.claude/<dir>` をこのディレクトリへのシンボリックリンクとして作成するため、
  ファイルを追加すればそのまま `~/.claude` 側にも反映される

## 管理対象外(コピー・コミットしない)の具体例

`~/.claude` 配下のうち、以下は自動生成されるローカル状態であり管理しない。

- `settings.local.json` — プロジェクト単位でハーネスが自動生成するローカル権限設定
- `sessions/`, `projects/`, `history.jsonl`, `shell-snapshots/`, `session-env/`, `ide/` などのセッション・履歴データ
- `plugins/cache/`, `plugins/marketplaces/`, `plugins/plugin-catalog-cache.json` などのキャッシュ
- `security/`, `telemetry/`, `backups/`, `file-history/`, `plans/` などのローカル生成物
- `policy-limits.json`, `remote-settings.json`, `remote-settings-consent.json`, `mcp-needs-auth-cache.json`
- `~/.claude.json`(認証トークン等を含む別ファイル。`~/.claude/` の外にあるが混同注意)

## ステータスラインの表示内容

`statusline-command.sh` は2行構成で以下を表示する。

```
[Fable 5] 🧠 19% (190k/1M) | 💰 $32.60
⏱️ 5h: 62% (reset 20:27/残3h00m) いのちを大事に！ | 📅 7d: 41% (8/24 17:27) | 🐙 ec* | 🔀 #12 approved | 📁 .dotfiles | ⏳ 13h16m
```

### 1行目(セッション情報)

| 表示 | 意味 |
|---|---|
| `[Fable 5]` | 使用中のモデル名 |
| `🧠 19%` | コンテキストウィンドウ使用率。50%未満は緑、50〜80%は黄、80%以上は赤 |
| `(190k/1M)` | コンテキストの実トークン数(使用量/モデルのコンテキストサイズ)。%だけでは残量が掴みにくい1Mモデル向け |
| `💰 $32.60` | このセッションの累計コスト(USD) |

### 2行目(リミット・作業状況)

| 表示 | 意味 |
|---|---|
| `⏱️ 5h: 62% (reset 20:27/残3h00m)` | 5時間レートリミットの使用率と、リセット時刻・残り時間。80%以上で赤 |
| `ガンガンいこうぜ！` / `いのちを大事に！` | ペース配分アナウンス。前者はリセット間近なのに使用率が低い(使い切れる)、後者は経過時間に対して使いすぎ |
| `📅 7d: 41% (8/24 17:27)` | 週次レートリミットの使用率とリセット日時 |
| `☠2zombie:1862,66039` | 3時間以上動き続けている `claude` プロセスの警告(`hooks/check-zombie-processes.sh`)。負荷を抑えるため2時間おき、またはリセット間近のみチェックする |
| `🐙 ec*` | gitブランチ名。`*` は未コミットの変更があることを示す |
| `🔀 #12 approved` | 現在のブランチに対応するPRの番号とレビュー状態。`approved` は緑、`changes_requested` は赤、`pending` は黄 |
| `📁 .dotfiles` | カレントディレクトリ名 |
| `⏳ 13h16m` | セッション開始からの経過時間 |

### 表示されない場合

- **5h / 7d が出ない**: `rate_limits` は「Claude.aiサブスクリプション契約者の、セッション最初のAPIレスポンス以降」
  にのみ渡される。それ以前は非表示。またサブスクリプションではなくusage creditsで動いている場合も渡されない
- **🐙 が出ない**: gitリポジトリ外にいる場合は省略される
- **🔀 が出ない**: 現在のブランチに対応するオープンなPRが無い場合は省略される
- **☠ が出ない**: 該当するゾンビプロセスがない、または前回チェックから2時間経っていない(正常)

### レートリミット(5h/7d)と支出上限(spend limit)は別物

`5h: 8%` のように余裕があるのに `You've hit your individual spend limit` と出ることがあるが、
これは矛盾ではなく、2つが別のメーターだから。

| | ステータスラインの `5h` / `7d` | 個人の支出上限 |
|---|---|---|
| 単位 | 使用量(トークン/リクエスト) | 金額(USD) |
| 出どころ | Claude.aiサブスクリプションの枠 | 組織管理者が設定した usage credits の上限 |
| リセット | ローリング5時間 / 7日で自動 | 管理者が引き上げるまで解除されない |
| 表示可否 | statuslineのJSONに含まれる | **JSONに該当フィールドが無く表示できない** |

`/model` で「Draws from usage credits」と表示されるモデル(Fable 5 など)は後者を消費するため、
レートリミットをほとんど使っていなくても支出上限に先に到達しうる。
対処は `/usage-credits` で管理者に上限引き上げを依頼するか、usage creditsを消費しないモデル
(Opus 5 / Sonnet 5 など)に切り替える。

### statuslineに渡されるJSONの主なフィールド

表示項目を増やしたいときの参照用。完全な定義は Claude Code 本体が内蔵しており、
`strings $(readlink -f $(which claude)) | grep -n 'How to use the statusLine command'` 付近で確認できる。

| フィールド | 内容 |
|---|---|
| `model.display_name` / `model.id` | モデル表示名 / モデルID |
| `context_window.used_percentage` / `remaining_percentage` | コンテキスト使用率 / 残り率(0-100、メッセージ前は null) |
| `context_window.total_input_tokens` / `total_output_tokens` | 入力トークン数(キャッシュ読み書き込み) / 直近レスポンスの出力トークン数 |
| `context_window.context_window_size` | 現在のモデルのコンテキストサイズ(例: 200000) |
| `context_window.current_usage.*` | 直近API呼び出しの `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens` |
| `rate_limits.five_hour.used_percentage` / `.resets_at` | 5時間枠の使用率 / リセット時刻(**Unix epoch秒**) |
| `rate_limits.seven_day.used_percentage` / `.resets_at` | 7日枠の使用率 / リセット時刻(同上) |
| `cost.total_cost_usd` | セッション累計コスト |
| `effort.level` | reasoning effort(`low`〜`max`)。対応モデルのみ |
| `thinking.enabled` | 拡張思考の有効/無効 |
| `pr.number` / `pr.review_state` | 現在のブランチのPR番号 / レビュー状態(`approved` など) |
| `workspace.repo.{host,owner,name}` / `workspace.git_worktree` | リポジトリ識別情報 / worktree名 |
| `session_id` / `session_name` / `version` / `output_style.name` | セッションID / `/rename` で付けた名前 / アプリバージョン / 出力スタイル |

`rate_limits` は `used_percentage` と `resets_at` の2つしか無く、すでに両方表示しているため
追加できる項目はない。

## permissions.allow の運用方針(許可プロンプトを減らす)

`settings.json` の `permissions.allow` は、本当に許可が必要な操作だけ確認させ、
それ以外は事前許可しておくためのリスト。以下の基準で追加・判断する。

- **許可リストに追加してよい(=読み取り専用・副作用がない)**
  - 状態を変更しないコマンド: `get`/`describe`/`list`/`view`/`status`/`log`/`diff`/`show` など
  - 例: `git status`, `git log`, `gh pr view`, `aws ec2 describe-*`, MCPツールで名前に
    `read`/`get`/`list`/`search`/`view` を含むもの
  - ただし `git status` や `grep` など Claude Code が最初から自動許可しているコマンドは
    そもそもリストに追記不要(プロンプト自体が出ない)
- **許可リストに追加しない(=書き込み・削除・実行系)**
  - 状態を変更するコマンド: `push`/`create`/`delete`/`merge`/`rm`/`mkdir`/`chmod` など
  - インタプリタ・シェルの任意実行(`python3`, `bash`, `node`, `ruby` などへのワイルドカード許可)は
    任意コード実行を許可することと同義なので、個別の完全一致コマンド以外は許可リスト化しない
  - `gh api *` のようにHTTPメソッド次第で書き込みにもなり得るワイルドカードは慎重に扱う
    (既存で許可済みのものはそのまま維持するが、新規に広げない)
- **迷ったら**: 「実行して状態が変わるか」を基準にする。変わらなければ許可対象、変わるなら
  都度確認させる

新しいコマンドが頻繁に許可プロンプトを出すようになったら、`/fewer-permission-prompts`
(Claude Code の `fewer-permission-prompts` スキル)でセッション履歴から使用頻度を集計し、
上記基準に沿って `permissions.allow` に追記する。

### 社内固有パスを含む許可ルールは置かない

`/Users/takumishoji/app/enechange/...` のような特定プロジェクトのパス・社名・リポジトリ構成を
含む許可ルールは、この `settings.json`(dotfilesリポジトリ、他マシンとも共有)には**追加しない**。

- そのプロジェクト自身の `<project>/.claude/settings.local.json` に書く
  (Claude Code が userSettings / projectSettings / localSettings を自動でマージするため、
  動作は変わらない)
- `settings.local.json` は `~/.config/git/ignore`(=このリポジトリの `.gitignore` をグローバル
  excludesFile として使う設定)により、どのリポジトリでも自動的にgit管理対象外になる
- 迷ったら「このルールにプロジェクト名・社名・機密っぽいパスが含まれるか」を基準にする。
  含まれるなら dotfiles 側ではなく該当プロジェクト側に置く

## 反映方法

`dotfiles.sh` 実行時、`.claude` ディレクトリはシンボリックリンクせず、
上記の管理対象ファイルだけを個別に `~/.claude/` にリンクする(`~/.claude` 自体を
シンボリックリンクに置き換えると、既存のセッションデータ等が壊れるため)。

```sh
ln -snfv ~/.dotfiles/.claude/settings.json ~/.claude/settings.json
ln -snfv ~/.dotfiles/.claude/statusline-command.sh ~/.claude/statusline-command.sh
```

## 更新の手順

管理対象ファイルは現在すべて `~/.claude` 側からリポジトリ側の実体へのシンボリックリンクに
置き換え済みのため、`~/.claude/settings.json` などを直接編集すればリポジトリ側にも自動的に
反映される(コピーは不要)。

新しいファイル・ディレクトリを管理対象に追加する場合は以下の3箇所を更新する。

1. `~/.dotfiles/.claude/` にコピーする
2. `dotfiles.sh` の `.claude` 分岐に `ln -snfv` を追記する
3. 本READMEの「現在の管理対象」に追記する

```sh
cp ~/.claude/<追加したいファイル> ~/.dotfiles/.claude/
ln -snfv ~/.dotfiles/.claude/<追加したいファイル> ~/.claude/<追加したいファイル>
```
