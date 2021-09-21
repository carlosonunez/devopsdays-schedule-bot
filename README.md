# DevOpsDays Program Bot

A simple bot that looks at the schedule for your program and posts what's up next on
Slack.

## How to Use

1. Create a `.env` from `.env.example`
2. `docker-compose run --rm schedule-bot`

## How to Use in GitHub Actions

A GitHub Actions CI pipeline is included if you want to run this on a schedule.

1. Encrypt your `.env`: `ENV_PASSWORD=[foo] docker-compose -f docker-compose.ci.yml run --rm encrypt-gpg`
2. Store the password you used for `ENV_PASSWORD` in [1] as a new secret called `env_file_password`
3. Commit and push your changes.
