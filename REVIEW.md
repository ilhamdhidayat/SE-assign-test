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