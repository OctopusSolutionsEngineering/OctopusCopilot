#!/usr/bin/env python3

# This is a script used to generate instructions for creating projects in Octopus Deploy.
# It does just enough to scan a Terraform file for the relevant resources and variables,
# without having to actually parse HCL.

import re
import sys


def find_octopus_variables(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_variable
    pattern = r'resource\s+"octopusdeploy_variable"\s+"[^"]+"'

    try:
        # Open and read the file
        print(f"## {label} Project Variable Instructions\n")
        print(
            f'You must include all the following variables from the "Example Octopus {label} Terraform Configuration" once unless otherwise specified:'
        )
        with open(filename, "r") as file:
            for line_number, line in enumerate(file, 1):
                # Check if the line matches our pattern
                match = re.match(pattern, line)
                if match:
                    print(f"* {match.group(0)}")
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_project_scheduled_triggers(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_project_scheduled_trigger
    pattern = r'resource\s+"octopusdeploy_project_scheduled_trigger"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Project Scheduled Triggers Instructions\n")
        print(
            f'You must include all the following project scheduled trigger resources from the "Example Octopus {label} Terraform Configuration" unless otherwise specified:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    print(
                        f'* resource "octopusdeploy_project_scheduled_trigger" "{match.group(1)}"'
                    )
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_lifecycles(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_lifecycles
    pattern = r'resource\s+"octopusdeploy_lifecycles"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Lifecycle Instructions\n")
        print(
            f'You must include all the following lifecycle resources from the "Example Octopus {label} Terraform Configuration" unless otherwise specified:'
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    print(f'* resource "octopusdeploy_lifecycles" "{match.group(1)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_step_names(filename, label):
    try:
        # Open and read the file
        print(f"\n## {label} Project Deployment Process Instructions\n")
        print(
            f'You must include all the following step resources from the "Example Octopus {label} Terraform Configuration" unless otherwise specified:'
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
                        elif current_block_type == "octopusdeploy_process_step":
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
                        ]:
                            in_block = True
                            current_block_type = resource_type
                            current_block_tf_name = tf_resource_name
                            current_block_lines = []
                            brace_level = stripped_line.count("{")

            for process_tf_name, process_info in all_processes_data.items():
                if not process_info["is_runbook"]:
                    for (
                        human_readable_name,
                        current_block_tf_name,
                        parent_tf_name_ref,
                    ) in all_step_details:
                        if parent_tf_name_ref == process_tf_name:
                            print(
                                f'* resource "octopusdeploy_process_step" "{current_block_tf_name}"'
                            )

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


def find_runbook_names(filename, label):
    # Pattern to match the resource declarations for octopusdeploy_variable
    pattern = r'resource\s+"octopusdeploy_runbook"\s+"([^"]+)"'

    try:
        # Open and read the file
        print(f"\n## {label} Project Runbook Instructions\n")
        print(
            "You must include all the following runbook resources unless otherwise specified:"
        )
        with open(filename, "r") as file:
            lines = file.readlines()

            for i, line in enumerate(lines):
                match = re.match(pattern, line)
                if match:
                    print(f'* resource "octopusdeploy_runbook" "{match.group(1)}"')
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"Error processing file: {e}")


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
    try:
        print(f"\n## {label} Project Runbook Deployment Process Instructions")
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

                print(
                    f"\nYou must include all the following runbook steps from the runbook_{runbook_base_name} runbook unless otherwise specified:"
                )

                # Define the prefix that steps for this runbook should start with.
                step_name_prefix = f"process_step_{runbook_base_name}_"

                for (
                    step_tf_name,
                    current_block_tf_name,
                    human_readable_name,
                ) in all_process_steps_data:
                    # Check if the step's Terraform resource name starts with the expected prefix.
                    if step_tf_name.startswith(step_name_prefix):
                        print(
                            f'* resource "octopusdeploy_process_step" "{current_block_tf_name}"'
                        )

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
    label = sys.argv[2]
    find_octopus_variables(filename, label)
    find_project_scheduled_triggers(filename, label)
    find_step_names(filename, label)
    find_runbook_names(filename, label)
    find_runbook_step_names(filename, label)
    find_lifecycles(filename, label)


if __name__ == "__main__":
    main()
