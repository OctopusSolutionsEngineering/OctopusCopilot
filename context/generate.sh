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
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > context.tf

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
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > k8s.tf


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
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > everystep.tf