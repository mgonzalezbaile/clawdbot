.PHONY: run stop status dashboard llm-log llm-system llm-messages

run:
	CLAWDBOT_ANTHROPIC_PAYLOAD_LOG=1 pnpm openclaw gateway run --bind loopback --port 18789

stop:
	pkill -9 -f openclaw || true
	launchctl bootout gui/$$(id -u)/com.clawdbot.gateway 2>/dev/null || true

status:
	pnpm openclaw channels status --probe

dashboard:
	pnpm openclaw dashboard

llm-system:
	grep '"stage":"request"' ~/.clawdbot/logs/anthropic-payload.jsonl | tail -1 | jq '.payload | {model, system: [.system[] | .text]}'

llm-messages:
	tail -f ~/.clawdbot/logs/anthropic-payload.jsonl | jq 'select(.stage == "request") | .payload | {model, message_count: (.messages | length), last_3: [.messages[-3:][] | {role, content: (.content | tostring | .[0:200])}]}'
