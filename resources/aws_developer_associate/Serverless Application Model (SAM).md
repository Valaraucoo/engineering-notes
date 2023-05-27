# Serverless Application Model (SAM)

SAM:

- SAM → shortcut for CloudFormation
- All configs in YAML code
- Generate complex CF from simple SAM YAML file
- Supports anything fron CR: outputs, mappings, parameters, etc.
- Easy to deploy
- SAM can use CodeDeploy
- SAM can help you to run Lambda, API GW, DynamoDB locally

Recipe:

- **Transform Header indicates it’s SAM template:**

```json
Transform: 'AWS::Serverless-2016-10-31'
```

- Write Code:

```json
AWS::Serverless::Function
AWS::Serverless::Api
AWS::Serverless::SimpleTable
```

- Package & Deploy:

```json
sam package
aws cloudformation package --s3-bucket <bucket> \
	 --template-file template.yaml \ 
	 --output-template-file dist/template-generated.yaml

sam deploy
aws cloudformation deploy \
	 --template-file template.yaml \ 
	 --stack-name my-sam
```

- Init project

```json
sam init
```

- SAM API Gateway:

```yaml
Resources:
  Function:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: app.lambda_handler
      Runtime: python3.9
			Timeout: 10
      **Events:
				Api:
					Type: Api
					Properties:
						Path: /example
						Method: GET**
```

Events:

- The object describing the source of events which trigger the function.
- Each event consists of a type and a set of properties that depend on that type.
- `Api` → creates API Gateway
- All Events: `AlexaSkill | Api | CloudWatchEvent | CloudWatchLogs | Cognito | DocumentDB | DynamoDB | EventBridgeRule | HttpApi | IoTRule | Kinesis | MQ | MSK | S3 | Schedule | ScheduleV2 | SelfManagedKafka | SNS | SQS`

- SAM DynamoDB:
    - We can create DynamoDB table to use into Lambda

```yaml
Resources:
  Function:
		...
		Environment:
			Variables:
				TABLE_NAME: !Ref Table
				REGION_NAME: !Ref AWS::Region # pseudo parameter
		**Policies:
			- DynamoDBCrudPolicy:
					TableName: !Ref Table**
	Table:
		**Type: AWS::Serverless::SimpleTable
		Properties:
			PrimaryKey:
				Name: user_id
				Type: String
			ProvisionedThroughput:
				ReadCapacityUnits: 1
				WriteCapacityUnits: 1**
```

SAM CloudFormation Designer and Application Repository:

- we can see infrastructure created via SAM in CF Designer

SAM Policy Templates:

- List of templates to apply permissions to your Lambda Functions
- Important Examples:
    - `S3ReadPolicy`
    - `SQSPollerPolicy`
    - `DynamoDBCrudPolicy`

SAM & CodeDeploy:

- **SAM framework natively uses CodeDeploy to update Lambda functions**
- Traffic Shifting feature (using Lambda Aliases)
- Pre and Post traffic hooks features to validate deployment
- Easy & automated rollbacks using CW Alarms
- There is need to create `codedeploy.yaml` file
- In `template.yaml`

```yaml
Resources:
  Function:
		...
		**AutoPublishAlias: live
		DeploymentPreference:
			Type: Canary10Percent10Minutes**
```

SAM Local Capabilities:

- Locally start AWS Lambda:
    - `sam local start-lambda`
    - starts a local endpoint that emulates AWS Lambda
    - Can run automated tests against this local endpoint
- Locally Invoke Lambda
    - `sam local invoke`
    - Invoke Lambda function with payload once and quit after invocation completes
    - Helpful for generating tests cases
- Locally start an API GW Endpoint:
    - `sam local start-api`
    - Starts a local HTTP server that hosts all your functions
    - changes to functions are automatically reloaded
- Generate AWS Events for Lambda Functions:
    - `sm local generate-event`
    - e.g. generate fake s3 event

SAM Summary:

- SAM is built on CF
- **SAM requires the Transform and Resources sections**
- Commands:

```yaml
sam build
sam package
sam deploy
```

- Use SAM Policy Templates
- SAM is integrated with CodeDeploy to do deploy to Lambda aliases

Serverless Application Repository (SAR):

- Managed repository for serverless applications
- **The applications are packaged using SAM**
- Build and publish applications that can be re-used by organizations
    - Can share publicly/privately
- ****************************************************************************************************************************This prevent duplicate work and just go straight to publishing****************************************************************************************************************************
- Application settings and behaviour can be customized using Env vars
- To publish we need to add Metadata into template:

```yaml
Metadata:
	AWS::ServerlessRepo::Application:
		Name: xyz
		Description: xyz
		Author: xyz
		SemanticVersion: 0.1.0
```