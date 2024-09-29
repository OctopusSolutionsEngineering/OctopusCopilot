import json
import unittest

from domain.view.markdown.markdown_dashboards import get_runbook_dashboard_response

sample_json = """{
  "Environments": [
    {
      "Id": "Environments-3121",
      "Name": "Administration"
    },
    {
      "Id": "Environments-3126",
      "Name": "Development"
    },
    {
      "Id": "Environments-3123",
      "Name": "Feature Branch"
    },
    {
      "Id": "Environments-3127",
      "Name": "Test"
    },
    {
      "Id": "Environments-3122",
      "Name": "Production"
    },
    {
      "Id": "Environments-3124",
      "Name": "Security"
    },
    {
      "Id": "Environments-3125",
      "Name": "Sync"
    }
  ],
  "RunbookRuns": {
    "Environments-3125": [
      {
        "Id": "RunbookRuns-53364",
        "ProjectId": "Projects-6035",
        "EnvironmentId": "Environments-3125",
        "RunbookSnapshotId": "RunbookSnapshots-4381",
        "RunbookSnapshotName": "Snapshot WQJFPK4",
        "RunbookSnapshotNotes": null,
        "RunBy": "matthew.casperson@octopus.com",
        "RunbookId": "Runbooks-4745",
        "TaskId": "ServerTasks-915266",
        "TenantId": "Tenants-841",
        "Created": "2024-06-06T00:30:58.602+00:00",
        "QueueTime": "2024-06-06T00:30:58.526+00:00",
        "StartTime": "2024-06-06T00:30:59.916+00:00",
        "CompletedTime": null,
        "State": "Executing",
        "HasPendingInterruptions": false,
        "HasWarningsOrErrors": false,
        "ErrorMessage": "",
        "Duration": "7 seconds",
        "IsCompleted": false,
        "Links": {
          "Self": "/api/Spaces-2408/runbookRuns/RunbookRuns-53364",
          "RunbookSnapshot": "/api/Spaces-2408/runbookSnapshots/RunbookSnapshots-4381",
          "Tenant": "/api/Spaces-2408/tenants/Tenants-841",
          "Task": "/api/tasks/ServerTasks-915266"
        }
      },
      {
        "Id": "RunbookRuns-53322",
        "ProjectId": "Projects-6035",
        "EnvironmentId": "Environments-3125",
        "RunbookSnapshotId": "RunbookSnapshots-4361",
        "RunbookSnapshotName": "Snapshot U7YBY6H",
        "RunbookSnapshotNotes": null,
        "RunBy": "matthew.casperson@octopus.com",
        "RunbookId": "Runbooks-4745",
        "TaskId": "ServerTasks-911580",
        "TenantId": "Tenants-781",
        "Created": "2024-06-05T04:48:52.059+00:00",
        "QueueTime": "2024-06-05T04:48:51.977+00:00",
        "StartTime": "2024-06-05T04:48:53.238+00:00",
        "CompletedTime": "2024-06-05T04:49:32.853+00:00",
        "State": "Success",
        "HasPendingInterruptions": false,
        "HasWarningsOrErrors": true,
        "ErrorMessage": "",
        "Duration": "41 seconds",
        "IsCompleted": true,
        "Links": {
          "Self": "/api/Spaces-2408/runbookRuns/RunbookRuns-53322",
          "RunbookSnapshot": "/api/Spaces-2408/runbookSnapshots/RunbookSnapshots-4361",
          "Tenant": "/api/Spaces-2408/tenants/Tenants-781",
          "Task": "/api/tasks/ServerTasks-911580"
        }
      }
    ]
  },
  "Links": {}
}"""


class RunbookDashboardTest(unittest.TestCase):
    def test_get_runbook_dashboard_response(self):
        result = get_runbook_dashboard_response(
            {"Name": "Project"},
            {"Name": "Runbook"},
            json.loads(sample_json),
            [],
            lambda x: x,
        )
        print(result)
        self.assertTrue("🟡" in result, result)
