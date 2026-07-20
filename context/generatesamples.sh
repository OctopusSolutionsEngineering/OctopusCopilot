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
    -url https://samples.octopus.app \
    -space Spaces-1093 \
    -apiKey API-GUEST \
    -projectName "Trident" \
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
cat step_template.json | jq -r '.Properties."Octopus.Action.Terraform.Template"' > samples_flyway.tf
copilot -p "Update samples_flyway.tf using the instructions in bestpractices.txt" --yolo

./generate_instructions.py samples_flyway.tf "Flyway" > instructions_flyway.md