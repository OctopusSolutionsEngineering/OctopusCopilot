import asyncio

from domain.b64.b64_encoder import decode_string_b64
from infrastructure.github import get_repo_contents


def generate_terraform_wrapper(query, callback, github_token, logging=None):
    def generate_terraform():
        """Generates the Terraform configuration that matches the query. Use this function when
        the query is asking to generate Terraform configuration, Terraform modules, or sample HCL.
        """

        if logging:
            logging("Enter:", "generate_terraform_wrapper")

        messages = [
            ("system",
             "You are methodical agent who understands Terraform modules defining Octopus Deploy resources."),
            ("system",
             "The supplied HCL configuration files are examples of valid Terraform configuration files for the Octopus Terraform provider.")]

        tests = asyncio.run(get_repo_contents("OctopusSolutionsEngineering", "OctopusTerraformExport", "test/terraform",
                                              github_token))

        messages += asyncio.run(get_all_file_content(tests, github_token, logging))

        messages.append(('user', "Question: {input}"))
        messages.append(('user', "Answer:"))

        return callback(query, messages)

    return generate_terraform


async def get_all_file_content(tests, github_token, logging=None):
    contents_results = await asyncio.gather(
        *[get_file_content(test["name"], github_token, logging) for test in tests])
    return [content for content in contents_results if content and not isinstance(content, Exception)]


async def get_file_content(name, github_token, logging=None):
    try:
        test_files = await get_repo_contents("OctopusSolutionsEngineering", "OctopusTerraformExport",
                                             "test/terraform/" + name + "/space_population",
                                             github_token)
        test_files_contents = await asyncio.gather(
            *[get_repo_contents("OctopusSolutionsEngineering", "OctopusTerraformExport",
                                "test/terraform/" + name + "/space_population/" + test_file["name"],
                                github_token) for test_file in test_files], return_exceptions=True)

        contents = [decode_string_b64(test_file_content["content"]) for test_file_content in
                    test_files_contents if not isinstance(test_files_contents, Exception)]

        return ("system", "HCL: ###\n" + "\n\n".join(contents).replace("{", "{{").replace("}", "}}") + "\n###")
    except Exception as e:
        # Sometimes the directory structure might not match the assumptions, or the decode function
        # fails. We want to silently ignore these errors and continue with the next file.
        if logging:
            logging("Error:", str(e))
        return None
