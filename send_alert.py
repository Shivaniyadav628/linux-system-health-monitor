


#!/usr/bin/env python3

import smtplib
import ssl
import sys
from email.message import EmailMessage
from pathlib import Path

CONFIG_FILE = Path.home() / ".health-monitor.env"


def load_config():
    config = {}

    for line in CONFIG_FILE.read_text().splitlines():
        line = line.strip()

        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        config[key.strip()] = value.strip().strip('"').strip("'")

    return config


def send_alert(subject, body, recipient=None):
    config = load_config()

    username = config.get("SMTP_USER")
    password = config.get("SMTP_APP_PASSWORD")
    recipient = recipient or config.get("SMTP_TO")

    if not username or not password or not recipient:
        raise ValueError(
            "Check SMTP_USER, SMTP_APP_PASSWORD, and SMTP_TO "
            "in ~/.health-monitor.env."
        )

    message = EmailMessage()
    message["From"] = username
    message["To"] = recipient
    message["Subject"] = subject
    message.set_content(body)

    tls_context = ssl.create_default_context()

    with smtplib.SMTP("smtp.gmail.com", 587, timeout=20) as server:
        server.ehlo()
        server.starttls(context=tls_context)
        server.ehlo()
        server.login(username, password)
        server.send_message(message)


if __name__ == "__main__":
    try:
        if len(sys.argv) == 3 and sys.argv[1] == "--alert":
            send_alert(sys.argv[2], sys.stdin.read())
            print("Alert email sent successfully.")
        else:
            recipient = input(
                "Enter the email address to receive the test alert: "
            ).strip()

            if "@" not in recipient:
                raise ValueError("Please enter a valid-looking email address.")

            send_alert(
                "Linux Health Monitor - Test Alert",
                "Success! Your Ubuntu WSL health monitor can send email alerts.",
                recipient,
            )
            print("Test email sent successfully. Check your inbox and spam folder.")

    except (OSError, ValueError, smtplib.SMTPException) as error:
        print(f"Email could not be sent: {error}", file=sys.stderr)
        raise SystemExit(1)
