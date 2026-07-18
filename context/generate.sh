PULL=always
IMAGE=ghcr.io/octopussolutionsengineering/octoterra:latest
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}
RUNTIME_VERSION=$("$CONTAINER_RUNTIME" -v 2>&1) || {
    echo "Failed to run $CONTAINER_RUNTIME -v" >&2
    exit 1
}

VOLUME_SUFFIX=

if printf '%s\n' "$RUNTIME_VERSION" | grep -qi podman; then
    VOLUME_SUFFIX=:z
fi

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Every Step Project" \
    -runbookName "Example Runbook" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > runbook.tf
./generate_instructions.py runbook.tf "Runbook" > instructions_runbook.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://samples.octopus.app \
    -space Spaces-302 \
    -apiKey API-GUEST \
    -projectName "Random Quotes .NET IIS" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -excludeAllRunbooks=true \
    -excludeAllLibraryVariableSets=true \
    -inlineVariableValues \
    -excludeTriggersExcept="Daily Security Scan" \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > vmbluegreen.tf

./generate_instructions.py vmbluegreen.tf "VM Blue/Green" > instructions_vmbluegreen.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Ephemeral Environments" \
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
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > ephemeral_environments.tf

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > k8s.tf

# The project name (i.e "Kubernetes" in this case) must match the value in copilot_request_context.py
./generate_instructions.py k8s.tf "Kubernetes" > instructions_k8s.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > azurefunction.tf

./generate_instructions.py azurefunction.tf "Azure Function" > instructions_azurefunction.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > azurewebapp.tf

./generate_instructions.py azurewebapp.tf "Azure Web App" > instructions_azurewebapp.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://samples.octopus.app \
    -space Spaces-1 \
    -apiKey API-GUEST \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > awslambda.tf

./generate_instructions.py awslambda.tf "AWS Lambda" > instructions_lambda.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
 -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Argo CD Octopub" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllTriggers=true \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > argoupdatetags.tf

./generate_instructions.py argoupdatetags.tf "Argo CD Update Image Tags" > instructions_argoupdatetags.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
 -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Argo CD Octopub Manifest" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllTriggers=true \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > argoupdatemanifest.tf

./generate_instructions.py argoupdatemanifest.tf "Argo CD Update Manifest" > instructions_argoupdatemanifest.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://samples.octopus.app \
    -space Spaces-203 \
    -apiKey API-GUEST \
    -projectName "Octopub" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > apachetomcat.tf

./generate_instructions.py apachetomcat.tf "Apache Tomcat" > instructions_tomcat.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > windowsiis.tf

./generate_instructions.py windowsiis.tf "Windows IIS" > instructions_iis.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Windows Service" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > windowsservice.tf

./generate_instructions.py windowsservice.tf "Windows IIS" > instructions_windowsservice.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "Empty Project" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > emptyproject.tf

./generate_instructions.py emptyproject.tf "Empty" > instructions_emptyproject.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > script.tf

./generate_instructions.py script.tf "Script Execution" > instructions_script.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > deploymentorchestration.tf

./generate_instructions.py deploymentorchestration.tf "Deployment Orchestration" > instructions_deploymentorchestration.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
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
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > terraform.tf

./generate_instructions.py terraform.tf "Terraform Deploy" > instructions_terraform.md

"$CONTAINER_RUNTIME" run --pull "$PULL" -v "$PWD:/tmp/octoexport$VOLUME_SUFFIX" --rm "$IMAGE" \
    -url https://mattc.octopus.app \
    -space Spaces-3368 \
    -apiKey $OCTOPUS_CLI_API_KEY \
    -projectName "LLM in Kubernetes" \
    -stepTemplate \
    -stepTemplateName "Space Context" \
    -stepTemplateKey "SpaceContext" \
    -dummySecretVariableValues \
    -includeProviderServerDetails=false \
    -ignoreCacManagedValues=false \
    -excludeCaCProjectSettings=true \
    -includeOctopusOutputVars=false \
    -inlineVariableValues \
    -excludeAllRunbooks=true \
    -dest /tmp/octoexport
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > llm.tf

./generate_instructions.py llm.tf "LLM Kubernetes" > instructions_llm.md