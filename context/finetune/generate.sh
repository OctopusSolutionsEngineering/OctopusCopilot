#!/bin/bash

rm octopus_ai_prompt_response_projects.jsonl
rm octopus_ai_prompt_merged.jsonl
./generate_finetune_data.py
./merge_training_files.py