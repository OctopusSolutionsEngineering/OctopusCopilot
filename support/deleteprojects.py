#!/usr/bin/env python3

# A script to quickly delete projects in a test space.

import os

import requests

OCTOPUS_URL = os.getenv("OCTOPUS_CLI_SERVER")
API_KEY = os.getenv("OCTOPUS_CLI_API_KEY")
SPACE_ID = "Spaces-3606"  # Replace with your space ID

headers = {"X-Octopus-ApiKey": API_KEY, "Content-Type": "application/json"}


def get_projects():
    url = f"{OCTOPUS_URL}/api/{SPACE_ID}/projects?skip=0&take=1000"
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json().get("Items", [])


def delete_project(project_id):
    url = f"{OCTOPUS_URL}/api/{SPACE_ID}/projects/{project_id}"
    response = requests.delete(url, headers=headers)
    response.raise_for_status()


def main():
    projects = get_projects()
    for project in projects:
        name = project["Name"]
        project_id = project["Id"]
        print(f"Project: {name} (ID: {project_id})")
        answer = input("Delete this project? (yes/no): ").strip().lower()
        if answer == "yes" or answer == "y":
            delete_project(project_id)
            print(f"Deleted project: {name}")
        else:
            print(f"Skipped project: {name}")


if __name__ == "__main__":
    main()
