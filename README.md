# Claude Agents

本 repo 用於維護個人使用的 Claude Code [Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)。實際檔案由 repo 進行版本控制，並透過 symlink 連結至 Claude Code 的執行環境。

　

## 定位與設計準則

agent 的定位、設計準則與 authoring 流程，以 [`claude-skills`](https://github.com/seon-kuraito/claude-skills) 中 [`sk-agent-author`](https://github.com/seon-kuraito/claude-skills/tree/main/skills/sk-agent-author) 的 `SKILL.md` 為唯一權威。

　

## Agents 一覽

目前尚無正式項目，也不預先規劃清單；後續將依重複出現的實際需求逐一建立。

　

## 運作方式

Claude Code 會掃描 `~/.claude/agents/` 來探索可用的 agent；每個 agent 是一份帶 YAML frontmatter 的 `.md` 檔，不需要在 settings 登記。本 repo 每個 agent 一個資料夾，definition、README 與 LICENSE 放在一起，連結時只把 definition 逐檔連進執行目錄，資料夾裡的其他檔案不會進入掃描範圍：

```
~/Developer/<owner>/claude-agents/agents/<name>/<name>.md   ← 實際檔案（本 repo）
~/.claude/agents/<name>.md                                  ← symlink，逐檔建立
```

與 [claude-skills](https://github.com/seon-kuraito/claude-skills)、[claude-hooks](https://github.com/seon-kuraito/claude-hooks) 相同，各 agent 會分別連結至執行環境，因此從任一路徑編輯時，修改的都是同一份檔案。直接安裝在 `~/.claude/agents/` 的第三方 agent 不會納入本 repo。

　

## 使用方式

把 repo 裡的 agent 連結到 Claude Code 執行環境：

```sh
scripts/link-agent.sh <agent-name>
```

`<agent-name>` 是 `agents/` 下的資料夾名稱。

腳本可重複執行：已連結的 agent 會跳過，也不會覆蓋非本 repo 管理的 symlink（例如：同名的第三方 agent）。

　

## 驗證

提交前檢查 repo 裡的 agent：

```sh
scripts/run-checks.sh               # 全部 agent
scripts/run-checks.sh <agent-name>  # 單一 agent
```

這支腳本執行結構層與腳本層檢查，兩者都不消耗模型 token。agent 需要由模型路由，因此本 repo 除了四條共通規則，也實作 `description` 與 `model-cases` 兩條路由專屬規則，另以 `contract` 檢查 `tools` 與 `model` 是否宣告。模型層的觸發與行為案例由 [`sk-agent-author`](https://github.com/seon-kuraito/claude-skills/tree/main/skills/sk-agent-author) 在流程末端執行。共通規則來自 [claude-skills](https://github.com/seon-kuraito/claude-skills) 的 `sk-skill-author/references/verification.md`；並列 repo 不存在時會跳過規則比對。

`agents/` 為空時仍會執行規則比對，讓提交前的檢查能發現規格更新與 runner 實作不一致的情況。

　

## 新增 agent

1. 在 `agents/<agent-name>/` 下撰寫 definition（`<agent-name>.md`）。
2. 執行 `scripts/link-agent.sh <agent-name>` 讓它出現在 `~/.claude/agents/`。
3. 為 agent 撰寫 `tests/model.json`：至少一個 `default: true` 的觸發案例，確認請求會路由到它。
4. 為 agent 撰寫一份自己的 `README.md`，說明：
   - **用途**：解決什麼問題、何時觸發
   - **來源**：原創，或衍生自哪個上游專案
   - **授權**：適用的 license 與相關聲明
5. 將它加入上方的「Agents 一覽」表，並依名稱字母序插入。
6. commit 前確認來源與授權：
   - **原創作品**：在 agent 資料夾內放置一份採用 MIT License 的 `LICENSE` 檔案
   - **衍生自寬鬆授權的上游**：保留上游授權，並在 agent 資料夾內以 `NOTICE` 標明來源、作者與修改內容
   - **來源不明或授權不相容**：不收入本 repo
