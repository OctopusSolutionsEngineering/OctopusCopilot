docker run -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
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

docker run -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
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

docker run -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
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

./generate_instructions.py k8s.tf "Kubernetes Web App" > instructions_k8s.md

docker run -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
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

./generate_instructions.py azurewebapp.tf "Azure Function" > instructions_azurefunction.md

docker run -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
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

docker run -v $PWD:/tmp/octoexport --rm ghcr.io/octopussolutionsengineering/octoterra \
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