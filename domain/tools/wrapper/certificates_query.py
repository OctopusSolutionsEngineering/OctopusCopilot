from domain.messages.general import build_hcl_prompt
from domain.query.query_inspector import exclude_all_environments


def answer_certificates_wrapper(original_query, callback, logging=None):
    def answer_certificates(space=None, projects=None, runbooks=None, targets=None,
                            tenants=None, environments=None,
                            accounts=None, certificates=None,
                            workerpools=None, machinepolicies=None, tagsets=None,
                            steps=None, **kwargs):
        """Answers a general query about certificates in an Octopus space.
Args:
space: Space name
projects: project names
runbooks: runbook names
targets: target/machine names
tenants: tenant names
environments: environment names
accounts: account names
certificates: certificate names
workerpools: worker pool names
machinepolicies: machine policy names
tagsets: tenant tag set names
steps: step names"""

        if logging:
            logging("Enter:", "answer_targets")

        # Build a few shot sample query with a chain-of-thought example to help the LLM understand the relationships
        # between projects, deployment processes, and variables.

        few_shot = """
Question: List the name and ID of certificates that belong to the \"Test\" environment.
HCL: ###
resource "octopusdeploy_space" "octopus_space_demo_space" {{
  id                          = "Spaces-2342"
  description                 = "Demo space"
  name                        = "Demo"
}}
resource "octopusdeploy_environment" "environment_test" {{
  id                           = "Environments-19923"
  name                         = "Test"
}}
resource "octopusdeploy_environment" "environment_development" {{
  id                           = "Environments-19922"
  name                         = "Development"
}}
resource "octopusdeploy_certificate" "certificate_my_certificate" {{
  id                                = "Certificates-18477"
  name                              = "My certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
resource "octopusdeploy_certificate" "certificate_development_certificate" {{
  id                                = "Certificates-18323"
  name                              = "Dev certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = ["${{octopusdeploy_environment.environment_development.id}}"]
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
resource "octopusdeploy_certificate" "certificate_unscoped_certificate" {{
  id                                = "Certificates-12323"
  name                              = "Unscoped certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
resource "octopusdeploy_certificate" "certificate_another_certificate" {{
  id                                = "Certificates-12333"
  name                              = "Another certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
resource "octopusdeploy_certificate" "certificate_global_certificate" {{
  id                                = "Certificates-12324"
  name                              = "Global certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
###
Answer:
First, assume all certificates belong to the space called "Demo".

Second, find the "octopusdeploy_certificate" resources that have an empty "environments" attribute, which indicates the certificate is not scoped to any environment.
The "octopusdeploy_certificate" "certificate_unscoped_certificate" resource has an empty "environments" attribute. This certificate is included in the results.
The "octopusdeploy_certificate" "certificate_global_certificate" resource has an empty "environments" attribute. This certificate is included in the results.

Third, find the environment with the name "Test".
The "octopusdeploy_environment" resource called "environment_test" has the name "Test".
This is the environment that the targets must reference in their "environments" attribute.

Fourth, find the "octopusdeploy_certificate" resources that have an "environments" attribute that references the "octopusdeploy_environment" resource called "environment_test".
The "octopusdeploy_certificate" "certificate_my_certificate" resource has an "environments" attribute that references the "octopusdeploy_environment" resource called "environment_test". This certificate is included in the results.
The "octopusdeploy_certificate" "certificate_another_certificate" resource has an "environments" attribute that references the "octopusdeploy_environment" resource called "environment_test". This certificate is included in the results.

The targets that belong to the "Test" environment are:
- Name: "My certificate" ID: "Certificates-18477"
- Name: "Another certificate" ID: "Certificates-12333"
- Name: "Unscoped certificate" ID: "Certificates-12323"
- Name: "Global certificate" ID: "Certificates-12324"

Question: What targets are defined in the space "Demo"?
HCL: ###
resource "octopusdeploy_space" "octopus_space_demo_space" {{
  id                          = "Spaces-2342"
  description                 = "Demo space"
  name                        = "Demo"
}}
resource "octopusdeploy_certificate" "certificate_my_certificate" {{
  id                                = "Certificates-18477"
  name                              = "My certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
resource "octopusdeploy_certificate" "certificate_development_certificate" {{
  id                                = "Certificates-18323"
  name                              = "Dev certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
resource "octopusdeploy_certificate" "certificate_another_certificate" {{
  id                                = "Certificates-12333"
  name                              = "Another certificate"
  password                          = ""
  certificate_data                  = ""
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
}}
###
Answer:
First, assume all targets belong to the space called "Demo".

Second, find all the certificates, which are represented by "octopusdeploy_certificate" resources.

The targets that belong to the "Demo" space are:
- Name: "My certificate" ID: "Certificates-18477"
- Name: "Another certificate" ID: "Certificates-12333"
- Name: "Dev certificate" ID: "Certificates-18323"
"""

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_hcl_prompt([
            ("system",
             "Certificates that have an empty \"environments\" attribute are not scoped to any environment and therefore belong to all environments."),
            ("system",
             "Questions asking about certificates that are scoped to a specific environment must include unscoped certificates in the answer."),
            ("user", few_shot)
        ])

        # Certificates are scoped the named environments or unscoped. However, the context will appear the same
        # for an unscoped certificate and a scoped certificate that does not have the associated environments in the
        # context - both certificates will have empty environments array.
        # So if the query mentioned environments, include the environments in the context.
        include_environments = ["<all>"] if not exclude_all_environments(original_query, environments) else []

        return callback(original_query, messages, space, projects, runbooks, targets,
                        tenants, include_environments, accounts, certificates, workerpools, machinepolicies, tagsets,
                        steps)

    return answer_certificates
