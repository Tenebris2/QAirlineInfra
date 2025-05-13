from dotenv import load_dotenv
import os
from helper import run_cmd

# Load environment variables from .env file
cwd = os.getcwd()
load_dotenv(os.path.join(cwd, ".env"))

# Access variables
mail_username = os.getenv("MAIL_USERNAME")
mail_password = os.getenv("MAIL_PASSWORD")
mail_server = os.getenv("MAIL_SERVER")
secret_key = os.getenv("SECRET_KEY")
postgres_user = os.getenv("POSTGRES_USER")
postgres_password = os.getenv("POSTGRES_PASSWORD")
print(mail_server)


def generate_db():
    connection_string = run_cmd("terraform output rds_endpoint")
    print(connection_string)
    cmd = f"psql postgresql://{postgres_user}:{postgres_password}@{connection_string}"

    print(cmd + " -c 'CREATE DATABASE airline_db;'")
    with open(
        cwd + "/cluster/secret.yaml",
        "w",
    ) as f:
        f.write(
            f"""
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
type: Opaque
stringData:
  DATABASE_URL: "{connection_string}/airline_db"
  MAIL_USERNAME: "{mail_username}"
  MAIL_PASSWORD: "{mail_password}"
  MAIL_SERVER: "{mail_server}"
  SECRET_KEY: "{secret_key}"
            """
        )


generate_db()
