# CloudFormation

AWS CloudFormation:

- Infrastructure as Code
- Declarative way of outlining AWS infra and resources
- CloudFormation creates resources in right order, with the exact configuration that you specify
- Benefits:
    - IaC: version control, changes in infra can be reviewd
    - Costs: free, you estimate costs
    - Productivity
    - Separation of concern
    - There is a lot of CF templates

How it works?

- Templates have to be uploaded in S3 and then referenced in CF
- To update a template, we cannot edit previous ones
    - We have to re-upload a new version of the template to AWS
- Stacks are identified by a name
- Deleting a stack deletes every artifacts that was created by CF

Deploying CF templates:

- Manual way:
    - edit templates in CF Designer
- Automated way:
    - edit templates in a YAML file
    - CF supports YAML and JSON
    - using AWS CLI

CF Stack:

- **A stack is a collection of AWS resources that you can manage as a single unit**.
- In other words, you can create, update, or delete a collection of resources by creating, updating, or deleting stacks.
- All the resources in a stack are defined by the stack's **AWS CloudFormation template**.
- A stack, for instance, can include all the resources required to run a web application, such as a web server, a database, and networking rules.
- If a resource can't be created, AWS CloudFormation rolls the stack back and automatically deletes any resources that were created.

CF Building Blocks:

- **Resources**: your AWS resources declared in the template (MANDATORY) → e.g. EC2 instances
- Parameters: the dynamic inputs for your template
- Mappings: the static variables for your template
- Outputs: references to what has been created
- Conditionals: list of conditions to perform resource creation
- Metadata

Templates helpers:

- References
- Functions

ChangeSet — changes provided in new/updated CF stack template.

CloudFormation Resources:

- Resources are mandatory in CF template
- They represent the different AWS Components that will be created and configured
- Resources are declared and can be referenced by each other
- There are over 224 types of resources
- format: `AWS::aws-product-name::data-type-name`

- You cannot create a dynamic amount of resources
    - Every value in CF template should be declared
- Not every AWS Services are supported

CloudFormation Parameters:

- Inputs to CF template
- You can reuse your templates across the company
- Some inputs can not be determined ahead of time
- You won’t have to re-upload a template to change its content
- Parameters can be controlled by all these settings:
    - Type:
        - String
        - Number
        - CommaDelimitedList
        - List<Type>
        - AWS Parameter
    - Description
    - Constraints
    - ConstraintDescription (string)
    - Min/MaxLength
    - Min/MaxValue
    - Defaults
    - AllowedValues (array)
    - AllowedPattern (regexp)
    - NoEcho (boolean) — to pass secrets

```yaml
Parameters:
  InstanceTypeParameter:
    Type: String
    Default: t2.micro
    AllowedValues:
      - t2.micro
      - m1.small
      - m1.large
    Description: Enter t2.micro, m1.small, or m1.large. Default is t2.micro.
```

- You use the `!Ref` intrinsic function to reference a parameter
    - AWS CloudFormation uses the parameter's value to provision the stack
- You can reference parameters from the `Resources` and `Outputs` sections of the same template

```yaml
Parameters: 
  InstanceType: 
    Type: 'AWS::SSM::Parameter::Value<String>'

Resources: 
  Instance: 
    Type: 'AWS::EC2::Instance'
    Properties: 
      InstanceType: !Ref InstanceType
```

Concept: Pseudo Parameters:

- AWS offers us pseudo parameters in any CF template
- These can be used at any time and are enabled by default:

| Reference Value | Example Return Value |
| --- | --- |
| AWS::AccountId | 123123123 |
| AWS::NotificationARNs | [arnaws:sns:…] |
| AWS::NoValue | no value |
| AWS::Region | us-east-2 |
| AWS::StackId | arn:… |
| AWS::StackName | MyStack |

```yaml
Outputs:
  MyStacksRegion:
    Value: !Ref "AWS::Region"
```

CloudFormation Mappings:

- Mappings are fixed variables within your CF Template
- Mappings are optional
- They are very handy to differentiate between different envs, regions, AMI types, etc.
- All the values are hard-coded within the template

```yaml
Mappings: 
  RegionMap: 
    us-east-1: 
      "HVM64": "ami-0ff8a91507f77f867"
    us-west-1: 
      "HVM64": "ami-0bdb828fd58c52235"
```

- Mappings are great when you know in advance all the values that can be taken and that they can be deduced from variables such as: Region, AZ, Env, etc.
- You can reference mappings using `!FindInMap` (`Fn::FindInMap`)
    - `!FindInMap [ MapName, TopLevelKey, SecondLevelKey ]`

```yaml
Value: !FindInMap [RegionAndInstanceTypeToAMIID, !Ref "AWS::Region", !Ref EnvironmentType]
```

CloudFormation Outputs:

- The Outputs section declares optional values that we can import into other stacks
    - If you export outputs, you can use them in another stack
- You can also view the outputs in the AWS Console or in using the AWS CLI
- It’s the best way to perform some collaboration cross stack, as you let expert handle their own part of the stack
- You cannot delete a CF Stack if its outputs are being referenced by another CF Stack

```yaml
Outputs:
  StackVPC:
    Description: The ID of the VPC
    Value: !Ref MyVPC
    Export:
      Name: !Sub "${AWS::StackName}-VPCID"
```

- Cross Stack Reference:
    - You can create a cross-stack reference to export resources from one AWS CloudFormation stack to another.
        - For example, you might have a network stack with a VPC and subnets and a separate public web application stack.
        - To use the security group and subnet from the network stack, you can create a cross-stack reference that allows the web application stack to reference resource outputs from the network stack.
        - With a cross-stack reference, owners of the web application stacks don't need to create or maintain networking rules or assets.
    - To create a cross-stack reference, use the `Export` output field to flag the value of a resource output for export. Then, use the `Fn::ImportValue` intrinsic function to import the value.
    - We then create a second template that leverages that VPC ID
    - We should use `Fn::ImportValue` function

```yaml
Resources:
	Example:
		Type: ...
		Properties:
			VpcId: !ImportValue "xyz-VPCID"
```

- You cannot delete the underlying stack until all the references are deleted too

CloudFormation Conditions:

- Conditions are used to control the creation of resources or outputs based on a condition
- Conditions can be whatever you want them to be:
    - example: Environment is dev or prod
- Each condition can reference another condition, parameter value or mapping

```yaml
Parameters:
  EnvType:
    Type: String
    AllowedValues:
      - prod
      - test
  BucketName:
    Default: ''
    Type: String
Conditions:
  IsProduction: !Equals 
    - !Ref EnvType
    - prod
  CreateBucket: !Not 
    - !Equals 
      - !Ref BucketName
      - ''
  CreateBucketPolicy: !And 
    - !Condition IsProduction
    - !Condition CreateBucket
Resources:
  Bucket:
    Type: 'AWS::S3::Bucket'
    Condition: CreateBucket
  Policy:
    Type: 'AWS::S3::BucketPolicy'
    Condition: CreateBucketPolicy
    Properties:
      Bucket: !Ref Bucket
      PolicyDocument: ...
```

- Instinct Function (Logical) can be any of the following:
    - And, Equals, If, Not, Or

**CloudFormation Functions must to know:**

- Ref, GetAtt, FindInMap, ImportValue, Join, Sub, Condition Functions (If, Not, Equals, etc.)

- `Fn::Ref` to reference parameters or resources:
    - parameters → returns the value of the parameter
    - resources → returns the physical ID of the underlying resource, e.g. EC2 instance id
- `Fn::GetAtt` — used to get other attributes of the resources
    - e.g. `!GetAtt EC2Instance.Arn` or `!GetAtt EC2Instance.AvailabilityZone`
    - you can use `GetAtt` in outputs or resources
- `Fn::ImportValue` — to import value that are exported in other templates
- `Fn::Join` — join values with a delimiter:
    - `!Join [delimiter, [ comma-delimited list of values ]]`
    - e.g. `!Join [ ":", [a, b, c]]` → `a:b:c`
- `Fn::Sub` — substitute variables from a text
    - `!Sub "${AWS::StackName}-VPCID"`

CF Rollbacks:

- Stack Creation Fails:
    - Default: everything rolls back (get deleted)
    - Optionally, you can disable rollback and troubleshoot what happen
- If a resource can't be created, AWS CloudFormation rolls the stack back and automatically deletes any resources that were created.
- Stack Update Fails:
    - The stack automatically rolls back to the previous known working state
    - Ability to see in the log what happened and error messages

CloudFormation Stack Notifications:

- Send Stack events to SNS Topic (Email, Lambda, …)
- Enable SNS Integration using Stack Options
- Any event happening in CF stack → e.g. being created, deleted, updated → sent to SNS topic

ChangeSets:

- When you update a stack, you need to know what changes before it happens for greater confidence
- ChangeSet won’t say if the update will be successful

Nested Stacks:

- Nested Stacks are stacks as a part of other stacks
- They allow you to isolate repeated patterns / common components in separate stacks and call them from other stack, e.g. re-used Load Balancer Configuration

Cross-Stack vs. Nested Stack:

- Cross Stacks:
    - helpful when stacks have different lifecycles
    - use output export and `!ImportValue`
    - when you need to pass export values to many stacks
    - stacks share resources
- Nested Stacks:
    - Helpful when components must be re-used
    - **the nested stack only is imported to the higher level stack (it’s not shared)**
    

StackSets:

- Create, update and delete stacks ******across multiple accounts and regions** with a single operation
- administrator account is needed to create StackSets
- when you updated a stack set, all associated stack instances are updated in all accounts and regions

CloudFormation Drift:

- Drift is the difference between the expected configuration values of stack resources defined in CloudFormation templates and the actual configuration values of these resources in the corresponding CloudFormation stacks.
- If someone changes resource settings in AWS Console → drift
- CloudFormation Drift detects drifts!

CF Stack Policies:

- During a CF Stack update, all update actions are allowed on all resources (by default)
- A **Stack Policy** is a JSON document that defines the update actions that are allowed on specific resources during Stack updates
    - e.g. Allow updates on all resources except the Production Database
- Protect resources from unintended updates
- When you set a Stack Policy → all resources in the Stack are **protected** by **default**
- **Specify an explicit ALLOW for the resources you want to be allowed to be updated**