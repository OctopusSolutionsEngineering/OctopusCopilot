This directory contains scripts to generate context files that are uploaded to blob storages and used when generating projects.

The context is generated from the space https://mattc.octopus.app/app#/Spaces-3368/projects?page=1&pageSize=50

Run the `generate.sh` script to generate the context files. 

These files are not used directly by the production application. They are saved in the project to ensure they are not lost.

These files are saved as blobs in Azure storage for production use. See `test_copilot_chat_create_projects.py` for a test that demonstrates how these files are persisted in Azure storage.

See `domain/tools/githubactions/projects/create_template_project.py` for where these files are used.