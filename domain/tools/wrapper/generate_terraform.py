from domain.messages.generate_hcl import generate_hcl_messages


def generate_terraform_wrapper(query, callback, github_token, logging=None):
    def generate_terraform():
        """Generates the Terraform configuration that matches the query. Use this function when
        the query is asking to generate Terraform configuration, Terraform modules, or sample HCL.
        Example prompts include:
        * Create a sample terraform module with three environments called "Development", "Test", and "Production"
        * Generate a Terraform module that creates a project called "My Project" with a runbook called "My Runbook"
        * Create a Terraform configuration that creates a project called "My Project" with a runbook called "My Runbook" and a target called "My Target"
        * Generate a Terraform configuration file that creates a project called "My Project" in the project group "My Project Group" with a runbook called "My Runbook" and a target called "My Target"
        """

        if logging:
            logging("Enter:", "generate_terraform_wrapper")

        return callback(query, generate_hcl_messages(github_token, logging))

    return generate_terraform
