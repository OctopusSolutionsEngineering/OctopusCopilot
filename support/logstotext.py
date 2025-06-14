#!/usr/bin/env python3

import json
import sys
import ast

# Download log files from the storage account under a path like
# resourceId=/SUBSCRIPTIONS/36083A1B-9710-4AAD-AB70-05E0EACC40FD/RESOURCEGROUPS/OCTOPUSAIAGENT/PROVIDERS/MICROSOFT.WEB/SITES/SPACEBUILDER/y=2025/m=06/d=14/h=00/m=00/PT1H.json

input_file = sys.argv[1] if len(sys.argv) > 2 else "PT1H.json"
output_file = sys.argv[2] if len(sys.argv) > 2 else "output.log"

with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        try:
            data = ast.literal_eval(line)
            message = data.get("properties", {}).get("message", "")
            outfile.write(message + "\n")
        except Exception as e:
            print(e)
            continue
