# Claude Agents

個人維護的 Claude Code [Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)。這個 repo 保存實際檔案並負責版控，再透過 symlink 掛進 Claude Code 的執行環境。

　

## 定位

這裡的 agent 主要用來提供「獨立的專業視角」：每個 agent 在自己的 context window 裡，依照一套明確的評估準則給出獨立見解，彼此看不到對方的輸出。隔離換來的是不被錨定的判斷——這是 subagent 機制唯一能硬性保證的東西，也是這個 repo 的立足點。

依「開一個獨立 window 換到什麼」分成兩類：

- **思考型（evaluator）**：換獨立性。使用唯讀工具、帶對抗性任務，產出是判斷本身
- **執行型（worker）**：換 context 經濟與並行。可寫可跑，把繁瑣工作留在主對話之外

分類時問一句：「隔離是為了保護判斷不被污染（思考型），還是為了避免繁瑣工作佔滿主對話（執行型）？」查資料再整理回報的 research agent 屬於執行型。

　

## 設計準則

- 準則寫成問題，不寫成知識；prompt 錨定在該領域既有、可查證的評估框架，不寫想像出來的人設
- 思考型 agent 一律帶對抗性任務（「從你的角度找出這件事會失敗的理由」），輸出固定包含：明確結論、主要風險、什麼證據會改變判斷
- 整合層只攤開分歧，不代替收斂；最後的決策留在維護者身上
- 驗證方式包含：鑑別力測試（repo 內保存已知答案的 fixture）、分歧測試、可行動測試

authoring 規範之後會整理進 `claude-skills` 的 `ultra-agent-author`；在它成熟前，以本 repo 的文件為準。

　

## Agents 一覽

目前尚無正式項目；第一批預計是產品選題的評核面板（老闆、行銷、技術、用戶四個視角）。

　

## 運作方式

Claude Code 會掃描 `~/.claude/agents/` 來探索可用的 agent；每個 agent 是一份帶 YAML frontmatter 的 `.md` 檔，不需要在 settings 登記。本 repo 每個 agent 一個資料夾，definition、README 與 LICENSE 放在一起，連結時只把 definition 逐檔連進執行目錄——資料夾裡的其他檔案不會進入掃描範圍：

```
~/Developer/claude-agents/agents/<name>/<name>.md   ← 實際檔案（本 repo）
~/.claude/agents/<name>.md                          ← symlink，逐檔建立
```

與 claude-skills、claude-hooks 相同：不論從哪個路徑編輯，改到的都是同一份檔案；直接安裝在 `~/.claude/agents/` 的第三方 agent 不會進入本 repo。

　

## 使用方式

把 repo 中的 agent 連結進 Claude Code 執行環境：

```sh
scripts/link-agent.sh <agent-name>
```

`<agent-name>` 是 agent 在 `agents/` 中的資料夾名。腳本可重複執行：已連結的 agent 不會有任何動作，也不會覆蓋任何非自身 symlink 的目標（例如同名的第三方 agent）。

　

## 新增 agent

1. 在 `agents/<agent-name>/` 下撰寫 definition（`<agent-name>.md`）
2. 執行 `scripts/link-agent.sh <agent-name>` 讓它出現在 `~/.claude/agents/`
3. 為 agent 撰寫一份自己的 `README.md`，說明用途、來源與授權
4. commit 前確認出處：
   - **原創作品**：採用 MIT 授權
   - **衍生自寬鬆授權的上游**：保留上游授權，並以 `NOTICE` 標明來源、作者與修改內容
   - **來源不明或授權不相容**：不收入本 repo
