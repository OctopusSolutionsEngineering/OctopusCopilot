#!/bin/bash

rm -rf space_population
rm -rf space_creation

docker run -v $PWD:/tmp/octoexport --rm octopussamples/octoterra \
    -url ${OCTOPUS_CLI_SERVER} \
    -space Spaces-2348 \
    -apiKey ${OCTOPUS_CLI_API_KEY} \
    -dest /tmp/octoexport

sudo chown -R $USER:$USER space_population
sudo chown -R $USER:$USER space_creation

# The test environment does not have dynamic workers
rm space_population/workerpool_hosted_ubuntu.tf
rm space_population/workerpool_hosted_windows.tf

sed -i 's/\${data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools\[0\].id}//g' space_population/deployment_process_project1.tf
sed -i 's/\${data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools\[0\].id}//g' space_population/deployment_process_project2.tf
sed -i 's/default\s*=\s*"Copilot Tests"/default="Simple"/g' space_creation/octopus_space_copilot_tests.tf