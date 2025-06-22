This directory contains scripts used to generate fine-tuning data for Azure OpenAI. It merges the fine-tuning data 
generated from the tests in Octoterra with fine-tuning examples based on exported template projects.


The process to generate the training examples is as follows:
1. Run the generate_finetune_data.py script from the OctopusTerraformExport/finetune directory
2. Run the generate.sh script to generate the fine-tuning data
3. The merged file is octopus_ai_prompt_merged.jsonl, which can be used to train the AI model