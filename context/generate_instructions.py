#!/usr/bin/env python3

# This is a script used to generate instructions for creating projects in Octopus Deploy.
# It does just enough to scan a Terraform file for the relevant resources and variables,
# without having to actually parse HCL.

import re
import sys


def general_instructions(filename, label):
    print(f"# {label} Instructions\n")
    print(
        f'* The supplied "Example Octopus {label} Terraform Configuration" is the primary source of truth for the configuration.'
    )
    print(
        f'* You must respond with Terraform configuration to create an Octopus project, and any supporting resources, based on the "Example Octopus {label} Terraform Configuration".'
    )
    print(
        f'* You must include the steps defined in the "Example Octopus {label} Terraform Configuration" unless the prompt explicit states that steps should be removed or modified.'
    )
    print(
        f'* If the prompt specifies that tenants, targets, machines, feeds, accounts, lifecycles, phases, or any other kind of resources are to be created or added, they must be created in addition to the resources from the "Example Octopus {label} Terraform Configuration".'
    )


def find_octopus_variables(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_variable
    pattern = r'resource\s+"octopusdeploy_variable"\s+"[^"]+"'

    try:
        # Open and read the file
        print(f"## {label} Project Variable Instructions\n")
        print(
            f'You must include all the following variables from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that variables should be removed or modified:'
        )
        with open(filename, "r") as file:
            for line_number, line in enumerate(file, 1):
                # Check if the line matches our pattern
                match = re.match(pattern, line)
                additional_instructions = ""

                if match and "workerpool" in match.group(0).lower():
                    additional_instructions = " (ensure the value of this variable queries the hosted work pool data source first and the default worker pool data source second)"

                if match:
                    print(f"* {match.group(0)}{additional_instructions}")
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_project_scheduled_triggers(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_project_scheduled_trigger
    pattern = r'resource\s+"octopusdeploy_project_scheduled_trigger"\s+"([^"]+)"'

    message = ""
    found = False

    try:
        # Open and read the file
        message += f"\n## {label} Project Scheduled Triggers Instructions\n"
        message += f'\nYou must include all the following project scheduled trigger resources from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that triggers should be removed or modified:\n'
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    found = True
                    message += f'* resource "octopusdeploy_project_scheduled_trigger" "{match.group(1)}"\n'
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")

    if found:
        print(message)


def find_project_channels(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_project_scheduled_trigger
    pattern = r'resource\s+"octopusdeploy_channel"\s+"([^"]+)"'

    found = False
    message = ""

    try:
        # Open and read the file
        message += f"\n## {label} Project Channels Instructions\n"
        message += f'\nYou must include all the following project channel resources from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that channels should be removed or modified:\n'
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    message += (
                        f'* resource "octopusdeploy_channel" "{match.group(1)}"\n'
                    )
                    found = True
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")

    if found:
        print(message)


def find_project_deployment_process(filename, label):
    ignore_list = ["process_child_project"]

    pattern = r'resource\s+"octopusdeploy_process"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Project Deployment Process Instructions\n")
        print(
            f'You must include all the following project deployment process resources from the "Example Octopus {label} Terraform Configuration" once:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* resource "octopusdeploy_process" "{match.group(1)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_project_deployment_process_step_order(filename, label):
    ignore_list = []

    pattern = r'resource\s+"octopusdeploy_process_steps_order"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Project Deployment Process Step Order Instructions\n")
        print(
            f'You must include all the following project deployment process step order resources from the "Example Octopus {label} Terraform Configuration" once:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match and match.group(1) not in ignore_list:
                    print(
                        f'* resource "octopusdeploy_process_steps_order" "{match.group(1)}"'
                    )
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_lifecycles(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_lifecycle
    pattern = r'resource\s+"octopusdeploy_lifecycle"\s+"([^"]+)"'
    data_pattern = r'data\s+"octopusdeploy_lifecycles"\s+"([^"]+)"'

    message = ""
    found = False

    try:
        # Open and read the file
        message += f"\n## {label} Lifecycle Instructions\n"
        message += f'\nYou must include all the following lifecycle resources from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that lifecycles should be removed or modified:\n'
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    found = True
                    message += (
                        f'* resource "octopusdeploy_lifecycle" "{match.group(1)}"\n'
                    )

                match = re.match(data_pattern, line)
                if match:
                    found = True
                    message += f'* data "octopusdeploy_lifecycles" "{match.group(1)}"\n'
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")

    if found:
        print(message)


def find_projects(filename, label):
    ignore_list = ["project_child_project"]

    pattern = r'resource\s+"octopusdeploy_project"\s+"([^"]+)"'
    data_pattern = r'data\s+"octopusdeploy_projects"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Project Instructions\n")
        print(
            f'You must include all the following project resources from the "Example Octopus {label} Terraform Configuration" once:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* resource "octopusdeploy_project" "{match.group(1)}"')

                match = re.match(data_pattern, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* data "octopusdeploy_projects" "{match.group(1)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_environments(filename, label):
    ignore_list = []

    pattern = r'resource\s+"octopusdeploy_environment"\s+"([^"]+)"'
    data_pattern = r'data\s+"octopusdeploy_environments"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Environment Instructions\n")
        print(
            f'You must include all the following environment resources from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that environments should be removed or modified:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* resource "octopusdeploy_environment" "{match.group(1)}"')

                match = re.match(data_pattern, line)
                if match:
                    print(f'* data "octopusdeploy_environments" "{match.group(1)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_feeds(filename, label):
    ignore_list = []

    ecr = r'resource\s+"octopusdeploy_aws_elastic_container_registry"\s+"([^"]+)"'
    docker = r'resource\s+"octopusdeploy_docker_container_registry"\s+"([^"]+)"'
    github = r'resource\s+"octopusdeploy_github_repository_feed"\s+"([^"]+)"'
    helm = r'resource\s+"octopusdeploy_helm_feed"\s+"([^"]+)"'
    maven = r'resource\s+"octopusdeploy_maven_feed"\s+"([^"]+)"'
    nuget = r'resource\s+"octopusdeploy_nuget_feed"\s+"([^"]+)"'
    data_pattern = r'data\s+"octopusdeploy_feeds"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Feed Instructions\n")
        print(
            f'You must include all the following feed resources from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that feeds should be removed or modified:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(ecr, line)
                if match and match.group(1) not in ignore_list:
                    print(
                        f'* resource "octopusdeploy_aws_elastic_container_registry" "{match.group(1)}"'
                    )

                match = re.match(docker, line)
                if match and match.group(1) not in ignore_list:
                    print(
                        f'* resource "octopusdeploy_docker_container_registry" "{match.group(1)}"'
                    )

                match = re.match(github, line)
                if match and match.group(1) not in ignore_list:
                    print(
                        f'* resource "octopusdeploy_github_repository_feed" "{match.group(1)}"'
                    )

                match = re.match(nuget, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* resource "octopusdeploy_nuget_feed" "{match.group(1)}"')

                match = re.match(maven, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* resource "octopusdeploy_maven_feed" "{match.group(1)}"')

                match = re.match(helm, line)
                if match and match.group(1) not in ignore_list:
                    print(f'* resource "octopusdeploy_helm_feed" "{match.group(1)}"')

                match = re.match(github, line)
                if match and match.group(1) not in ignore_list:
                    print(
                        f'* resource "octopusdeploy_github_repository_feed" "{match.group(1)}"'
                    )

                match = re.match(data_pattern, line)
                if match:
                    print(f'* data "octopusdeploy_feeds" "{match.group(1)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_step_names(filename, label):
    # We do not want to include the child project from the orcestration project example.
    # This project is only included to demonstrate how all the data sources link up.
    ignore_list = ["process_step_child_project_run_a_script"]

    try:
        # Open and read the file
        print(f"\n## {label} Project Deployment Process Steps Instructions\n")
        print(
            f'You must include all the following step resources from the "Example Octopus {label} Terraform Configuration" once unless the prompt explicitly states that steps should be removed or modified:'
        )
        with open(filename, "r") as file:
            content = file.read()

            all_processes_data = {}  # {tf_process_name: {'is_runbook': bool}}
            all_step_details = (
                []
            )  # (human_readable_step_name, parent_process_tf_name_from_id)

            in_block = False
            current_block_type = None
            current_block_tf_name = None
            current_block_lines = []
            brace_level = 0

            resource_declaration_regex = re.compile(
                r'resource\s+"([^"]+)"\s+"([^"]+)"\s*\{'
            )
            name_attribute_regex = re.compile(r'name\s*=\s*"([^"]*)"')
            # Regex for extracting the parent process's Terraform resource name from 'process_id'
            process_id_regex = re.compile(
                r'process_id\s*=\s*"(?:[^"]*?\?\s*null\s*:)?\s*octopusdeploy_process\.([^.]+?)(?:\[\d+\])?\.id\s*\}"'
            )

            for line in content.splitlines():
                stripped_line = line.strip()

                brace_level += stripped_line.count("{")
                brace_level -= stripped_line.count("}")

                if in_block:
                    current_block_lines.append(line)

                    if brace_level == 0:
                        in_block = False
                        block_content = "\n".join(current_block_lines)

                        if current_block_type == "octopusdeploy_process":
                            is_runbook = "runbook_id =" in block_content
                            all_processes_data[current_block_tf_name] = {
                                "is_runbook": is_runbook
                            }
                        elif (
                            current_block_type == "octopusdeploy_process_step"
                            or current_block_type
                            == "octopusdeploy_process_templated_step"
                        ):
                            human_readable_name = "Unnamed Step"  # Default fallback
                            name_match = name_attribute_regex.search(block_content)
                            if name_match:
                                human_readable_name = name_match.group(1)

                            parent_process_tf_name = None
                            process_id_match = process_id_regex.search(block_content)
                            if process_id_match:
                                parent_process_tf_name = process_id_match.group(1)

                            if parent_process_tf_name:
                                all_step_details.append(
                                    (
                                        current_block_type,
                                        human_readable_name,
                                        current_block_tf_name,
                                        parent_process_tf_name,
                                    )
                                )

                        current_block_type = None
                        current_block_tf_name = None
                        current_block_lines = []

                else:
                    match = resource_declaration_regex.match(stripped_line)
                    if match:
                        resource_type = match.group(1)
                        tf_resource_name = match.group(2)

                        if resource_type in [
                            "octopusdeploy_process",
                            "octopusdeploy_process_step",
                            "octopusdeploy_process_templated_step",
                        ]:
                            in_block = True
                            current_block_type = resource_type
                            current_block_tf_name = tf_resource_name
                            current_block_lines = []
                            brace_level = stripped_line.count("{")

            for process_tf_name, process_info in all_processes_data.items():
                if not process_info["is_runbook"]:
                    for (
                        current_block_type,
                        human_readable_name,
                        current_block_tf_name,
                        parent_tf_name_ref,
                    ) in all_step_details:
                        if (
                            parent_tf_name_ref == process_tf_name
                            and current_block_tf_name not in ignore_list
                        ):
                            print(
                                f'* resource "{current_block_type}" "{current_block_tf_name}"'
                            )

        print(
            f"\nYou will be penalized for not including these steps if the prompt did not specifically ask for them to be removed or modified."
        )

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_runbook_names(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_runbook
    pattern = r'resource\s+"octopusdeploy_runbook"\s+"([^"]+)"'

    found = False
    message = ""

    try:
        # Open and read the file
        message += f"\n## {label} Project Runbook Instructions\n"
        message += "\nYou must include all the following runbook resources once unless the prompt explicitly states that runbooks should be removed or modified:\n"
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    found = True
                    message += (
                        f'* resource "octopusdeploy_runbook" "{match.group(1)}"\n'
                    )
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")

    if found:
        print(message)


def find_variable_value(filename, variable):
    try:
        # Open and read the file
        with open(filename, "r") as file:
            lines = file.readlines()

            # Flag to track if we're inside a runbook resource
            inside_variable = False

            for i, line in enumerate(lines):
                # Check if we're entering an octopusdeploy_runbook resource
                if re.search(r'variable\s+"' + variable + '"', line):
                    inside_variable = True
                    continue

                # Check if we're exiting the deployment_process resource
                # A closing brace with no indentation indicates the end of the resource
                if inside_variable and line.strip() == "}" and not line.startswith(" "):
                    inside_variable = False
                    continue

                # Only look for the runbook name inside a runbook resource
                if inside_variable:
                    for j in range(1, 6):
                        if i + j >= len(lines):
                            break

                        next_line = lines[i + j].strip()
                        if re.match(r"\s*default\s*=", next_line):
                            # Extract the name part (remove quotes if present)
                            name_match = re.match(r'default\s*=\s*"([^"]*)"', next_line)
                            if name_match:
                                return name_match.group(1)
                            break
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")

    return None


def find_runbook_step_names(filename, label):
    message = ""
    found = False

    try:
        message += (
            f"\n## {label} Project Runbook Deployment Process Steps Instructions\n"
        )
        with open(filename, "r") as file:
            content = file.read()  # Read the whole file content once

            # Stores tf_process_name of runbook processes
            runbook_process_tf_names = []
            # Stores (step_tf_name, human_readable_step_name) for all steps
            all_process_steps_data = []

            # State variables for line-by-line parsing
            in_block = False
            current_block_type = None
            current_block_tf_name = None
            current_block_lines = []
            brace_level = 0

            # Regex for identifying resource declarations
            resource_declaration_regex = re.compile(
                r'resource\s+"([^"]+)"\s+"([^"]+)"\s*\{'
            )
            # Regex for extracting the 'name' attribute
            name_attribute_regex = re.compile(r'name\s*=\s*"([^"]*)"')
            # Regex for finding 'runbook_id' within a block
            runbook_id_regex = re.compile(r"runbook_id\s*=", re.DOTALL)

            for line in content.splitlines():
                stripped_line = line.strip()

                if in_block:
                    current_block_lines.append(
                        line
                    )  # Keep the original line for content analysis

                    brace_level += stripped_line.count("{")
                    brace_level -= stripped_line.count("}")

                    if brace_level == 0:
                        # End of the current top-level resource block
                        in_block = False
                        block_content = "\n".join(current_block_lines)

                        if current_block_type == "octopusdeploy_process":
                            if runbook_id_regex.search(block_content):
                                runbook_process_tf_names.append(current_block_tf_name)
                        elif current_block_type == "octopusdeploy_process_step":
                            name_match = name_attribute_regex.search(block_content)
                            if name_match:
                                human_readable_name = name_match.group(1)
                                all_process_steps_data.append(
                                    (
                                        current_block_tf_name,
                                        current_block_tf_name,
                                        human_readable_name,
                                    )
                                )

                        # Reset block state
                        current_block_type = None
                        current_block_tf_name = None
                        current_block_lines = []

                else:
                    # Check for the start of a new resource block
                    match = resource_declaration_regex.match(stripped_line)
                    if match:
                        resource_type = match.group(1)
                        tf_resource_name = match.group(2)

                        in_block = True
                        current_block_type = resource_type
                        current_block_tf_name = tf_resource_name
                        current_block_lines = []
                        brace_level = stripped_line.count("{")

            # After parsing all lines, process the collected data
            for tf_process_name in runbook_process_tf_names:
                # Derive the base name for the runbook
                runbook_base_name = tf_process_name.replace("process_", "")

                message += f"\nYou must include all the following runbook steps from the runbook_{runbook_base_name} runbook once unless the prompt explicitly states that runbook steps should be removed or modified:\n"

                # Define the prefix that steps for this runbook should start with.
                step_name_prefix = f"process_step_{runbook_base_name}_"

                for (
                    step_tf_name,
                    current_block_tf_name,
                    human_readable_name,
                ) in all_process_steps_data:
                    # Check if the step's Terraform resource name starts with the expected prefix.
                    if step_tf_name.startswith(step_name_prefix):
                        found = True
                        message += f'* resource "octopusdeploy_process_step" "{current_block_tf_name}"\n'

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")

    if found:
        print(message)


def main():
    # Check if a filename was provided
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        return

    filename = sys.argv[1]
    label = sys.argv[2]

    # The order of resources appears to be important. We create the standalone resources first,
    # then the resources that depend on them.
    general_instructions(filename, label)
    find_environments(filename, label)
    find_feeds(filename, label)
    find_projects(filename, label)
    find_runbook_names(filename, label)
    find_project_deployment_process(filename, label)
    find_step_names(filename, label)
    find_runbook_step_names(filename, label)
    find_project_deployment_process_step_order(filename, label)
    find_octopus_variables(filename, label)
    find_lifecycles(filename, label)
    find_project_channels(filename, label)
    find_project_scheduled_triggers(filename, label)


if __name__ == "__main__":
    main()
