import json
import urllib3
import os


# Initialize the HTTP client
http = urllib3.PoolManager()

def lambda_handler(event, context):
    # Fetch environment variables
    SLACK_CHANNEL = os.environ['SLACK_CHANNEL']
    HOOK_URL = os.environ['HOOK_URL']

    # Log the entire event object for debugging
    print("Received event:", json.dumps(event, indent=2))

    # Extract the relevant data from the RDS EventBridge event
    subject_header = event.get("detail-type")
    source = event.get("detail", {}).get("SourceType")
    date = event.get("detail", {}).get("Date")
    event_message = event.get("detail", {}).get("Message")
    event_id = event.get("detail", {}).get("EventID")
    event_categories = event.get("detail", {}).get("EventCategories", [])
    

    # Log extracted details for debugging
    print("Subject header:", subject_header)
    print('Source:', source)
    print('Event message:', event_message)
    print('Event Categories:', event_categories)
    print('Event ID:', event_id)
    print('Date:', date)

    # Define color based on some logic, e.g., based on event severity
    color = "#FF9800"  # Default color, adjust as needed

    # Construct the Slack message
    slack_message = {
        "channel": SLACK_CHANNEL,
        "username": "llg-develop-RDS-Alert",
        "attachments": [
            {
                "fallback": "RDS Event Details",
                "color": color,
                "fields": [
                    {
                        "title": "Message",
                        "value": event_message,
                        "short": False
                    },
                    {
                        "title": "Event Categories",
                        "value": event_categories,
                        "short": True
                    },
                    {
                        "title": "Subject",
                        "value": subject_header,
                        "short": True
                    },
                    {
                        "title": "Source",
                        "value": source,
                        "short": True
                    },
                    {
                        "title": "Event ID",
                        "value": event_id,
                        "short": True
                    },
                    {
                        "title": "Date",
                        "value": date,
                        "short": True
                    }
                ],
                "footer": "RDS Event Notification",
            }
        ]
    }

    # Encode the Slack message as JSON and send it
    encoded_msg = json.dumps(slack_message).encode('utf-8')
    response = http.request('POST', HOOK_URL, body=encoded_msg, headers={'Content-Type': 'application/json'})

    # Log the response from Slack
    print(f"Response status: {response.status}")
    print(f"Response data: {response.data.decode('utf-8')}")