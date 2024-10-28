# IP Address Returner with CloudFront and S3

This project sets up an AWS infrastructure using Terraform to create a simple service that returns the IP address of the requester. It utilizes Amazon CloudFront and S3 to deliver this functionality in a scalable and efficient manner.

## ⚠️ Important Disclaimer

**This project is for testing and demonstration purposes only.**

Please be aware of the following:

- The infrastructure deployed by this project is not intended for production use.
- Security measures may not be comprehensive or up to date.
- Performance and reliability have not been thoroughly tested at scale.
- The project may not comply with all best practices or organizational standards.

Before using any part of this project in a production environment:

1. Thoroughly review and understand all code and configurations.
2. Conduct a comprehensive security audit.
3. Test extensively in a safe, isolated environment.
4. Adapt and modify the code to meet your specific requirements and security standards.
5. Ensure compliance with your organization's policies and any relevant regulations.

The maintainers of this project are not responsible for any issues that may arise from the use of this code in production environments.

---

## Project Overview

The main components of this project are:

1. An S3 bucket for storing static content
2. A CloudFront distribution
3. A CloudFront function that returns the requester's IP address

The CloudFront function is triggered on viewer requests and returns a plain text response containing the IP address of the client making the request.

## Prerequisites

To use this Terraform configuration, you need:

1. An AWS account
2. Terraform installed on your local machine
3. AWS CLI configured with appropriate credentials

## Usage

1. Clone this repository to your local machine.

2. Initialize Terraform:
```
terraform init
```
3. Review the planned changes:
```
terraform plan
```
4. Apply the Terraform configuration:
```
terraform apply
```

5. After the apply is complete, Terraform will output the CloudFront distribution domain name and the S3 bucket name.

6. To test the function, send a GET request to the CloudFront distribution domain name. You should receive your IP address as the response.

## Infrastructure Details

- **S3 Bucket**: A private S3 bucket is created with a random name for storing static content.
- **CloudFront Distribution**: Set up to serve content from the S3 bucket and execute the IP returner function.
- **CloudFront Function**: A simple JavaScript function that returns the requester's IP address.
- **Origin Access Identity**: Ensures that the S3 bucket contents can only be accessed through CloudFront.

## Security Considerations

- The S3 bucket is configured with public access blocked.
- CloudFront uses HTTPS by default.
- The S3 bucket can only be accessed via CloudFront, not directly.

## Outputs

- `cloudfront_domain_name`: The domain name of the CloudFront distribution
- `s3_bucket_name`: The name of the created S3 bucket

## Cleanup

To destroy the created resources:
```
terraform destroy
```

## Contributing

Contributions to improve the project are welcome. Please follow the standard fork, branch, and pull request workflow.

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file included in this repository.
