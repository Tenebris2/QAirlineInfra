import os


def run_cmd(cmd):
    """
    Run a shell command and return the output.
    """
    result = os.popen(cmd).read()
    return result
