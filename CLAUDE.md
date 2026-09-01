# CLAUDE.md — claude-agents

Personal Claude Code subagent definitions — the subagent member of the `claude-*` family. Family-wide coordination norms live in `../claude-meta/CLAUDE.md`; the layer split to remember here: skills guide (how), hooks enforce (must), agents isolate (a separate context window).

## Positioning

Current focus, not an exclusive definition: **independent professional perspectives** — evaluation-panel agents (boss / marketing / tech / user) whose product *is* the judgment. Window isolation is what buys independence from anchoring; persona text is legitimate here because the output is the perspective itself. Worker-style agents are admissible as real needs recur.

## Taxonomy

Classify by which mechanical property the separate window buys:

- **Thinking (evaluator)** — buys independence. Read-only tools, strong model, adversarial mandate; validated by the three subjective tests below.
- **Execution (worker)** — buys context economy and parallelism. Working tools, cheaper model acceptable; objective output, so eligible for real eval fixtures.

Classifier question: "isolation to protect the judgment from anchoring (thinking), or to keep dirty work out of the main window (execution)?" Research-style agents are execution.

## Design norms

Authoring rules will ultimately live in `ultra-agent-author` (`../claude-skills`); until it matures, this section is the reference.

- Write criteria as questions, not knowledge; anchor prompts in real, citable evaluation frameworks of the domain — never invented personas.
- Every thinking agent carries an adversarial mandate ("find why this fails from your angle") and outputs: verdict, top risks, and what evidence would change its mind.
- Synthesis produces a disagreement map, never a combined verdict — convergence and decisions stay with the maintainer.
- Validation: discrimination test (planted-flaw fixtures kept in-repo), divergence test (perspectives must differ substantively), actionability test.

## Layout

One folder per agent: `agents/<name>/` holds the definition (`<name>.md`), its `README.md`, and its `LICENSE`. Only the definition is symlinked into `~/.claude/agents/` via `scripts/link-agent.sh` — per-file, so sibling files stay out of the discovery directory.
