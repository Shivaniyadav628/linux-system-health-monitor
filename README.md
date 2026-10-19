# Linux System Health Monitor

A lightweight Linux monitoring and alerting utility built with Bash and Python. The system collects resource-usage information, evaluates system health against defined thresholds, records monitoring results, and sends email notifications when configured limits are exceeded.

## Overview

The Linux System Health Monitor automates routine system-health checks using shell scripting and cron. It combines resource monitoring, persistent logging, and SMTP-based email notifications into a simple, maintainable solution suitable for Linux environments.

## Key Features

- **Resource Monitoring:** Tracks memory utilization, disk utilization, and system load.
- **Threshold-Based Warnings:** Identifies resource usage that reaches configured warning limits.
- **Automated Scheduling:** Executes monitoring checks at five-minute intervals using cron.
- **Persistent Logging:** Maintains health reports and warning records for troubleshooting and review.
- **Email Notifications:** Uses Python and Gmail SMTP to deliver alert notifications.
- **Alert Cooldown:** Suppresses repeated email alerts for one hour after a successful notification.
- **Credential Protection:** Keeps email configuration outside the source repository and uses restricted file permissions.

## Technology Stack

| Component | Technology |
|---|---|
| Monitoring and automation | Bash |
| Email notification service | Python 3 |
| Scheduling | Cron |
| Email transport | SMTP with TLS |
| Development environment | Ubuntu on WSL |
| Version control | Git and GitHub |

## Architecture

1. **Scheduler:** Cron invokes the monitoring script at five-minute intervals.
2. **Collection:** The Bash script retrieves system resource information.
3. **Evaluation:** Resource measurements are compared with configured thresholds.
4. **Logging:** Health reports and warning events are recorded for later inspection.
5. **Notification:** When an alert condition is met, the Bash script invokes the Python email sender.
6. **Cooldown:** A timestamp-based state file prevents repeated notifications during the configured cooldown period.

## Repository Structure

```text
linux-system-health-monitor/
├── health_monitor.sh    # Resource monitoring and alert logic
├── send_alert.py        # SMTP email notification utility
├── README.md            # Project documentation
├── LICENSE              # MIT License
└── .gitignore           # Excludes local and sensitive files
```

Runtime logs, cooldown state, local credentials, and backup files are excluded from version control.

## Requirements

- Linux or Ubuntu through WSL
- Bash
- Python 3
- Cron
- Gmail account with two-step verification and an App Password, if Gmail is used for notifications

## Installation and Configuration

Clone the repository and enter the project directory:

```bash
git clone https://github.com/Shivaniyadav628/linux-system-health-monitor.git
cd linux-system-health-monitor
```

Make the scripts executable:

```bash
chmod +x health_monitor.sh send_alert.py
```

### Email Configuration

Create a local configuration file outside the repository:

```bash
nano ~/.health-monitor.env
```

Configure the following environment values using your own credentials:

```bash
SMTP_USER="your_gmail_address@gmail.com"
SMTP_APP_PASSWORD="your_gmail_app_password"
SMTP_TO="recipient@example.com"
```

Replace the example values with your own configuration. Never put real credentials in the README or commit them to GitHub.

Restrict access to the configuration file:

```bash
chmod 600 ~/.health-monitor.env
```

## Usage

Run the monitor manually:

```bash
./health_monitor.sh
```

Inspect recent monitoring reports:

```bash
tail -n 30 health.log
```

Inspect recorded warnings:

```bash
tail -n 30 warnings.log
```

The log files are generated at runtime and are intentionally not tracked by Git.

## Automated Execution

Configure the user crontab:

```bash
crontab -e
```

Add the following entry, adjusting the directory if necessary:

```cron
*/5 * * * * cd ~/linux-practice && ./health_monitor.sh >> ~/linux-practice/health.log 2>&1
```

Verify the schedule:

```bash
crontab -l
```

## Alert Policy

The current implementation uses an 80% resource-usage threshold and a one-hour email-alert cooldown. These settings should be reviewed in the source code before making configuration changes.

Email delivery requires valid local SMTP credentials, network connectivity, and successful authentication.

## Verification

The following behaviours have been verified:

- Cron executes the production monitoring script at five-minute intervals.
- Monitoring output is written to the health log.
- Resource checks report memory, disk, and system-load information.
- A simulated high-usage test successfully invoked the email sender through cron.
- The email sender's cooldown suppresses repeated alerts during the cooldown window.

The scheduled email test used a separate temporary script and did not change the production threshold.

## Security Considerations

- Credentials are stored outside the repository.
- The local email configuration is protected with restrictive file permissions.
- Logs, runtime state, and backup files are excluded from version control.
- Gmail App Passwords must never be committed to GitHub.
- Any exposed credential should be revoked and replaced.

## Potential Enhancements

- Independent cooldowns for each resource category.
- Configurable thresholds through an external configuration file.
- More precise CPU utilization measurements.
- Structured logging and improved error reporting.
- Additional metrics, historical analysis, and monitoring dashboards.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

**Shivani Gundemoni**

B.Tech Computer Science and Engineering Student

- **GitHub:** [Shivaniyadav628](https://github.com/Shivaniyadav628)
- **Project:** Linux System Health Monitor
- **Technologies:** Bash, Python, Linux, Cron, SMTP

This project was developed as part of my hands-on learning in Linux system administration, shell scripting, automation, and monitoring.
