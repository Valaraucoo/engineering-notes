# Other Serverless: Step Function, AppSync & Amplify

AWS Step Functions:

- Model your workflows as state machines (one per workflow)
    - Order fulfillment, Data processing
    - Web applications, any workflow
- Workflows are written in JSON
    - Visualization of the workflow and the execution of the workflows, as well as history
- Starting workflow with SDK, API Gateway, EventBridge
- Step function contains multiple **Tasks**
- **Task state** do some work in your state machine
- **Task** **state** could invoke: Lambda, AWS Batch Job, run ECS task, insert item from DynamoDB, Publish message to SNS/SQS, Launch another Step function workflow,
- Tasks could run an one Activity:
    - EC2, Amazon ECS, on-premises
    - Activities poll the step functions for work
    - activities send results back to step function

Step function states:

- **Choice State** — test for a condition to send to a branch (or default branch)
- ******************************************Fail or Succeed State****************************************** — stop execution with failure or success
- **Pass State** — simply pass its input to its output or inject some fixed data without performing work
- ********************Wait State******************** — provide a delay for a certain amount of time or until a specified time/date
- ******************Map State****************** — dynamically iterate steps
- ****************************Parallel State**************************** — begin parallel branches of execution

Error Handling:

- Any state can encounter runtime errors for various reasons, e.g. task failures
- Use **********Retry********** (to retry failed state) and **********Catch********** (transition to failure path) in the State Machine to handle the errors instead of inside the Application Code
- Predefined error codes:
    - `States.ALL` matches any error name
    - `States.Timeout` task run longer than `TimeoutSeconds` or no heartbeat received
    - `States.TaskFailed` execution failure
    - `States.Permissions` insufficient permissions to execute code
- The state may report its own errors
- Retry (Task or Parallel State):
    - Evaluated from top to bottom
    - **********************ErrorEquals********************** match a specific kind of error
    - **********************IntervalSeconds********************** initial delay before retrying
    - **********************BackoffRate********************** multiple the delay after each retry
    - ******************MaxAttempts****************** default to 3, set to 0 for never retried
    - When max attempts are reached → the **********Catch********** kicks in

```json
"HelloStepFuntion": {
	...
	"Retry": [
		{
			"ErrorEquals": ["States.TaskFailed"],
			"IntervalSeconds": 30,
			"MaxAttempts": 3,
			"BackoffRate": 2.0
		}
	],
	"End": true
}
```

- Catch (Task of Parallel State):
    - Evaluated from top to bottom
    - **********************ErrorEquals********************** match a specific kind of error
    - ********Next******** state to sent to

```json
"HelloStepFuntion": {
	...
	"Catch": [
		{
			"ErrorEquals": ["States.ALL"],
			"Next": "CustomErrorFallback",
			"ResultPath": "$.error"
		}
	],
	"End": true
},
"CustomErrorFallback": {
	"Type": "Pass",
	"End": true
}
```

- ResultPath:
    - include the error in the input into the next state → `"$.error"`

Step Function — Wait for Task Token:

- Allows you to pause Step Function during a Task until a Task Token is returned
- Task might wait for other AWS Services, human approval, 3rd paty integration, etc.
- To do so: Append `.waitForTaskToken` to the `Resource` field to tell Step Functions to wait for the Task Token to be returned
- Task will be paused until it receives that Task Token back with a ******************************SendTaskSuccess****************************** or **********************SendTaskFailure********************** API call
- Possibility to use external systems with Step Function
- Step Function in this case is **pushing** an event out to process

Step Function — Activity Tasks:

- Enables you to have the Task work performed by an ******************************Activity Worker******************************
- ******************************Activity Worker****************************** apps can be running on EC2, Lambda, …
- Activity Worker regularly **poll** for a Task using ************************GetActivityTask************************ API  (pull an event)
- If there is something to proces → poll → After Activity Worker completes its work, it sends a response of its success/failure using ******************************SendTaskSucces****************************** or ******************************SendTaskFailure******************************
- To keep the Task active:
    - Configure how long a task can wait (for processing) by setting **TimeoutSeconds**
    - Periodically send a heartbeat from Activity Worker using **********************************SendTaskHeartBeat********************************** within the time you set in **************HeartBeatSeconds**************
- By configuring a long TimeoutSeconds and actively sending a heartbeat, Activity Task can wait up to 1 year

Standard vs. Express Workflows:

- Standard (default):
    - Max duration up to 1 year
    - Execution Model: Exactly-once execution
    - Execution Rate: 2k / seconds
    - Execution History: up to 90 days or using CW
    - Pricing: number of state transitions
    - Use cases: non-idempotent actions (e.g. payment processing)
- Express (async and sync):
    - Max duration up to 5 minutes
    - Execution Model: Exactly-once execution
    - Execution Rate: 100k / seconds
    - Execution History: CloudWatch Logs (no way to track logs in the console)
    - Pricing: number of state transitions, duration, memory consumption
    - Use cases: IoT data ingestions, streaming data, mobile app backends, …
- **Async Express Workflow doesn’t wait for workflow to complete**
    - You don’t need an immediate response
    - Must manage idempotence
- Sync Express:
    - Wait for workflow to complete
    - You need an immediate response
    - Can be invoked from API GW or Lambda function

AppSync — overview:

- AppSync is managed service that uses **GraphQL**
- AppSync combines data from **one or more sources**
    - Integrated with DynamoDB, Aurora, OpenSearch and more
    - Custom sources with AWS Lambda
- AppSync can be also used to retrieve data in **************************************************real-time with WebSocket or MQTT**
- We have to upload GraphQL schema to AppSync
- Security:
    - API_KEY → same as for API GW
    - AWS_IAM → IAM users / roles / cross-account access
    - OPENID_CONNECT
    - AMAZON_COGNITO_USER_POOLS

Amplify:

- Amplify Studio — UI to create apps
- Amplify CLI
- Amplify Libraries
- Amplify Hosting
- Set of tools to get started with app
- Authentication `amplify add auth` → Cognito
    - Supports MFA, Social Sign-in etc.
    - Pre-built UI components
    - Fine-grained authorization
- Data Store `amplify add api` → AppSync + DynamoDB
    - Powered by GraphQL
- Amplify Hosting `amplify add hosting`
    - Build and host web apps
    - CI/CD
    - PR Reviews
    - Custom Domains
    - Monitoring
    - Redirect and Custom Headers
    - Password Protection
- Amplify End-to-End Testing:
    - Run end-to-end tests in the **test phase** in Amplify
    - Use the test step to run any test commands at build time → `amplify.yml`
    - **Integrated with Cypress testing framework**