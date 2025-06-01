This directory contains scripts to generate context files that are uploaded to blob storages and used when generating projects.

The context is generated from the space https://mattc.octopus.app/app#/Spaces-3368/projects?page=1&pageSize=50

Run the `generate.sh` script to generate the context files. 

These files are not used directly by the production application. They are saved in the project to ensure they are not lost.

These files are saved as blobs in Azure storage for production use. See `test_copilot_chat_create_projects.py` for a test that demonstrates how these files are persisted in Azure storage.

See `domain/tools/githubactions/projects/create_template_project.py` for where these files are used.

The `instructions_<projectname>.md` files contain generated instructions that allow the LLM to recreate the template project verbatim. The contents of these files must be copied into the project instruction files. Note that this is a manual process because the `instructions_<projectname>.md` sometime contain instructions that should be left out, usually when there are no runbooks. This may be fixed up in the future, but for now you must manually review the instructions and then copy/paste them into the project instructions.

So the workflow is:

1. Run `generate.sh` to generate the context files.
2. Review the generated `instructions_<projectname>.md` files.
3. Copy the contents of the `instructions_<projectname>.md` files into the project instruction files i.e. files like `awslambdaystemprompt.txt`, `azurefunctionsystemprompt.txt` etc.
4. Upload the *.tf and *.txt files to Azure storage.