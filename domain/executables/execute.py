import subprocess


def print_output(message):
    print(message)


def execute(args, cwd=None, env=None, print_args=None, print_func=print_output):
    """
        The execute method provides the ability to execute external processes while capturing and returning the
        output to std err and std out and exit code.
    """
    process = subprocess.Popen(args,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               text=True,
                               cwd=cwd,
                               env=env)
    stdout, stderr = process.communicate()
    retcode = process.returncode

    if print_args is not None:
        print_func(' '.join(args))

    if print_func is not None:
        print_func(stdout)
        print_func(stderr)

    return stdout, stderr, retcode
