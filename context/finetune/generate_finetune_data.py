#!/usr/bin/env python3

# This script generates a JSONL file for fine-tuning an AI model with Octopus Deploy Terraform configurations.

import re
import json

# Step 1: Read generalinstructions.txt
with open("../generalinstructions.txt", "r") as f:
    general_instructions = f.read()

# Step 2: Read scriptsystemprompt.txt
with open("../scriptsystemprompt.txt", "r") as f:
    script_system_prompt = f.read()

# Step 3: Read script.tf
with open("../script.tf", "r") as f:
    tf_contents = f.read()


# Step 4: Replace the default value of project_script_name
def replace_default_var(content, var_name, new_value):
    pattern = rf'(variable\s*"{var_name}"\s*\{{[^}}]*?default\s*=\s*")([^"]*)(")'
    return re.sub(pattern, rf"\1{new_value}\3", content, flags=re.DOTALL)


tf_contents_modified = replace_default_var(
    tf_contents, "project_script_name", "My Script Project"
)

# Step 5: Create the JSON object
instructions = general_instructions + "\n\n" + script_system_prompt

example_project = (
    "# Example Octopus Script Terraform Configuration" + "\n\n" + tf_contents
)

result = {
    "messages": [
        {
            "role": "system",
            "content": "You are an expert in generating Octopus Deploy Terraform configurations.",
        },
        {"role": "system", "content": instructions},
        {"role": "system", "content": example_project},
        {
            "role": "user",
            "content": 'Create a script project called "My Script Project"',
        },
        {"role": "assistant", "content": tf_contents_modified},
    ]
}

with open("octopus_ai_prompt_response_projects.jsonl", "a") as f:
    item = json.dumps(result, separators=(",", ":"))
    f.write(item + "\n")
