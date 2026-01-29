.PHONY: run stop status dashboard

run:
	pnpm moltbot gateway run --bind loopback --port 18789

stop:
	pkill -9 -f moltbot || true
	launchctl bootout gui/$$(id -u)/com.clawdbot.gateway 2>/dev/null || true

status:
	pnpm moltbot channels status --probe

dashboard:
	pnpm moltbot dashboard
