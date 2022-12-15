# IAM: Users, Groups, Policies

<aside>
⚠️ IAM = Identity and Access Management, it’s one of AWS **Global Services**.

</aside>

- **Root account** is created by default, shouldn’t be used or shared!
- It’s better to use user with admin permissions instead of root account.
- Users are people within your organization and can be grouped:
    - Groups only contain users, not other groups
    - Users don’t have to belong to any group (it’s not a good practice)
    - User can belong to multiple groups
     

### IAM: Permissions

- User or Groups can be assigned to JSON documents called **policies** (IAM Policy) e.g.

- Policies define the permissions of the users
- In AWS you apply the **least privilege principle**: don’t give more permissions than a user needs

### IAM Policies inheritance

- If you attach IAM Policy at the group level then the policy will get applied for each user in group

### IAM Policies Structure

- **Identity-based** policies are attached to an IAM user, group, or role.
- **Resource-based** policies are attached to a resource.
    - For example, you can attach resource-based policies to Amazon S3 buckets, Amazon SQS queues, VPC endpoints, and AWS Key Management Service encryption keys.
    - With resource-based policies, you can specify who has access to the resource and what actions they can perform on it.

- Identity-based policies and resource-based policies are both permissions policies and are evaluated **together**.

- Consist of:
    - `Version` — policy language version (required)
    - `Statement` — one or more individual statements (required)
- Statements consists of:
    - `Sid` — an identifier for the statement (optional)
    - `Effect` — whether the statement allows or denied access (required)
    - `Principal` — account/user/role to which this policy is applied to
    - `Action` — list of actions this policy allows or denied
    - `Resource` — list of resources to which the action is applied to
    - `Condition` — condition for when this policy is in effect (optional)

```json
{
    "Version": "2012-10-17",
		"Id": "S3-Account-Permissions"
    "Statement": [
        {
						"Sid": "1",
            "Effect": "Allow",
						"Principal": {
							"AWS": ["arn:aws:iam::123123123:kamil"]
						}
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": ["arn:aws:s3::::bucket/*"]
        }
    ]
}
```

### IAM MFA

- You can specify Password Policy:
    - minimum password length etc.
    - allow all IAM users to change their own passwords
    - require users to change their password after some time (password expiration)
    - prevent password re-use

- Multifactor Authentication MFA:
    - Virtual MFA — Authenticator
    - U2F security key
    

### IAM Access Keys

How can users access AWS?

- AWS Management Console - protected by password + MFA
- AWS Command Line Interface (CLI) - protected by access keys
- AWS SDK — protected by access keys

<aside>
⚠️ Access Keys are secret, just like a password!

</aside>

### IAM Roles for Services

- Some AWS service will need to perform actions on your behalf → to do so, we will assign permissions to AWS services with **IAM Roles**
- An IAM role is similar to an IAM user, in that it is an **AWS identity** with permission policies that determine what the identity can and cannot do in AWS.
- You can use roles to delegate access to users, applications, or services that don't normally have access to your AWS resources.
- Roles and users are both AWS identities with permissions policies that determine what the identity can and cannot do in AWS.
- However, instead of being uniquely associated with one person, a role is intended to be assumable by anyone who needs it.
- When you assume a role, it provides you with temporary security credentials for your role session.

Roles can be created for other **AWS service**. Common use cases is to create IAM Role to EC2 or Lambda.

### IAM Security Tools

- **IAM Credentials Report** (account-level) — a report that lists all your account’s users and the status of their various credentials
- **IAM Access Advisor** (user-level) — access advisor shows the service permissions granted to a user and when those services were last accessed.

### Good practices

- Do not use the root account except for AWS account setup
- One physical user = One AWS user
- Assign user to groups and assign permissions to groups
    - Groups contains only users
    - IAM Policies are JSON documents that outlines permissions for users or groups
- Create a strong password policy
- Use and enforce the use of MFA
- Create and use Roles for giving permissions to AWS services
- Audit permissions of your account with the IAM Credentials Report
