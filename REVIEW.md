# Review Results

## Issues Flag on PR

### app/app.py

- On [app/app.py](app/app.py) line 8 there is a **[blocker]** because Hardcoded Secret for Database Password. It cause Credentials Leak. To handle it Please remove the default password on the script and use just from DB_PASSWORD variable value.

```
DB_PASSWORD = os.environ.get("DB_PASSWORD")
```

### infra/variables.tf

- On [infra/variables.tf](infra/variables.tf) line 11 there is a **[blocker]** because Hardcoded Secret for Database Password. It cause Credentials Leak. To handle it, same with [app.py](app/app.py) file, remove the default password this variables.tf and use secret from variables or input from user when run manually.

```
variable "db_password" {
}
```

- **[nice-to-have]** are when adding spesific data type into each variable for ensure data type when need to fill on the variables is.
```
variable "aws_region" {
  default = "us-east-1"
  type    = string
}
```

- **[should-fix]** on line 15 because the default image tag is latest. It's not recommended for image versioning or rollback if needed. Use more specific tag for the image.

### .env

- On [.env](.env) file there a **[blocker]** because Hardcoded Secret for Database URL, Database Password and API Token. It cause Credentials Leak. To handle it, Don't push real .env file to GitHub Repository, remove this file on the next push. If this file used for reference, please rename it to another name, .env.examples for example and use dummy secret values instead of real secret values.

### .gitignore

- On [.gitignore](.gitignore) file there a **[blocker]** because No .env on .gitignore file. It needed to prevent accidentally commit of the .env file. To handle it, Add .env files into the .gitignore file.

```
__pycache__/
*.pyc
.env
```

### Dockerfile

- On [Dockerfile](Dockerfile) file there a **[blocker]** because Hardcoded Secret for Database Password. It cause Credentials Leak. To handle it, either use ENV on the run with variable or env file or use ARG when running docker build.

```
ARG DATABASE_PASSWORD
ENV DB_PASSWORD=$DATABASE_PASSWORD
```

## Infra Pipeline

### CI/CD Pipeline

- Set the CI/CD Pipeline from running when there are some push to branch `main`, into run only when there are closed pull request to branch `main`. Push directly into branch main is not a great idea since it can cause application error if not checked properly. 
```
on:
  pull_request:
    branches: [main]
    types:
      - closed
```

- On `Run tests` step the test is set to **continue-on-error: true** . Set this to false so when there are any issues/fails during the test the CI/CD pipeline will not continued and the app will not deployed.
```
      - name: Run tests
        continue-on-error: false
        run: pytest app/
```

- Adding new step `Set up Terraform` to make sure the terraform command is available like `Set up Python`. And better to use spesific version also to prevent version mismatch when running the apply.
```
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v4
        with:
          terraform-version: "1.15.8"
```

- Adjust `Terraform apply` step, using validate and also plan with output file instead of **-auto-approve**
```
      - name: Terraform apply
        working-directory: infra
        run: |
          terraform init
          terraform validate
          terraform plan -out=prod.tfplan
          terraform apply prod.tfplan
```

### Infrastucture
- Adding remote state file for terraform so when the state will be stored remotely and will not lost after CI/CD Pipeline done.
```
  backend "s3" {
    bucket         = "iac-se-assigment-bucket"
    key            = "terraform/fargate/demo-api.tfstate"
    region         = var.aws_region
    use_lockfile   = true
  }
```

- Set the incoming port for application to be spesific same as the setup port on Application Load Balancer (80) so it will not open all port and set spesific incoming IP only for SSH port (22) for security hardening.
```
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.156.164.122/32"]
  }
```

- Set desired_count for the container to 2 for maximizing the 2 Availability Zone that already created. It also increasing the High Availability and Fault Tolerance.
```
resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
```

## Check & Rollback

For checking the service status enable healthcheck on `aws_lb_target_group` resource, set the path and port of the target, then set also the healthy_threshold, interval, timeout, unhealthy_threshold, matcher if needed. Observability tools can be used as well for alerting system when the service is down. For rollback, I recommend change the tag latest first so it can be rollback to spesific version. But there is option to enable the deployment_circuit_breaker also on `aws_ecs_service` resource. 