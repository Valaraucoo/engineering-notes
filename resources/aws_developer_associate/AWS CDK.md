# CDK

Cloud Development Kit — define cloud infra in Python/JS/Java/.NET

- Contains high level components called ********************constructs********************
- The code is “compiled” into a CF template
- ************************************************************************************************************************You can therefore deploy infra and application code together************************************************************************************************************************
    - Great for Lambdas and Docker apps
- SAM: great for serverless, write templates in JSON/YAML, quickly development with Lambda
- CDK: all AWS Services, infra in programming languages
- You can use SAM CLI to locally test your CDK apps
- ************************************************************You must first run `cdk synth` →** call sam local invoke to test locally Lambdas (SYNTHESIZE)

```
cdk bootstrap -> creates necessary resources for CDK Toolkit
cdk synth     -> generate whole CF template generated from CDK
cdk deploy
cdk destroy
```

CDK Constructs:

- ******************Construct****************** is a component that encapsulates everything CDK needs to create the final CF stack
- Construct can be a single AWS resource (e.g. S3 bucket) or multiple related resources (e.g. worker queue with compute)
- **AWS Construct Library**:
    - A collection of constructs included in AWS CDK
    - Every AWS Resource
    - Contains 3 different levels of Constructs available (L1, L2, L3)
- **Construct Hub** — additional constructs from AWS, 3rd parties and open-source CDK community

Layer 1 Constructs (L1):

- Can be called **************************CFN Resources************************** which represents all resources directly available in CF
- Constructs are periodically generated from **CF Resource Specification**
- Constructs names starts with ******Cfn****** (e.g. `CfnBucket`)
- **********************************************************************************************************You must explicitly configure all resource properties**

```jsx
const bucket = new s3.CfnBucket(this, "MyBucket, { bucketName: "xyz" });
```

Layer 2 Constructs (L2):

- Represents AWS resources but with a higher level → intent-based API
- Similar functionality as L1 but with convenient defaults and boilerplate
- Contains extra methods inside of objects
    - Provide methods that make it simpler to work with the resource properties
- You don’t need to know all the details about the resource properties

```jsx
const bucket = new s3.Bucket(this, "MyBucket", { versioned: true });
```

Layer 3 Constructs (L3):

- Can be called ****************Patterns**************** → multiple related resources
- Helps you complete common tasks in AWS

CDK — Important Commands:

```
npm install -g aws-cdk-lib 
cdk init app 
cdk synth     -> synthesizes and prints CF template
cdk bootstrap -> deploys the CDK Toolkit staging Stack
cdk deploy    -> deploy the stack(s)
cdk diff      -> view differences of local CDK and deployed stack
cdk destroy
```

CDK Bootstrap:

- The process of provisioning resources for CDK before you can deploy CDK apps into an AWS Environment
    - AWS Environment = account + region
- CF Stack called **CDKToolkit** is created an contains:
    - S3 bucket - to store files
    - IAM Roles - to grant permissions to perform deployments
- You must run the following command for each new env:

```
cdk bootstrap aws://<aws_account>/<aws_region>
```

CDK — Unit Testing:

- To test CDK apps, use **CDK Assertion Module**
- Verify we have specific resources, rules, conditions, …
- Two types of tests:
    - **Fine-grained Assertions** — test specific aspects of the CF template
    - ****************************Snapshot Tests**************************** — test the synthesized CF template against a previously stored baseline template
- To import a template:

```
Template.fromStack(MyStack)   -> stack built in CDK
Template.fromString(mystring) -> stack build outside CDK
```