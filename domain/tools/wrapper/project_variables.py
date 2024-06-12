from domain.messages.general import build_hcl_prompt


def answer_project_variables_usage_wrapper(original_query, callback, logging=None):
    def answer_project_variables_usage(space=None, projects=None, variables=None, **kwargs):
        """Answers a question where variables are used in a project or if they are unused.

        Args:
        space: Space name
        projects: project names
        variables: variable names
        """

        if logging:
            logging("Enter:", "answer_project_variables_usage")

        # Build a few shot sample query with a chain-of-thought example to help the LLM understand the relationships
        # between projects, deployment processes, and variables.

        few_shot = """
Question: Given the HCL representation of a project and its variables, where are the variables are used in the project "My Project"?
HCL: ###
resource "octopusdeploy_project" "test_project" {{
    name = "My Project"
}}
resource "octopusdeploy_deployment_process" "another_deployment_process" {{
  project_id = "${{octopusdeploy_project.another_project.id}}"
  step {{
    name = "The second projects step"
    action {{
      name = "The second projects step"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{TheSecondProjectsVariable}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }}
    }}
  }}
}}
resource "octopusdeploy_deployment_process" "test_project_deployment_process" {{
  project_id = "${{octopusdeploy_project.test_project.id}}"
  step {{
    name = "My Sample Step Parent"
    action {{
      name = "My Sample Step"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{Variable.Test}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }}
    }}
  }}
    step {{
    name = "Step 2 Parent"
    action {{
      name = "Step 2"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{AnotherVariable}}\\necho #{{SecretVariable}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Azure.AccountId" = "Azure.Account"
      }}
    }}
  }}
}}
resource "octopusdeploy_variable" "project_variable" {{
  owner_id     = "${{octopusdeploy_project.test_project.id}}"
  value        = "I am a variable"
  name         = "Variable.Test"
}}
resource "octopusdeploy_variable" "another_variable" {{
  owner_id     = "${{octopusdeploy_project.test_project.id}}"
  value        = "['An', 'array']"
  name         = "AnotherVariable"
}}
resource "octopusdeploy_variable" "variable3" {{
  owner_id     = "${{octopusdeploy_project.test_project.id}}"
  value        = "hi there"
  name         = "TestVariable3"
}}
resource "octopusdeploy_variable" "secret_variable" {{
  owner_id = "${{octopusdeploy_project.test_project.id}}"
  value = "I am a variable"
  name = "SecretVariable"
  type = "Sensitive"
  sensitive_value = "I am a secret"
  is_sensitive = true
}}
resource "octopusdeploy_variable" "secondprojectvariable" {{
  owner_id     = "${{octopusdeploy_project.another_project.id}}"
  value        = "hi there"
  name         = "SecondProjectVariable"
}}
resource "octopusdeploy_variable" "azure_account" {{
  owner_id = "${{octopusdeploy_project.test_project.id}}"
  value        = "Accounts-1"
  name         = "Azure.Account"
  type         = "AzureAccount"
  is_sensitive = false
}}
###
Answer:
The resource with the labels "octopusdeploy_project" and "test_project" has an attribute called "name" with the value "My Project". This name matches the project name in the query. Therefore, this is the project we base the answer on.
The resource with the labels "octopusdeploy_deployment_process" "test_project_deployment_process" has an attribute called "project_id" that matches the labels of the project called "My Project". Therefore, this deployment process belongs to the project \"My Project\"".

The resource with the labels "octopusdeploy_variable" "project_variable" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "Variable.Test". The deployment process belonging to the "My Project" project has a "step" block with an "action" block with the attribute "name" set to "My Sample Step" and another attribute including the string "Variable.Test". Therefore, the variable "Variable.Test" is used by the step "My Sample Step".
The resource with the labels "octopusdeploy_variable" "another_variable" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "AnotherVariable". The deployment process belonging to the "My Project" project has a "step" block with an "action" block with the attribute "name" set to "Step 2" and another attribute including the string "AnotherVariable". Therefore, the variable "AnotherVariable" is used by the step "Step 2".
The resource with the labels "octopusdeploy_variable" "secret_variable" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "SecretVariable". The deployment process belonging to the "My Project" project has a "step" block with an "action" block with the attribute "name" set to "Step 2" and another attribute including the string "SecretVariable". Therefore, the variable "AnotherVariable" is used by the step "Step 2".
The resource with the labels "octopusdeploy_variable" "azure_account" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "Azure.Account". The deployment process belonging to the "My Project" project has a "step" block with an "action" block with the attribute "name" set to "Step 2" and another attribute including the string "Azure.Account". Therefore, the variable "Azure.Account" is used by the step "Step 2".
The resource with the labels "octopusdeploy_variable" "variable3" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "TestVariable3". None of the attributes assigned to the deployment process belonging to the "My Project" project uses the string "TestVariable3". Therefore, the variable "TestVariable3" is unused.
The resource with the labels "octopusdeploy_variable" "secondprojectvariable" has an attribute called "owner_id" that does not match match the labels of the project called "My Project". Therefore, the variable "SecondProjectVariable" is not included in the answer.

These are the variables used in the project "My Project":
- The variable "Variable.Test" is used by the step "My Sample Step".
- The variable "AnotherVariable" is used by the step "Step 2".
- The variable "SecretVariable" is used by the step "Step 2".
- The variable "TestVariable3" is unused.
"""

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_hcl_prompt([("user", few_shot)])

        return callback(original_query, messages, space, projects, variables)

    return answer_project_variables_usage


def answer_project_variables_wrapper(original_query, callback, logging=None):
    def answer_project_variables(space=None, projects=None, variables=None, **kwargs):
        """Answers a question about the variables defined for a project. This does not provide details about tenants.

        Args:
        space: Space name
        projects: project names
        variables: variable names
        """

        # Few shot example with chain-of-thought example to help the LLM understand the relationships between projects
        # and variables.

        few_shot = """
Question: Given the HCL representation of a project and its variables, list the variables defined in a project "My Project".
HCL: ###
resource "octopusdeploy_project" "test_project" {{
    name = "My Project"
}}
resource "octopusdeploy_deployment_process" "test_project_deployment_process" {{
  project_id = "${{octopusdeploy_project.test_project.id}}"
  step {{
    name = "Deploy with CLI"
    action {{
      name = "Deploy with CLI"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{Variable.Test}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Azure.AccountId" = "Azure.Account"
      }}
    }}
  }}
}}
resource "octopusdeploy_variable" "azure_account" {{
  owner_id = "${{octopusdeploy_project.test_project.id}}"
  value        = "Accounts-1"
  name         = "Azure.Account"
  type         = "AzureAccount"
  is_sensitive = false
}}
resource "octopusdeploy_variable" "project_variable" {{
  owner_id = "${{octopusdeploy_project.test_project.id}}"
  value = "I am a variable"
  name = "Variable.Test"
  is_sensitive = false
}}
resource "octopusdeploy_variable" "secret_variable" {{
  owner_id = "${{octopusdeploy_project.test_project.id}}"
  value = "I am a variable"
  name = "SecretVariable"
  type = "Sensitive"
  sensitive_value = "I am a secret"
  is_sensitive = true
}}
resource "octopusdeploy_variable" "secondprojectvariable" {{
  owner_id     = "${{octopusdeploy_project.another_project.id}}"
  value        = "hi there"
  name         = "SecondProjectVariable"
}}
###
Answer:

The resource with the labels "octopusdeploy_project" and "test_project" has an attribute called "name" with the value "My Project". This name matches the project name in the query. Therefore, this is the project we base the answer on.
The resource with the labels "octopusdeploy_variable" "project_variable" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "Variable.Test". Therefore, the variable "Variable.Test" is defined in the project "My Project".
The resource with the labels "octopusdeploy_variable" "secret_variable" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "SecretVariable". Therefore, the variable "SecretVariable" is defined in the project "My Project".
The resource with the labels "octopusdeploy_variable" "azure_account" has an attribute called "owner_id" that matches the labels of the project called "My Project" and an attribute called "name" with the value "Azure.Account". Therefore, the variable "Azure.Account" is defined in the project "My Project".
The resource with the labels "octopusdeploy_variable" "secondprojectvariable" has an attribute called "owner_id" that does not match match the labels of the project called "My Project". Therefore, the variable "SecondProjectVariable" is not included in the answer.

These are the variables defined in the project "My Project":
- "Variable.Test"
- "SecretVariable"
- "Azure.Account"
"""

        if logging:
            logging("Enter:", "answer_project_variables")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_hcl_prompt([("user", few_shot)])

        return callback(original_query, messages, space, projects, variables)

    return answer_project_variables
