#!/bin/bash

rm *.jsonl
./generate_finetune_data.py
./merge_training_files.py