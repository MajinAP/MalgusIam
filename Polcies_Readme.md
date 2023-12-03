# Administrator Policy

This policy grants unlimited power to those who wield it. Users with this policy can perform any action on any resource within the AWS realm. It's like being the supreme ruler, having control over everything.
````
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}

````
## Management Policy

For those who want to oversee and manage AWS resources but not necessarily have absolute power, this policy is ideal. It allows actions related to billing, EC2 instances, Cognito identity, and AWS organizations.

````
json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "billing:*",
        "ec2:*",
        "cognito-identity:*",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
````


## DevOps Policy

DevOps practitioners, this policy is your toolset. It grants permissions to describe the organization and obtain information about EC2 instances. It's like having the ability to peek into the workings of the system.


````
json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "organizations:DescribeOrganization",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
````

## Contractor Policy

For those with a specific role, like a contractor hired for a particular job, this policy grants permissions to describe S3 resources. It's akin to having access to specific tools needed for the job at hand.

````
json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:Describe*",
      "Resource": "*"
    }
  ]
}
````
