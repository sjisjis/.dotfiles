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
