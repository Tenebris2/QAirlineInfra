import os
import subprocess


def run_cmd(cmd, cwd=None):
    """
    Run a shell command and return the output.
    """
    result = subprocess.run(cmd, cwd=cwd, shell=True, capture_output=True, text=True)
    return result.stdout
