import re
import sys


def find_octopus_variables(filename):
    # Pattern to match the resource declarations for octopusdeploy_variable
    pattern = r'resource\s+"octopusdeploy_variable"\s+"[^"]+"'

    try:
        # Open and read the file
        print("## Azure Web App Project Variable Instructions\n")
        print(
            "You must include all the following variables once unless otherwise specified:"
        )
        with open(filename, "r") as file:
            for line_number, line in enumerate(file, 1):
                # Check if the line matches our pattern
                match = re.match(pattern, line)
                if match:
                    print(f'* "{match.group(0)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_step_names(filename):
    try:
        # Open and read the file
        print("\n## Azure Web App Project Deployment Process Instructions\n")
        print("You must include all the following steps unless otherwise specified:")
        with open(filename, "r") as file:
            lines = file.readlines()

            # Flag to track if we're inside a deployment_process resource
            inside_deployment_process = False

            for i, line in enumerate(lines):
                # Check if we're entering an octopusdeploy_deployment_process resource
                if re.search(r'resource\s+"octopusdeploy_deployment_process"', line):
                    inside_deployment_process = True
                    continue

                # Check if we're exiting the deployment_process resource
                # A closing brace with no indentation indicates the end of the resource
                if (
                    inside_deployment_process
                    and line.strip() == "}"
                    and not line.startswith(" ")
                ):
                    inside_deployment_process = False
                    continue

                # Only look for steps inside a deployment_process resource
                if inside_deployment_process and re.match(r"\s+step \{", line):
                    # Scan the next 5 lines (or fewer if we reach end of file)
                    for j in range(1, 6):
                        if i + j >= len(lines):
                            break

                        next_line = lines[i + j].strip()
                        if re.match(r"\s*name\s*=", next_line):
                            # Extract the name part (remove quotes if present)
                            name_match = re.match(r'name\s*=\s*"([^"]*)"', next_line)
                            if name_match:
                                print(f'* "{name_match.group(1)}"')
                            break
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_runbook_step_names(filename):
    try:
        # Open and read the file
        print("\n## Azure Web App Project Runbook Deployment Process Instructions")
        with open(filename, "r") as file:
            lines = file.readlines()

            # Flag to track if we're inside a deployment_process resource
            inside_deployment_process = False

            for i, line in enumerate(lines):
                # Check if we're entering an octopusdeploy_deployment_process resource
                if re.search(r'resource\s+"octopusdeploy_runbook_process"', line):
                    inside_deployment_process = True
                    continue

                # Check if we're exiting the deployment_process resource
                # A closing brace with no indentation indicates the end of the resource
                if (
                    inside_deployment_process
                    and line.strip() == "}"
                    and not line.startswith(" ")
                ):
                    inside_deployment_process = False
                    continue

                # Look for the runbook id
                if inside_deployment_process:
                    for j in range(1, 6):
                        if i + j >= len(lines):
                            break

                        next_line = lines[i + j].strip()
                        if re.match(r"\s*runbook_id\s*=", next_line):
                            # Extract the name part (remove quotes if present)
                            name_match = re.match(
                                r'runbook_id\s*=\s*"\$\{length\(data.octopusdeploy_projects\..*?\.projects\) != 0 \? null : octopusdeploy_runbook\.(.*?)\[0]\.id}"',
                                next_line,
                            )
                            if name_match:
                                print(
                                    f"\nYou must include all the following runbook steps from the {name_match.group(1)} runbook unless otherwise specified:"
                                )
                                break

                # Only look for steps inside a deployment_process resource
                if inside_deployment_process and re.match(r"\s+step \{", line):
                    # Scan the next 5 lines (or fewer if we reach end of file)
                    for j in range(1, 6):
                        if i + j >= len(lines):
                            break

                        next_line = lines[i + j].strip()
                        if re.match(r"\s*name\s*=", next_line):
                            # Extract the name part (remove quotes if present)
                            name_match = re.match(r'name\s*=\s*"([^"]*)"', next_line)
                            if name_match:
                                print(f'* "{name_match.group(1)}"')
                            break
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def main():
    # Check if a filename was provided
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        return

    filename = sys.argv[1]
    find_octopus_variables(filename)
    find_step_names(filename)
    find_runbook_step_names(filename)


if __name__ == "__main__":
    main()
