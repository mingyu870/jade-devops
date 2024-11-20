# CICD base module
Create AWS resource for CICD
 - Connection for github: code star (Manual completion)
 - Notification for slack 
 - ECS cluster


# Before create
Setup up the Slack Chatbot manually, Because Slack connect requires Slack permissions and only via a  web browser.
 - Add workspace manually. See [AWS Documents](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html#slack-client-setup)


# After create

Manual completion connection(codestar) with github organization on `https://{your-region}.console.aws.amazon.com/codesuite/settings/connections` like `https://ap-northeast-2.console.aws.amazon.com/codesuite/settings/connections`

The `aws_codestarconnections_connection` resource create with `PENDING` state.
Authentication with the connection provider must be completed in the AWS Console.
See the AWS documentation(https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html) for details.


# How to get slack IDs

Install AWSbot to channels that receive notification

Find slack workspace ID and channel ID
- Open slack in web browser then copy url `https://app.slack.com/client/Txxxxxxxxxxx/Cxxxxxxxxxx` `Txxxxxxxxxxx` is workspace id and `Cxxxxxxxxxx` is channel id
 - ref sites
  - https://medium.com/@life-is-short-so-enjoy-it/slack-where-how-to-get-slack-channel-id-f6765ff37dcc
  - https://slack.com/intl/en-gb/help/articles/221769328-Locate-your-Slack-URL-or-ID
  - https://help.socialintents.com/article/148-how-to-find-your-slack-team-id-and-slack-channel-id