import os
import json

from helper import run_cmd

# run the script from here if set default
FRONTEND_BUILD_DIR = os.getenv("FRONTEND_BUILD_DIR")
BUCKET_NAME = os.getenv("BUCKET_NAME", "qairline-website-react-bucket")


def deploy_frontend_to_s3():
    print("Running frontend build...")
    cmd = f"aws s3 sync '{FRONTEND_BUILD_DIR}' s3://{BUCKET_NAME}/"
    print(f"Running {cmd}")
    run_cmd(cmd)


deploy_frontend_to_s3()
