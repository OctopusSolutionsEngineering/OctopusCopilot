PULL=never

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -excludeAllProjects \
    -stepTemplate \
    -stepTemplateName "Space Context"     \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > context.tf

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Every Step Project" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > everystep.tf

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Project Settings Example" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > projectsettings1.tf

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Kubernetes Web App" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > k8s.tf

# The project name (i.e "Kubernetes" in this case) must match the value in copilot_request_context.py
./generate_instructions.py k8s.tf "Kubernetes" > instructions_k8s.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Azure Function" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > azurefunction.tf

./generate_instructions.py azurefunction.tf "Azure Function" > instructions_azurefunction.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Azure Web App" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > azurewebapp.tf

./generate_instructions.py azurewebapp.tf "Azure Web App" > instructions_azurewebapp.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "AWS Lambda" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > awslambda.tf

./generate_instructions.py awslambda.tf "AWS Lambda" > instructions_lambda.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "IIS" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > windowsiis.tf

./generate_instructions.py windowsiis.tf "Windows IIS" > instructions_iis.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Script" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > script.tf

./generate_instructions.py script.tf "Script" > instructions_script.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Deployment Orchestration" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > deploymentorchestration.tf

./generate_instructions.py deploymentorchestration.tf "Deployment Orchestration" > instructions_deploymentorchestration.md

docker run --pull $PULL -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Terraform" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > terraform.tf

./generate_instructions.py terraform.tf "Terraform Deploy" > instructions_terraform.md