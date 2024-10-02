import unittest
import json

from domain.validation.octopus_validation import (
    is_api_key,
    is_manual_intervention_valid,
    is_hosted_octopus,
)

sample_manual_intervention = """
[
    {
      "Id": "Interruptions-7104",
      "SpaceId": "Spaces-1765",
      "Title": "Approve deployment",
      "Type": "ManualIntervention",
      "Created": "2024-08-12T09:37:43.437+00:00",
      "IsPending": true,
      "Form": {
        "Values": {
          "Instructions": null,
          "Notes": null,
          "Result": null
        },
        "Elements": [
          {
            "Name": "Instructions",
            "Control": {
              "Type": "Paragraph",
              "Text": "Do stuff here",
              "ResolveLinks": false
            },
            "IsValueRequired": false
          },
          {
            "Name": "Notes",
            "Control": {
              "Type": "TextArea",
              "Label": "Notes"
            },
            "IsValueRequired": false
          },
          {
            "Name": "Result",
            "Control": {
              "Type": "SubmitButtonGroup",
              "Buttons": [
                {
                  "Text": "Proceed",
                  "Value": "Proceed",
                  "RequiresConfirmation": false
                },
                {
                  "Text": "Abort",
                  "Value": "Abort",
                  "RequiresConfirmation": true
                }
              ]
            },
            "IsValueRequired": false
          }
        ]
      },
      "RelatedDocumentIds": [
        "Deployments-122622",
        "ServerTasks-1023377",
        "Projects-4902",
        "Environments-2441"
      ],
      "ResponsibleTeamIds": [
        "Teams-781"
      ],
      "ResponsibleUserId": null,
      "CanTakeResponsibility": true,
      "HasResponsibility": false,
      "TaskId": "ServerTasks-1023377",
      "CorrelationId": "ServerTasks-1023377_KWS2H6YNJR/052e168d7d81480d994924bcd16f342e/d41bc31db47349d392f46d9e7c9da089",
      "IsLinkedToOtherInterruption": false,
      "Links": {
        "Self": "/api/Spaces-1765/interruptions/Interruptions-7104",
        "Submit": "/api/Spaces-1765/interruptions/Interruptions-7104/submit",
        "Responsible": "/api/Spaces-1765/interruptions/Interruptions-7104/responsible"
      }
    }
]
"""

sample_guided_failure = """
[
    {
      "Id": "Interruptions-7105",
      "SpaceId": "Spaces-1765",
      "Title": "Deploy Copilot release 0.0.11 to Development requires failure guidance",
      "Type": "GuidedFailure",
      "Created": "2024-08-12T09:40:33.229+00:00",
      "IsPending": true,
      "Form": {
        "Values": {
          "Instructions": null,
          "Notes": null,
          "Guidance": null
        },
        "Elements": [
          {
            "Name": "Instructions",
            "Control": {
              "Type": "Paragraph",
              "Text": "'Step that will fail (type Run a Script) on DynamicWorker 24-08-11-0600-bi7ri ' in the current task failed. What would you like to do?",
              "ResolveLinks": false
            },
            "IsValueRequired": false
          },
          {
            "Name": "Notes",
            "Control": {
              "Type": "TextArea",
              "Label": "Notes"
            },
            "IsValueRequired": false
          },
          {
            "Name": "Guidance",
            "Control": {
              "Type": "SubmitButtonGroup",
              "Buttons": [
                {
                  "Text": "Fail",
                  "Value": "Fail",
                  "RequiresConfirmation": false
                },
                {
                  "Text": "Retry",
                  "Value": "Retry",
                  "RequiresConfirmation": false
                },
                {
                  "Text": "Ignore",
                  "Value": "Ignore",
                  "RequiresConfirmation": false
                }
              ]
            },
            "IsValueRequired": true
          }
        ]
      },
      "RelatedDocumentIds": [
        "ServerTasks-1023377",
        "Deployments-122622",
        "Projects-4902",
        "Environments-2441"
      ],
      "ResponsibleTeamIds": [],
      "ResponsibleUserId": null,
      "CanTakeResponsibility": true,
      "HasResponsibility": false,
      "TaskId": "ServerTasks-1023377",
      "CorrelationId": "ServerTasks-1023377_KWS2H6YNJR/128698c356834385b81f71214831cea4/ef0309f46f50427eb826f15ed1d02971",
      "IsLinkedToOtherInterruption": false,
      "Links": {
        "Self": "/api/Spaces-1765/interruptions/Interruptions-7105",
        "Submit": "/api/Spaces-1765/interruptions/Interruptions-7105/submit",
        "Responsible": "/api/Spaces-1765/interruptions/Interruptions-7105/responsible"
      }
    }
]
"""

sample_teams = """
[
    {
      "Id": "Teams-781",
      "Name": "Dev Team",
      "MemberUserIds": [
        "Users-884"
      ],
      "ExternalSecurityGroups": [],
      "CanBeDeleted": true,
      "CanBeRenamed": true,
      "CanChangeRoles": true,
      "CanChangeMembers": true,
      "SpaceId": "Spaces-1765",
      "Slug": "dev-team",
      "Description": "",
      "Links": {
        "Self": "/api/teams/Teams-781",
        "ScopedUserRoles": "/api/teams/Teams-781/scopeduserroles{?skip,take}"
      }
    },
    {
      "Id": "Teams-782",
      "Name": "QA Team",
      "MemberUserIds": [
        "Users-885"
      ],
      "ExternalSecurityGroups": [],
      "CanBeDeleted": true,
      "CanBeRenamed": true,
      "CanChangeRoles": true,
      "CanChangeMembers": true,
      "SpaceId": "Spaces-1765",
      "Slug": "qa-team",
      "Description": "",
      "Links": {
        "Self": "/api/teams/Teams-782",
        "ScopedUserRoles": "/api/teams/Teams-782/scopeduserroles{?skip,take}"
      }
    },
    {
      "Id": "teams-spacemanagers-Spaces-1765",
      "Name": "Space Managers",
      "MemberUserIds": [
        "Users-427"
      ],
      "ExternalSecurityGroups": [],
      "CanBeDeleted": false,
      "CanBeRenamed": false,
      "CanChangeRoles": true,
      "CanChangeMembers": true,
      "SpaceId": "Spaces-1765",
      "Slug": "space-managers",
      "Description": "",
      "Links": {
        "Self": "/api/teams/teams-spacemanagers-Spaces-1765",
        "ScopedUserRoles": "/api/teams/teams-spacemanagers-Spaces-1765/scopeduserroles{?skip,take}"
      }
    }
  ]
"""


class ApiKeyTest(unittest.TestCase):
    def test_api_key_validation(self):
        self.assertTrue(is_api_key("API-XXXXXXXXX"))
        self.assertTrue(is_api_key("API-ABCDEFG1234"))
        self.assertFalse(is_api_key("blah"))
        self.assertFalse(is_api_key("javascript:alert('hello')"))
        self.assertFalse(is_api_key(""))
        self.assertFalse(is_api_key("     "))
        self.assertFalse(is_api_key(None))
        self.assertFalse(is_api_key([]))
        self.assertFalse(is_api_key({}))

    def test_interruption_validation_no_interruptions(self):
        valid, error_response = is_manual_intervention_valid(
            space_name="Simple",
            space_id="Spaces-1",
            project_name="Interruption project",
            release_version="0.0.1",
            environment_name="Development",
            tenant_name=None,
            task_id="ServerTasks-12345",
            task_interruptions=None,
            teams=None,
            url="http://localhost:8080/",
            interruption_action="Proceed",
        )

        self.assertFalse(valid)
        self.assertTrue(
            "No interruptions found for:" in error_response,
            "Response was " + error_response,
        )

    def test_interruption_validation_guided_failure_is_invalid(self):
        valid, error_response = is_manual_intervention_valid(
            space_name="Simple",
            space_id="Spaces-1",
            project_name="Interruption project",
            release_version="0.0.1",
            environment_name="Development",
            tenant_name=None,
            task_id="ServerTasks-12345",
            task_interruptions=json.loads(sample_guided_failure),
            teams=None,
            url="http://localhost:8080/",
            interruption_action="Proceed",
        )

        self.assertFalse(valid)
        self.assertTrue(
            "An incompatible interruption (guided failure) was found for:"
            in error_response,
            "Response was " + error_response,
        )

    def test_interruption_validation_another_user_taken_responsibility(self):
        interruptions = json.loads(sample_manual_intervention)
        interruptions[0]["ResponsibleUserId"] = "Users-12345"
        interruptions[0]["HasTakenResponsibility"] = False
        valid, error_response = is_manual_intervention_valid(
            space_name="Simple",
            space_id="Spaces-1",
            project_name="Interruption project",
            release_version="0.0.1",
            environment_name="Development",
            tenant_name=None,
            task_id="ServerTasks-12345",
            task_interruptions=interruptions,
            teams=None,
            url="http://localhost:8080/",
            interruption_action="Proceed",
        )

        self.assertFalse(valid)
        self.assertTrue(
            "Another user has already taken responsibility of the manual intervention for:"
            in error_response,
            "Response was " + error_response,
        )

    def test_interruption_validation_user_cant_take_responsibility(self):
        interruptions = json.loads(sample_manual_intervention)
        interruptions[0]["CanTakeResponsibility"] = False

        valid, error_response = is_manual_intervention_valid(
            space_name="Simple",
            space_id="Spaces-1",
            project_name="Interruption project",
            release_version="0.0.1",
            environment_name="Development",
            tenant_name=None,
            task_id="ServerTasks-12345",
            task_interruptions=interruptions,
            teams=json.loads(sample_teams),
            url="http://localhost:8080/",
            interruption_action="Proceed",
        )

        self.assertFalse(valid)
        self.assertTrue(
            "You don't have sufficient permissions to take responsibility for the manual intervention."
            in error_response,
            "Response was " + error_response,
        )

    def test_is_hosted_octopus(self):
        # Test with valid hosted Octopus URLs
        self.assertTrue(is_hosted_octopus("https://example.octopus.app"))
        self.assertTrue(is_hosted_octopus("https://example.testoctopus.app"))

        # Test with invalid hosted Octopus URLs
        self.assertFalse(is_hosted_octopus("https://example.com"))
        self.assertFalse(is_hosted_octopus("https://octopus.app"))
        self.assertFalse(is_hosted_octopus(""))

        # Test with None
        self.assertFalse(is_hosted_octopus(None))
