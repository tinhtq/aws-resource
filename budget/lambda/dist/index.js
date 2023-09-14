"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const client_organizations_1 = require("@aws-sdk/client-organizations");
const axios_1 = __importDefault(require("axios"));
const handler = (event) => __awaiter(void 0, void 0, void 0, function* () {
    const message = event.Records[0].Sns.Message;
    let actualAmount = "";
    const regex = /ACTUAL Amount: \$(\d+\.\d+)/;
    const match = regex.exec(message);
    if (match) {
        actualAmount = match[1];
        console.log(actualAmount);
        yield sendMessage(actualAmount);
    }
    else {
        console.log("ACTUAL Amount not found in message");
    }
    return {
        statusCode: 200,
        body: JSON.stringify(message),
    };
});
exports.handler = handler;
function getInfoAccount() {
    var _a, _b, _c;
    return __awaiter(this, void 0, void 0, function* () {
        const client = new client_organizations_1.OrganizationsClient();
        if (!process.env.accountId)
            throw Error("Variable accountId is not defined in environment");
        const input = {
            AccountId: process.env.accountId,
        };
        const command = new client_organizations_1.DescribeAccountCommand(input);
        const response = yield client.send(command);
        return {
            accountId: (_a = response.Account) === null || _a === void 0 ? void 0 : _a.Id,
            email: (_b = response.Account) === null || _b === void 0 ? void 0 : _b.Email,
            name: (_c = response.Account) === null || _c === void 0 ? void 0 : _c.Name,
        };
    });
}
function sendMessage(actualAmount) {
    return __awaiter(this, void 0, void 0, function* () {
        const url = "https://slack.com/api/chat.postMessage";
        const info = yield getInfoAccount();
        const thresholdCost = (Number(process.env.limit) * Number(process.env.threshold)) / 100;
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
        };
        const res = yield axios_1.default.post(url, body, {
            headers: { authorization: `Bearer ${process.env.token}` },
        });
        console.log(res);
    });
}
