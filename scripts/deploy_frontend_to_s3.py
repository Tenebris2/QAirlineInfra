import os
import json

from helper import run_cmd


# run the script from here if set default
FRONTEND_DIR = os.getenv("FRONTEND_DIR", "../QAirlineCICD/frontend/")
BUCKET_NAME = os.getenv("BUCKET_NAME", "qairlines-website-react-bucket")


def deploy_frontend_to_s3():
    api_endpoint = json.loads(run_cmd("terraform output -json apigw_endpoint"))

    print("Writing endpoint to .env...")

    with open(FRONTEND_DIR + ".env", "w") as f:
        f.write(f"REACT_APP_BACKEND_URL={api_endpoint}\n")

    print("Building frontend...")

    run_cmd("npm run build", cwd=FRONTEND_DIR)

    cmd = (
        f"aws s3 sync '{FRONTEND_DIR}'/build s3://{BUCKET_NAME}/ --profile devops-user"
    )
    print(f"Running {cmd}")
    cmd_res = run_cmd(cmd)

    print(cmd_res)
    print("Sucessfully deployed frontend to S3 bucket")


deploy_frontend_to_s3()
