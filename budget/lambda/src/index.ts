import {
  OrganizationsClient,
  DescribeAccountCommand,
} from "@aws-sdk/client-organizations"
import axios from "axios"

export const handler = async (event: any): Promise<any> => {
  const message = event.Records[0].Sns.Message
  let actualAmount = ""
  const regex = /ACTUAL Amount: \$(\d+\.\d+)/
  const match = regex.exec(message)
  if (match) {
    actualAmount = match[1]
    console.log(actualAmount)
    await sendMessage(actualAmount)
  } else {
    console.log("ACTUAL Amount not found in message")
  }

  return {
    statusCode: 200,
    body: JSON.stringify(message),
  }
}

async function getInfoAccount(): Promise<Record<string, string | undefined>> {
  const client = new OrganizationsClient()
  if (!process.env.accountId)
    throw Error("Variable accountId is not defined in environment")
  const input = {
    AccountId: process.env.accountId,
  }
  const command = new DescribeAccountCommand(input)
  const response = await client.send(command)
  return {
    accountId: response.Account?.Id,
    email: response.Account?.Email,
    name: response.Account?.Name,
  }
}
async function sendMessage(actualAmount: string) {
  const url = "https://slack.com/api/chat.postMessage"
  const info = await getInfoAccount()
  const thresholdCost =
    (Number(process.env.limit) * Number(process.env.threshold)) / 100
  const body = {
    channel: process.env.channel,
    blocks: [
      {
        type: "header",
        text: {
          type: "plain_text",
          text: ":rotating_light: AWS Budget Alert :rotating_light:",
          emoji: true,
        },
      },
      {
        type: "divider",
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: ":moneybag: Our AWS budget has been exceeded.",
        },
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `:chart_with_upwards_trend: Your ACUTAL Cost budget has exceeded the limit for the current month. The current ACTUAL Cost is $${actualAmount}, slightly higher than the threshold limit  of ${process.env.threshold}% of $${process.env.limit}, i.e., $${thresholdCost} :worried:`,
        },
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: ":mag: Please review your AWS resource usage to ensure we stay within our budget.",
        },
      },
      {
        type: "divider",
      },
      {
        type: "context",
        elements: [
          {
            type: "mrkdwn",
            text: `*Account ID:* ${info.accountId}`,
          },
          {
            type: "mrkdwn",
            text: `*Account Name:* ${info.name}`,
          },
          {
            type: "mrkdwn",
            text: `*Account Email:* ${info.email}`,
          },
        ],
      },
    ],
  }

  const res = await axios.post(url, body, {
    headers: { authorization: `Bearer ${process.env.token}` },
  })
  console.log(res)
}
