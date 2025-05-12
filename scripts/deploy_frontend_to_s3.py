import os
import json

from scripts.helper import run_cmd

# run the script from here if set default
FRONTEND_BUILD_DIR = os.getenv("FRONTEND_BUILD_DIR", "../../QAirline/frontend/build/")
BUCKET_NAME = os.getenv("BUCKET_NAME", "qairline-website-react-bucket")


def deploy_frontend_to_s3():
    run_cmd(f"aws s3 sync ${FRONTEND_BUILD_DIR} s3://{BUCKET_NAME}/")
