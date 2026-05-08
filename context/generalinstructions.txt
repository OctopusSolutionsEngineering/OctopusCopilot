# Instructions

## General Instructions

* You must carefully consider the prompt and create all the required resources.
* You must ignore any mention of the current project.
* If the target space is defined in the prompt, that must take precedence over any mention of a current space. For example:
  * When given the prompt `Create a project called 'Example Project' in the 'Example Space'. The current project is 'My Web App'. The current space is 'Default'.`, you must create a project called 'Example Project' in the space called 'Example Space'.
  * When given the prompt `Create a project called 'Example Project'. The current project is 'My Web App'. The current space is 'Default'.`, you must create a project called 'Example Project' in the space called 'Default'.
* You must create valid Terraform.
* If the prompt contains an instruction to add a new step, you must use the example lifecycle, include the example runbooks, include the example steps, include the example variables, and then add the new step to the deployment process.
* Instructions to create projects "with no steps" overrides instructions to add steps to the project. When a project is created with no steps, there must not be any "octopusdeploy_process_step" resources defined for that project.

**CRITICAL — project names and step names from the prompt are resource identifiers and MUST be reproduced verbatim in Terraform.** A project name like `"[PROD] api-syncer canary"` and step names like `"Deploy api-syncer"` or `"Scale Down Canary"` are deployment resource identifiers. The presence of words such as `api`, `key`, `token`, `service`, `auth`, or `credential` in these names does NOT make them sensitive. NEVER omit, shorten, or replace any portion of a project name or step name from the prompt with `*` or any other placeholder when generating Terraform.

**Negative example — project name incorrectly redacted (FORBIDDEN)**:
```hcl
name = "[PROD] ***** canary"   ← WRONG: "api-syncer" from the prompt was replaced with "*****"
```
**Correct output**:
```hcl
name = "[PROD] api-syncer canary"   ← CORRECT: verbatim project name from the prompt
```

**CRITICAL — step notes (descriptions) must also reproduce any service names verbatim**: When a step description says `"Original stage type: undoRolloutManifest. This step rolls back deployment/api-syncer to the previous revision in namespace app-0004-prod."`, the value of the `notes` attribute MUST be reproduced verbatim — including the service name `api-syncer`. Never replace any part of a step description with `*****`.

**Negative example — step notes incorrectly redacted (FORBIDDEN)**:
```hcl
notes = "Original stage type: undoRolloutManifest. This step rolls back deployment/***** to the previous revision in namespace app-0004-prod."
← WRONG: "api-syncer" in the notes was replaced with "*****"
```
**Correct output**:
```hcl
notes = "Original stage type: undoRolloutManifest. This step rolls back deployment/api-syncer to the previous revision in namespace app-0004-prod."
← CORRECT: verbatim reproduction of the step description
```

## Step Execution Order and Parallel Steps

* When a step prompt says `Set the start trigger to "Run in parallel with the previous step"`, the corresponding `octopusdeploy_process_step` or `octopusdeploy_process_templated_step` resource MUST have `start_trigger = "StartWithPrevious"`.
* When a step prompt says `Set the start trigger to "Wait for all previous steps to complete, then start"`, the resource MUST have `start_trigger = "StartAfterPrevious"`.
* Steps with no start trigger annotation default to `start_trigger = "StartAfterPrevious"`.
* If the prompt says `The step must be disabled.`, you must still keep that step in the `octopusdeploy_process_steps_order` resource and preserve any explicit `start_trigger` annotation from the prompt. Disabled steps still participate in process ordering.
* You will be penalized for using `start_trigger = "StartAfterPrevious"` when the prompt explicitly says `"Run in parallel with the previous step"`.
* You will be penalized for using `start_trigger = "StartWithPrevious"` when the prompt explicitly says `"Wait for all previous steps to complete, then start"` or when no start trigger annotation is given.
* **MANDATORY SELF-CHECK — parallel group completeness**: Before finalizing generated Terraform, scan every step prompt for the phrase `"Run in parallel with the previous step"`. For EACH such step, verify that the corresponding `octopusdeploy_process_step` or `octopusdeploy_process_templated_step` uses `start_trigger = "StartWithPrevious"`. If any step with that phrase uses `start_trigger = "StartAfterPrevious"`, correct it before outputting. **This check applies to ALL steps in the parallel group including the LAST one** — the last member of a parallel group is NOT a convergence point and MUST use `start_trigger = "StartWithPrevious"`, not `"StartAfterPrevious"`. Only the step AFTER the entire parallel group (annotated with "Wait for all previous steps") is a convergence point.

  **CRITICAL — the SECOND step in a parallel group is the most commonly broken**: When a prompt includes a large parallel group (e.g., 8 steps all with "Run in parallel with the previous step"), the SECOND step — the first one to receive the parallel annotation — is where the `StartAfterPrevious` mistake is most often made. Before finalizing, explicitly check the resource for the SECOND parallel step and confirm it uses `start_trigger = "StartWithPrevious"`, not `"StartAfterPrevious"`.

  **CRITICAL — the bug can occur at ANY position in a large parallel group, not just the second step**: After fixing the second step, do NOT assume all remaining parallel steps are correct. The `StartAfterPrevious` mistake can occur at any index in a large parallel group (third, fourth, etc.). The self-check must examine EVERY step annotated with "Run in parallel with the previous step" — not just the second one.

  **Negative example — SECOND step in large parallel group incorrectly using StartAfterPrevious (VERY COMMON MISTAKE)**:

  Given that the prompt says:
  ```
  * Add a "Deploy Kubernetes YAML" step ... "Deploy Service-A" ...    (no annotation — first in parallel group)
  * Add a "Deploy Kubernetes YAML" step ... "Deploy Service-B" ... Set the start trigger to "Run in parallel with the previous step".   ← SECOND step in group
  * Add a "Deploy Kubernetes YAML" step ... "Deploy Service-C" ... Set the start trigger to "Run in parallel with the previous step".
  * Add a "Deploy Kubernetes YAML" step ... "Deploy Service-D" ... Set the start trigger to "Run in parallel with the previous step".
  ```

  The **WRONG** Terraform (Deploy Service-B uses StartAfterPrevious — FORBIDDEN):
  ```hcl
  resource "octopusdeploy_process_step" "process_step_deploy_service_a" {
    start_trigger = "StartAfterPrevious"  ← correct (first in group, no annotation)
  }
  resource "octopusdeploy_process_step" "process_step_deploy_service_b" {
    start_trigger = "StartAfterPrevious"  ← WRONG: prompt says "Run in parallel with the previous step"
  }
  resource "octopusdeploy_process_step" "process_step_deploy_service_c" {
    start_trigger = "StartWithPrevious"  ← correct
  }
  resource "octopusdeploy_process_step" "process_step_deploy_service_d" {
    start_trigger = "StartWithPrevious"  ← correct
  }
  ```

  The **CORRECT** Terraform (ALL steps after the first use StartWithPrevious):
  ```hcl
  resource "octopusdeploy_process_step" "process_step_deploy_service_a" {
    start_trigger = "StartAfterPrevious"  ← first in group
  }
  resource "octopusdeploy_process_step" "process_step_deploy_service_b" {
    start_trigger = "StartWithPrevious"  ← CORRECT: second step MUST use StartWithPrevious
  }
  resource "octopusdeploy_process_step" "process_step_deploy_service_c" {
    start_trigger = "StartWithPrevious"  ← correct
  }
  resource "octopusdeploy_process_step" "process_step_deploy_service_d" {
    start_trigger = "StartWithPrevious"  ← correct
  }
  ```
* **MANDATORY SELF-CHECK — convergence step completeness**: Before finalizing generated Terraform, scan every step prompt for the phrase `"Wait for all previous steps to complete, then start"`. For EACH such step, verify that the corresponding resource uses `start_trigger = "StartAfterPrevious"`. If any step with that phrase uses `start_trigger = "StartWithPrevious"`, correct it before outputting.

**CRITICAL — convergence steps (after a parallel group) MUST use `start_trigger = "StartAfterPrevious"`**: When the prompt says `Set the start trigger to "Wait for all previous steps to complete, then start"`, this indicates a convergence point — a step that waits for multiple preceding parallel steps to finish before it begins. In Octopus Terraform, this is expressed as `start_trigger = "StartAfterPrevious"`. This is the SAME attribute value as the default, but it MUST be explicitly set when the prompt says "Wait for all previous steps". The `StartAfterPrevious` value is used for two distinct cases:
1. Sequential steps (default, no annotation needed)
2. Convergence steps (explicitly annotated in prompt — MUST be set even though value matches default)

**Negative example — convergence step after a parallel group incorrectly using StartWithPrevious**:

Given that the prompt says:
```
* Add a "Deploy Kubernetes YAML" step ... "Deploy Dev" ...         (no annotation — first in root group)
* Add a "Deploy Kubernetes YAML" step ... "Deploy Staging" ... Set the start trigger to "Run in parallel with the previous step".
* Add a "Manual Intervention" step ... "Manual Judgment" ... Set the start trigger to "Wait for all previous steps to complete, then start".
```

The **WRONG** Terraform (Manual Judgment uses StartWithPrevious — FORBIDDEN at a convergence point):
```hcl
resource "octopusdeploy_process_step" "... deploy_staging" {
  start_trigger = "StartWithPrevious"  ← correct
  ...
}
resource "octopusdeploy_process_step" "... manual_judgment" {
  start_trigger = "StartWithPrevious"  ← WRONG: convergence point must use StartAfterPrevious
  ...
}
```

The **CORRECT** Terraform (Manual Judgment uses StartAfterPrevious as a convergence point):
```hcl
resource "octopusdeploy_process_step" "... deploy_staging" {
  start_trigger = "StartWithPrevious"  ← CORRECT: parallel
  ...
}
resource "octopusdeploy_process_step" "... manual_judgment" {
  start_trigger = "StartAfterPrevious"  ← CORRECT: convergence — waits for all parallel steps
  ...
}
```

**CRITICAL — a step with BOTH `is_disabled = true` AND `start_trigger = "StartWithPrevious"` is VALID and REQUIRED when a disabled stage is a parallel group member**: When the prompt says `The step must be disabled. Set the start trigger to "Run in parallel with the previous step"`, the corresponding Terraform resource MUST have both attributes set. Setting `is_disabled = true` does NOT override or cancel the `start_trigger` annotation.

**Negative example — disabled parallel step incorrectly using StartAfterPrevious (COMMON MISTAKE)**:

Given that the prompt says:
```
* Add a "Deploy Kubernetes YAML" step ... "Deploy Dev" ...
* Add a "Deploy Kubernetes YAML" step ... "Deploy Staging" ... The step must be disabled. Set the start trigger to "Run in parallel with the previous step".
```

The **WRONG** Terraform (Deploy Staging uses StartAfterPrevious — FORBIDDEN when prompt says parallel):
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_staging" {
  name          = "Deploy Staging"
  is_disabled   = true
  start_trigger = "StartAfterPrevious"  ← WRONG: prompt says "Run in parallel with the previous step"
  ...
}
```

The **CORRECT** Terraform (disabled step still uses StartWithPrevious):
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_staging" {
  name          = "Deploy Staging"
  is_disabled   = true
  start_trigger = "StartWithPrevious"  ← CORRECT: disabled + parallel are independent attributes
  ...
}
```

**CRITICAL — the `start_trigger` on the FIRST step in a project is always `"StartAfterPrevious"`**: The first step in `octopusdeploy_process_steps_order` always uses `start_trigger = "StartAfterPrevious"` (or the equivalent default). For the first step, `"StartAfterPrevious"` means "start immediately" since there are no previous steps. This is correct behavior and must NOT be changed to `"StartWithPrevious"`.

**CRITICAL — steps that appear CONSECUTIVE in the `octopusdeploy_process_steps_order` list and should run in parallel MUST use `start_trigger = "StartWithPrevious"` for the SECOND and subsequent steps in the parallel group.** If the prompt says `Set the start trigger to "Run in parallel with the previous step"` for a step, you must set `start_trigger = "StartWithPrevious"` — even if the step appears AFTER a step that itself uses `"StartAfterPrevious"`. The `start_trigger` on each step is evaluated independently: it controls how THAT step starts relative to the step immediately before it in the ordered list.

**Negative example — consecutive parallel step incorrectly using StartAfterPrevious (COMMON MISTAKE)**:

Given that the prompt says:
```
* Add a "Deploy Kubernetes YAML" step ... "Deploy -canary-" ... Set the start trigger to "Wait for all previous steps to complete, then start".
* Add a "Run a kubectl script" step ... "Rollback -internal-" ... Set the start trigger to "Run in parallel with the previous step".
```

The **WRONG** Terraform (Rollback step uses StartAfterPrevious — FORBIDDEN when prompt says parallel):
```hcl
resource "octopusdeploy_process_step" "... deploy_canary" {
  start_trigger = "StartAfterPrevious"
  ...
}
resource "octopusdeploy_process_step" "... rollback_internal" {
  start_trigger = "StartAfterPrevious"  ← WRONG: prompt says "Run in parallel with the previous step"
  ...
}
```

The **CORRECT** Terraform (Rollback step uses StartWithPrevious as instructed):
```hcl
resource "octopusdeploy_process_step" "... deploy_canary" {
  start_trigger = "StartAfterPrevious"
  ...
}
resource "octopusdeploy_process_step" "... rollback_internal" {
  start_trigger = "StartWithPrevious"  ← CORRECT: matches "Run in parallel with the previous step"
  ...
}
```

**CRITICAL — in a 3-or-more-step parallel group, ALL steps after the first MUST use `start_trigger = "StartWithPrevious"`**: When three or more consecutive steps all have `Set the start trigger to "Run in parallel with the previous step"` (or the second and subsequent steps in a group do), every step except the first MUST use `StartWithPrevious`. The last step in the group is NOT a convergence point — it is still part of the parallel group. Only the step AFTER the entire group (the one with "Wait for all previous steps") is the convergence point.

**Negative example — 3-step parallel group where the LAST parallel step incorrectly uses StartAfterPrevious (COMMON MISTAKE)**:

Given that the prompt says:
```
* Add a "Deploy Kubernetes YAML" step ... "Deploy -main-" ... Set the start trigger to "Wait for all previous steps to complete, then start".
* Add a "Run a kubectl script" step ... "Rollback -internal-" ... Set the start trigger to "Run in parallel with the previous step".
* Add a "Run a kubectl script" step ... "Rollback -canary-" ... Set the start trigger to "Run in parallel with the previous step".
```

The **WRONG** Terraform (Rollback -canary- uses StartAfterPrevious — FORBIDDEN):
```hcl
resource "octopusdeploy_process_step" "... deploy_main" {
  start_trigger = "StartAfterPrevious"  ← correct (first in parallel group)
}
resource "octopusdeploy_process_step" "... rollback_internal" {
  start_trigger = "StartWithPrevious"  ← correct
}
resource "octopusdeploy_process_step" "... rollback_canary" {
  start_trigger = "StartAfterPrevious"  ← WRONG: "Run in parallel" means StartWithPrevious, NOT StartAfterPrevious
}
```

The **CORRECT** Terraform (all parallel steps except the first use StartWithPrevious):
```hcl
resource "octopusdeploy_process_step" "... deploy_main" {
  start_trigger = "StartAfterPrevious"  ← first in group
}
resource "octopusdeploy_process_step" "... rollback_internal" {
  start_trigger = "StartWithPrevious"  ← CORRECT
}
resource "octopusdeploy_process_step" "... rollback_canary" {
  start_trigger = "StartWithPrevious"  ← CORRECT: LAST parallel step still uses StartWithPrevious
}
```

**MANDATORY SELF-CHECK — parallel step count verification**: Before finalizing generated Terraform, count the number of step prompts annotated with `"Run in parallel with the previous step"`. This count MUST equal the number of `octopusdeploy_process_step` resources with `start_trigger = "StartWithPrevious"`. If these counts do not match, find and fix the discrepancy before outputting. A count mismatch always indicates that one or more parallel steps incorrectly use `start_trigger = "StartAfterPrevious"`.

**MANDATORY SELF-CHECK — sequential step after parallel group**: When a prompt contains a step annotated with `"Wait for all previous steps to complete, then start"` immediately following a parallel group (one or more steps with `"Run in parallel with the previous step"`), verify that step uses `start_trigger = "StartAfterPrevious"`. This is the default, but the self-check ensures it was not accidentally set to `"StartWithPrevious"` by a copy-paste error.

## Inline Kubernetes YAML Indentation

* When setting `Octopus.Action.KubernetesContainers.CustomResourceYaml` in `execution_properties`, the YAML value MUST use proper 2-space indentation at every level. Flat YAML (where all keys appear at column 0) is invalid and will cause deployment failures.
* For example, a Deployment manifest must nest `metadata.name` at 2 spaces, `spec.template` at 4 spaces, and container entries at 8 spaces.
* ConfigMap-style maps must also remain nested. Keys under `data:` or `stringData:` must be indented two spaces beneath those parent keys; they must never be emitted at column 0.
* YAML lists must also preserve indentation. Under keys like `containers`, `env`, `envFrom`, `volumeMounts`, `ports`, `args`, and `imagePullSecrets`, the `-` list marker must be indented beneath its parent key and the child fields beneath the list item must be indented two spaces deeper than the dash.
* Multi-document YAML must preserve both separators and indentation. A document separator line containing exactly `---` must be followed by a new top-level document starting again at column 0, while nested keys in that document remain indented.
* If you cannot serialize cached manifest YAML with both correct indentation and verbatim values, you must fall back to a TODO placeholder instead of emitting malformed or partially redacted YAML.
* You will be penalized for producing flat YAML in `Octopus.Action.KubernetesContainers.CustomResourceYaml`.
* **CRITICAL — if the prompt provides YAML that is already flat (all keys at column 0)**, you MUST re-indent it with proper 2-space nesting before embedding it as the value of `Octopus.Action.KubernetesContainers.CustomResourceYaml`. Flat YAML from the prompt is NOT a valid reason to emit flat YAML in Terraform. If you cannot correctly reconstruct the proper indentation from the flat input, use a TODO placeholder comment instead.
* You will be penalized for embedding flat (column-0) YAML into any `execution_properties` value even when the source prompt also showed flat YAML.

**MANDATORY CONTAINERS COLUMN CHECK**: Before finalizing any `Octopus.Action.KubernetesContainers.CustomResourceYaml` value for a Deployment resource, count the leading spaces on the `containers:` key:
- In a standard Deployment (kind: Deployment), `containers:` must be at **6 spaces** (`spec.template.spec.containers` = depth 3, in a `<<-EOT` heredoc where each line has 2 extra spaces from the heredoc indent, the actual Kubernetes indent is 4 spaces but Terraform adds 2 leading spaces making it `      containers:`)
- **The simplest check**: does the `containers:` line start at column 0 (no leading spaces)? If YES, the YAML is FLAT and WRONG. You MUST re-indent or replace with a TODO placeholder.
- A `containers:` line at column 0 indicates that the entire pod-spec is flat. This is always wrong for a Deployment and must be corrected before outputting.
- If you cannot correctly re-indent a flat Deployment+HPA or any multi-document manifest, replace it with `# TODO: replace with correctly indented manifest` and set `is_disabled = true` on the step.

**CRITICAL — flat YAML re-indentation algorithm**: When the prompt provides flat YAML and you must reconstruct the correct indentation, use the following depth-tracking approach:
1. Parse the flat keys by their Kubernetes schema knowledge. For a Deployment, `apiVersion`, `kind`, `metadata`, `spec` are at depth 0 (column 0). Keys inside `metadata` (`name`, `namespace`, `labels`, `annotations`) are at depth 1 (2 spaces). Keys inside `spec` are at depth 1 (2 spaces), unless they are inside `template` (depth 2, 4 spaces) or deeper.
2. For lists (`containers`, `env`, `envFrom`, `volumeMounts`, `imagePullSecrets`, `ports`, `tolerations`, `volumes`), the list key itself is at its schema depth, the `-` marker appears at the same column as the list key, and the child fields of each list item appear at 2 spaces deeper than the `-`.
3. Always verify: does each key appear at a deeper column than its parent key? If not, it is wrong.

**Extended Deployment YAML depth table** (including complex pod-spec fields):
* `apiVersion`, `kind`, `metadata`, `spec` → depth 0, column 0
* `metadata.name`, `metadata.namespace`, `metadata.labels` → depth 1, 2 spaces
* `spec.replicas`, `spec.selector`, `spec.template` → depth 1, 2 spaces
* `spec.template.metadata`, `spec.template.spec` → depth 2, 4 spaces
* `spec.template.spec.containers` (list key) → depth 3, 6 spaces
* `spec.template.spec.containers[-]` (dash) → depth 3, 6 spaces
* `spec.template.spec.containers[0].name`, `.image`, `.env`, `.envFrom`, `.volumeMounts`, `.resources`, `.ports`, `.livenessProbe`, `.readinessProbe` → depth 4, 8 spaces
* `spec.template.spec.containers[0].env[-]` (dash) → depth 4, 8 spaces
* `spec.template.spec.containers[0].env[0].name`, `.value` → depth 5, 10 spaces
* `spec.template.spec.containers[0].envFrom[-]` (dash) → depth 4, 8 spaces
* `spec.template.spec.containers[0].envFrom[0].secretRef`, `.configMapRef` → depth 5, 10 spaces
* `spec.template.spec.containers[0].envFrom[0].secretRef.name` → depth 6, 12 spaces
* `spec.template.spec.containers[0].volumeMounts[-]` (dash) → depth 4, 8 spaces
* `spec.template.spec.containers[0].volumeMounts[0].name`, `.mountPath`, `.subPath` → depth 5, 10 spaces
* `spec.template.spec.tolerations` (list key) → depth 3, 6 spaces
* `spec.template.spec.tolerations[-]` (dash) → depth 3, 6 spaces
* `spec.template.spec.tolerations[0].key`, `.operator`, `.effect`, `.tolerationSeconds` → depth 4, 8 spaces
* `spec.template.spec.nodeSelector` → depth 3, 6 spaces
* `spec.template.spec.nodeSelector.cloud.google.com/gke-nodepool` → depth 4, 8 spaces
* `spec.template.spec.imagePullSecrets` (list key) → depth 3, 6 spaces
* `spec.template.spec.imagePullSecrets[-]` (dash) → depth 3, 6 spaces
* `spec.template.spec.imagePullSecrets[0].name` → depth 4, 8 spaces
* `spec.template.spec.volumes` (list key) → depth 3, 6 spaces
* `spec.template.spec.volumes[-]` (dash) → depth 3, 6 spaces
* `spec.template.spec.volumes[0].name`, `.secret`, `.configMap` → depth 4, 8 spaces
* `spec.template.spec.volumes[0].secret.secretName` → depth 5, 10 spaces

**Example — reconstructing a flat Deployment with tolerations, nodeSelector, and imagePullSecrets**:

If the prompt says (flat YAML from conversion step):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
name: worker
namespace: app-0117-dev
spec:
replicas: 2
template:
spec:
containers:
- name: worker
image: registry.example.invalid/image-0250
envFrom:
- secretRef:
name: worker-secrets
resources:
requests:
cpu: "100m"
memory: "128Mi"
limits:
cpu: "500m"
memory: "512Mi"
volumeMounts:
- name: config-volume
mountPath: /config
tolerations:
- key: dedicated
operator: Equal
value: worker
effect: NoSchedule
nodeSelector:
cloud.google.com/gke-nodepool: worker-pool
imagePullSecrets:
- name: registry-creds
volumes:
- name: config-volume
configMap:
name: worker-config
```

The **CORRECT** Terraform value re-indents each key based on schema depth:
```hcl
"Octopus.Action.KubernetesContainers.CustomResourceYaml" = <<-EOT
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: worker
    namespace: app-0117-dev
  spec:
    replicas: 2
    template:
      spec:
        containers:
          - name: worker
            image: registry.example.invalid/image-0250
            envFrom:
              - secretRef:
                  name: worker-secrets
            resources:
              requests:
                cpu: "100m"
                memory: "128Mi"
              limits:
                cpu: "500m"
                memory: "512Mi"
            volumeMounts:
              - name: config-volume
                mountPath: /config
        tolerations:
          - key: dedicated
            operator: Equal
            value: worker
            effect: NoSchedule
        nodeSelector:
          cloud.google.com/gke-nodepool: worker-pool
        imagePullSecrets:
          - name: registry-creds
        volumes:
          - name: config-volume
            configMap:
              name: worker-config
  EOT
```

Note: `tolerations`, `nodeSelector`, `imagePullSecrets`, and `volumes` are direct children of `spec.template.spec`, NOT of the container. They sit at depth 3 (6 spaces) alongside `containers`.

**CronJob YAML re-indentation**: CronJob has an extra `jobTemplate` nesting level compared to Deployment. The key depths are:
* `apiVersion`, `kind`, `metadata`, `spec` → depth 0, column 0
* `spec.schedule`, `spec.concurrencyPolicy`, `spec.successfulJobsHistoryLimit` etc. → depth 1, 2 spaces
* `spec.jobTemplate` → depth 1, 2 spaces
* `spec.jobTemplate.spec` → depth 2, 4 spaces
* `spec.jobTemplate.spec.template` → depth 3, 6 spaces
* `spec.jobTemplate.spec.template.spec` → depth 4, 8 spaces
* `spec.jobTemplate.spec.template.spec.containers` → depth 5, 10 spaces (list key)
* `spec.jobTemplate.spec.template.spec.containers[-]` (dash) → depth 5, 10 spaces
* `spec.jobTemplate.spec.template.spec.containers[0].name` → depth 6, 12 spaces
* `spec.jobTemplate.spec.template.spec.containers[0].env` → depth 6, 12 spaces
* `spec.jobTemplate.spec.template.spec.containers[0].env[-]` (dash) → depth 6, 12 spaces
* `spec.jobTemplate.spec.template.spec.containers[0].env[0].name` → depth 7, 14 spaces

**Example — reconstructing a flat CronJob from the prompt into correct Terraform YAML**:

If the prompt says (flat YAML from conversion step):
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
name: my-cronjob
namespace: app-prod
spec:
schedule: "0 2 * * *"
jobTemplate:
spec:
template:
spec:
containers:
- name: my-task
image: gcr.io/my-org/my-task:latest
env:
- name: ENV_VAR
value: "production"
restartPolicy: Never
```

The **CORRECT** Terraform value re-indents each key based on CronJob schema depth:
```hcl
"Octopus.Action.KubernetesContainers.CustomResourceYaml" = <<-EOT
  apiVersion: batch/v1
  kind: CronJob
  metadata:
    name: my-cronjob
    namespace: app-prod
  spec:
    schedule: "0 2 * * *"
    jobTemplate:
      spec:
        template:
          spec:
            containers:
              - name: my-task
                image: gcr.io/my-org/my-task:latest
                env:
                  - name: ENV_VAR
                    value: "production"
            restartPolicy: Never
  EOT
```

**Example — reconstructing a flat Deployment + HPA multi-document from the prompt into correct Terraform YAML**:

If the prompt says (flat YAML from conversion step):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
name: gateway
namespace: app-0126-dev
spec:
replicas: 2
template:
spec:
containers:
- name: gateway
image: registry.example.invalid/image-0200
envFrom:
- secretRef:
name: double-api-token
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
name: gateway-hpa
spec:
maxReplicas: 4
minReplicas: 2
```

The **CORRECT** Terraform value re-indents each document based on schema depth:
```hcl
"Octopus.Action.KubernetesContainers.CustomResourceYaml" = <<-EOT
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: gateway
    namespace: app-0126-dev
  spec:
    replicas: 2
    template:
      spec:
        containers:
          - name: gateway
            image: registry.example.invalid/image-0200
            envFrom:
              - secretRef:
                  name: double-api-token
  ---
  apiVersion: autoscaling/v2
  kind: HorizontalPodAutoscaler
  metadata:
    name: gateway-hpa
  spec:
    maxReplicas: 4
    minReplicas: 2
  EOT
```

## Step Name Character Rules

* Octopus Deploy step names may only contain letters, numbers, periods, commas, dashes, underscores, and hashes. Parentheses `()` and square brackets `[]` are NOT valid in step names.
* If the prompt contains a step name with parentheses or square brackets that were replaced by dashes (e.g., `Deploy -Manifest-`), use the dash-replaced form exactly as written in the prompt. Do NOT re-introduce parentheses or other special characters.
* Do NOT normalize prompt-provided dash replacements into underscores. For example, `Manual Judgment -Canary-` must stay `Manual Judgment -Canary-`, never `Manual Judgment _Canary_`.
* You will be penalized for creating steps with parentheses or square brackets in their names.

## Step Description Property

* When the prompt says `Set the step description to "..."`, the description must be set as the top-level `notes` attribute on the `octopusdeploy_process_step` resource, NOT inside the `execution_properties` map.
* When the prompt says `Set the step description to include: "..."` or otherwise instructs you to append text to an existing step description, you must build a SINGLE final description string in prompt order and store that combined value in `notes`. Do not emit multiple competing description properties.
* If a step receives more than one description fragment in the prompt, concatenate them with a single space between fragments unless the prompt explicitly specifies different punctuation.
* The description value must be the exact verbatim string from the prompt, including any quoted sub-strings.
* You will be penalized for omitting a step description when the prompt explicitly instructs it to be set.
* You will be penalized for placing the `notes` attribute inside `execution_properties` — `notes` is a top-level attribute of the `octopusdeploy_process_step` resource.
* **CRITICAL — never add backslash-escaping to GCS paths or other URLs in step descriptions.** When a step description contains a GCS path like `gs://example-bucket/path/to/file.yaml`, reproduce it verbatim in the `notes` string without adding backslashes or extra quotation marks around the URL. For example, `notes = "This step originally loaded its manifest from Google Cloud Storage at gs://example-bucket/path. The manifest must be inlined or reconfigured."` — NOT `notes = "... at \"gs://example-bucket/path\"."`.
* **CRITICAL — `NOTE (migration):` text must be preserved verbatim**: When a step description includes text of the form `NOTE (migration): ...`, this text MUST appear verbatim in the `notes` attribute. Do NOT drop, summarize, or rephrase migration notes. These notes communicate important information about conditional branching or preconditions that were lost during migration. For example, if the prompt says `Set the step description to "...; NOTE (migration): This step was originally on the SUCCESS branch after \"Manual Judgment\". In this migration, both branches now run in parallel."`, the `notes` value MUST include the full NOTE (migration) sentence.
* **CRITICAL — `NOTE (migration):` text for rollback/rejection branches must be preserved verbatim**: When a prompt description for an `undoRolloutManifest` step includes `NOTE (migration): This step was originally on the rollback/rejection branch of a pipeline. In this migration it runs in parallel with the deploy step — configure this step to run only when the deploy step is not needed, or disable it and trigger rollbacks manually.`, this ENTIRE sentence MUST appear verbatim in the `notes` attribute. Do NOT drop this note, do NOT shorten it, and do NOT replace it with a generic migration note. This note is critical for engineers to understand that a rollback step running in parallel with a deploy step was originally a conditional branch that only ran on the NO/rejection path of a manual judgment.
* **IMPORTANT — `NOTE (migration): ... timeout ...` text from `stageTimeoutMs` must be preserved verbatim**: When a `manualJudgment` stage had a `stageTimeoutMs` property, the converted prompt will include a sentence like `NOTE (migration): The original stage had a timeout of 30 minutes (stageTimeoutMs: 1800000). Configure a Manual Intervention timeout in Octopus if required.` in the step description. This text MUST appear verbatim in the `notes` attribute of the corresponding `octopusdeploy_process_step` resource. Do NOT omit or shorten the timeout note.

* **IMPORTANT — `NOTE (migration): ... timeout ...` text from `stageTimeoutMs` on non-`manualJudgment` stages must also be preserved verbatim**: When any non-`manualJudgment` stage (e.g., `deployManifest`, `runJobManifest`) had a `stageTimeoutMs` property, the converted prompt will include a sentence like `NOTE (migration): The original stage had a timeout of <N> minutes (stageTimeoutMs: <value>). Configure a step timeout in Octopus if required.` in the step description. This text MUST appear verbatim in the `notes` attribute. Never omit or shorten this migration note even for non-manualJudgment steps.
**Negative example — GCS URL with incorrect backslash escaping in notes (FORBIDDEN)**:
```hcl
notes = "This step originally loaded its manifest from Google Cloud Storage at \"gs://example-bucket/storage-3209\". The manifest must be inlined."
                                                                            ^WRONG: backslash-escaped quotes added around the GCS URL
```
**Correct output**:
```hcl
notes = "This step originally loaded its manifest from Google Cloud Storage at gs://example-bucket/storage-3209. The manifest must be inlined."
```

**Example — correct placement of `notes` attribute**:

```hcl
resource "octopusdeploy_process_step" "process_step_deploy_staging" {
  name                  = "Deploy Staging"
  notes                 = "This step originally loaded its manifest from Google Cloud Storage at gs://example-bucket/path. The manifest must be inlined or reconfigured."
  is_disabled           = true
  execution_properties  = {
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "# TODO: ..."
    "Octopus.Action.Script.ScriptSource"                     = "Inline"
  }
}
```

**WRONG — `notes` inside `execution_properties` (FORBIDDEN)**:

```hcl
resource "octopusdeploy_process_step" "process_step_deploy_staging" {
  name                  = "Deploy Staging"
  execution_properties  = {
    "notes"                                                  = "This step originally..."  # WRONG
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "# TODO: ..."
  }
}
```

## Wait Steps (Script Steps with Start-Sleep)

* A `wait` stage converted to `Start-Sleep -Seconds <N>` must be implemented as an `octopusdeploy_process_step` of type `"Octopus.Script"` with `execution_properties` containing `"Octopus.Action.Script.ScriptBody" = "Start-Sleep -Seconds <N>"`, `"Octopus.Action.Script.Syntax" = "PowerShell"`, and `"Octopus.Action.Script.ScriptSource" = "Inline"`.
* The step name must match the dash-replaced form from the prompt (e.g., `"Wait -15min-"`) — parentheses in the original stage name have been replaced with dashes.
* You will be penalized for using a type other than `"Octopus.Script"` for wait steps.

## "Review Template-Derived Pipeline Behavior" Script Step

* When the prompt includes `Add a "Run a Script" step with the name "Review template-derived pipeline behavior"`, create an `octopusdeploy_process_step` resource of type `"Octopus.Script"` with `execution_properties` containing:
  * `"Octopus.Action.Script.ScriptBody"` — the inline PowerShell comment from the prompt (e.g., `# TODO: expand the pipeline template "pipeline://basic-gcs" using the templatedPipeline variables before considering this conversion complete.`)
  * `"Octopus.Action.Script.Syntax" = "PowerShell"`
  * `"Octopus.Action.Script.ScriptSource" = "Inline"`
* This step does NOT require a `properties` block with `Octopus.Action.TargetRoles` — it runs on the server, not on a Kubernetes target.
* This step MUST be the LAST entry in the `octopusdeploy_process_steps_order` `steps` array.

**Example — "Review template-derived pipeline behavior" step in Terraform**:
```hcl
resource "octopusdeploy_process_step" "process_step_review_template_derived_pipeline_behavior" {
  count                = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"
  name                 = "Review template-derived pipeline behavior"
  type                 = "Octopus.Script"
  process_id           = octopusdeploy_process.process_my_project[0].id
  condition            = "Success"
  package_requirement  = "LetOctopusDecide"
  start_trigger        = "StartAfterPrevious"
  execution_properties = {
    "Octopus.Action.RunOnServer"         = "true"
    "Octopus.Action.Script.ScriptSource" = "Inline"
    "Octopus.Action.Script.Syntax"       = "PowerShell"
    "Octopus.Action.Script.ScriptBody"   = "# TODO: expand the pipeline template \"pipeline://basic-gcs\" using the templatedPipeline variables before considering this conversion complete."
  }
}
```

## Multiple Description Fragments in `notes` (CRITICAL)

When a step receives MULTIPLE description fragments from the prompt (e.g., an original stage name plus a stageTimeoutMs migration note), you MUST concatenate ALL fragments into one single `notes` value. Do NOT drop any fragment.

For example, if the prompt says:
```
* Set the step name to "Review -Approval-".
* Set the step description to "Original stage name: Review and Approval."
* Append to the step description: "NOTE (migration): The original stage had a timeout of 30 minutes (stageTimeoutMs: 1800000). Configure a Manual Intervention timeout in Octopus if required."
```

The **WRONG** output includes only the first fragment:
```hcl
resource "octopusdeploy_process_step" "process_step_review_approval" {
  name  = "Review -Approval-"
  notes = "Original stage name: Review and Approval."   # WRONG: second fragment dropped
  ...
}
```

The **CORRECT** output concatenates all fragments in order, separated by a space:
```hcl
resource "octopusdeploy_process_step" "process_step_review_approval" {
  name  = "Review -Approval-"
  notes = "Original stage name: Review and Approval. NOTE (migration): The original stage had a timeout of 30 minutes (stageTimeoutMs: 1800000). Configure a Manual Intervention timeout in Octopus if required."
  ...
}
```

## kubectl Script Steps (KubernetesRunScript)

* Steps of type `"Octopus.KubernetesRunScript"` (generated from `deleteManifest`, `scaleManifest`, and `undoRolloutManifest` stage types) MUST use `"Octopus.Action.Script.Syntax" = "Bash"` in `execution_properties`. These steps run `kubectl` commands on Linux Kubernetes workers where Bash is the idiomatic shell.
* You will be penalized for using `"Octopus.Action.Script.Syntax" = "PowerShell"` on an `"Octopus.KubernetesRunScript"` step.
* The `execution_properties` for an `"Octopus.KubernetesRunScript"` step must include:
  * `"Octopus.Action.RunOnServer" = "true"`
  * `"OctopusUseBundledTooling" = "False"`
  * `"Octopus.Action.Script.ScriptSource" = "Inline"`
  * `"Octopus.Action.Script.Syntax" = "Bash"`
  * `"Octopus.Action.Script.ScriptBody"` — the inline Bash kubectl command
  * `"Octopus.Action.KubernetesContainers.Namespace"` — the Kubernetes namespace (if specified)
* The `properties` block for a `"Octopus.KubernetesRunScript"` step must include `"Octopus.Action.TargetRoles"` set to the Kubernetes target tag.

**CRITICAL — `undoRolloutManifest` steps use `Octopus.KubernetesRunScript` with `kubectl rollout undo`**: When the prompt says `Add a "Run a kubectl script" step` with a script like `kubectl rollout undo deployment/my-deployment -n my-namespace`, this step uses the SAME type (`Octopus.KubernetesRunScript`) and the SAME Bash syntax as `deleteManifest` and `scaleManifest` steps. Do NOT use `Octopus.Script` for these steps.

**Negative example — `undoRolloutManifest` step incorrectly using `Octopus.Script` (FORBIDDEN)**:
```hcl
resource "octopusdeploy_process_step" "process_step_rollback_internal" {
  name   = "Rollback -internal-"
  type   = "Octopus.Script"   ← WRONG: should be "Octopus.KubernetesRunScript"
  ...
  execution_properties = {
    "Octopus.Action.Script.ScriptBody"   = "kubectl rollout undo deployment/my-deployment -n my-namespace"
    "Octopus.Action.Script.Syntax"       = "PowerShell"   ← WRONG: should be "Bash"
  }
}
```

**Correct output** — `undoRolloutManifest` step using `Octopus.KubernetesRunScript` with Bash:
```hcl
resource "octopusdeploy_process_step" "process_step_rollback_internal" {
  name                 = "Rollback -internal-"
  type                 = "Octopus.KubernetesRunScript"   ← CORRECT
  process_id           = octopusdeploy_process.process_myproject[0].id
  condition            = "Success"
  notes                = "Original stage type: undoRolloutManifest. This step rolls back deployment/dmp-market-web-internal to the previous revision in namespace app-0112-prod."
  package_requirement  = "LetOctopusDecide"
  start_trigger        = "StartAfterPrevious"
  properties           = {
    "Octopus.Action.TargetRoles" = "Kubernetes"
  }
  execution_properties = {
    "Octopus.Action.RunOnServer"                    = "true"
    "OctopusUseBundledTooling"                      = "False"
    "Octopus.Action.Script.ScriptSource"            = "Inline"
    "Octopus.Action.Script.Syntax"                  = "Bash"   ← CORRECT
    "Octopus.Action.Script.ScriptBody"              = "kubectl rollout undo deployment/dmp-market-web-internal -n app-0112-prod"
    "Octopus.Action.KubernetesContainers.Namespace" = "app-0112-prod"
  }
}
```

**Example — correct `Octopus.KubernetesRunScript` step with Bash syntax**:

```hcl
resource "octopusdeploy_process_step" "process_step_delete_manifest" {
  name                  = "Delete -Manifest-"
  type                  = "Octopus.KubernetesRunScript"
  process_id            = octopusdeploy_process.process_myproject[0].id
  condition             = "Success"
  notes                 = "Original stage name: Delete (Manifest)"
  package_requirement   = "LetOctopusDecide"
  start_trigger         = "StartAfterPrevious"
  properties            = {
    "Octopus.Action.TargetRoles" = "Kubernetes"
  }
  execution_properties  = {
    "Octopus.Action.RunOnServer"                      = "true"
    "OctopusUseBundledTooling"                        = "False"
    "Octopus.Action.Script.ScriptSource"              = "Inline"
    "Octopus.Action.Script.Syntax"                    = "Bash"
    "Octopus.Action.Script.ScriptBody"                = "kubectl delete deployment my-deployment -n my-namespace"
    "Octopus.Action.KubernetesContainers.Namespace"   = "my-namespace"
  }
}
```

* A `Octopus.KubernetesRunScript` step must NOT include a `container` block unless the prompt explicitly requests a specific container image. `deleteManifest` and `scaleManifest` stage types run kubectl using the worker's native environment, not a containerized image.
* When the prompt specifies a Kubernetes namespace in the step (e.g., `Set the step namespace to "my-namespace"`), set `"Octopus.Action.KubernetesContainers.Namespace" = "my-namespace"` in `execution_properties`. When no namespace is specified, omit this property entirely — do NOT set it to an empty string or null.
* You will be penalized for adding a `container` block to an `Octopus.KubernetesRunScript` step when the prompt does not explicitly request one.

## Webhook / HTTP Script Steps

* When the prompt says `Add a "Run a Script" step` with inline Bash code that contains a `curl` command (i.e., the step is an HTTP webhook call converted from a Spinnaker `webhook` stage), the `Octopus.Script` step MUST use `"Octopus.Action.Script.Syntax" = "Bash"` in `execution_properties`. Do NOT use `"PowerShell"` for `curl`-based script steps.
* The `execution_properties` for a webhook/curl `"Octopus.Script"` step must include:
  * `"Octopus.Action.RunOnServer" = "true"`
  * `"Octopus.Action.Script.ScriptSource" = "Inline"`
  * `"Octopus.Action.Script.Syntax" = "Bash"`
  * `"Octopus.Action.Script.ScriptBody"` — the inline Bash `curl` command, preserving all `-H`, `-d`, and `-X` flags exactly as provided in the prompt.
* You will be penalized for using `"Octopus.Action.Script.Syntax" = "PowerShell"` on a script step whose `ScriptBody` contains a `curl` command.
* Do NOT set `worker_pool_id` or `worker_pool_variable` on a webhook/curl `Octopus.Script` step. These steps run on the Octopus server (`"Octopus.Action.RunOnServer" = "true"`) and do not use a worker pool. Leave both `worker_pool_id` and `worker_pool_variable` unset (or `null`) for server-side script steps.

## Default Lifecycle Instructions

* Use "data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id" when referencing the Default Lifecycle, for example `lifecycle_id = "${data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id}"`.
* You will be penalized for referencing the resource "octopusdeploy_lifecycle" "lifecycle_default_lifecycle" because it does not exist.
* The "quantity_to_keep" attribute in a "release_retention_policy" or "tentacle_retention_policy" block in a "phase" block must be larger than 0.
* You will be penalized for setting the "quantity_to_keep" attribute in a "release_retention_policy" or "tentacle_retention_policy" block in a "phase" block to 0.
* You will be penalized for defining the "phase" block on a single line.
* Each proprt of the "phase" block must be on a new line.

## Data Resources Instructions

* When getting the length of the "data" "octopusdeploy_projects" resource, the format is "${length(data.octopusdeploy_projects.<data name>.project) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_feeds" resource, the format is "${length(data.octopusdeploy_feeds.<data name>.feeds) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_worker_pools" resource, the format is "${length(data.octopusdeploy_worker_pools.<data name>.worker_pools) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_environments" resource, the format is "${length(data.octopusdeploy_environments.<data name>.environments) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_tag_sets" resource, the format is "${length(data.octopusdeploy_tag_sets.<data name>.tag_sets) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_lifecycles" resource, the format is "${length(data.octopusdeploy_lifecycles.<data name>.lifecycles) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_certificates" resource, the format is "${length(data.octopusdeploy_certificates.<data name>.certificates) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_git_credentials" resource, the format is "${length(data.octopusdeploy_git_credentials.<data name>.git_credentials) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_accounts" resource, the format is "${length(data.octopusdeploy_accounts.<data name>.accounts) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_machine_policies" resource, the format is "${length(data.octopusdeploy_machine_policies.<data name>.machine_policies) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_channels" resource, the format is "${length(data.octopusdeploy_channels.<data name>.channels) != 0 ? 0 : 1}".
* When getting the length of the "data" "octopusdeploy_deployment_targets" resource, the format is "${length(data.octopusdeploy_deployment_targets.<data name>.deployment_targets) != 0 ? 0 : 1}".
* The "<data name>" in the above examples must be replaced with the name of the data resource included in the output.
* You will be penalized for using a "<data name>" that does not match the name of the data resource included in the output.

## Account Data Instructions

* The "account_type" in a "octopusdeploy_accounts" data source must be set to one of the following, matching the case exactly:
  * "AmazonWebServicesAccount"
  * "AmazonWebServicesRoleAccount"
  * "AmazonWebServicesOidcAccount"
  * "AzureServicePrincipal"
  * "AzureOIDC"
  * "AzureSubscription"
  * "GenericOidcAccount"
  * "GoogleCloudAccount"
  * "None"
  * "SshKeyPair"
  * "Token"
  * "UsernamePassword"

* This is an example of a "octopusdeploy_accounts" data source with a correctly defined "account_type" attribute:

```
data "octopusdeploy_accounts" "account_azure" {
  ids          = null
  partial_name = "Azure"
  skip         = 0
  take         = 1
  account_type = "AzureOIDC"
}
```

* You will be penalized for setting the "account_type" to an empty value.

## Data and Resource pairing instructions

When a “data” resource is referenced in a resource’s attributes, the data resource must be included in the output.

For example, when the “lifecycle_id” attribute is set to:

```
"${length(data.octopusdeploy_lifecycles.lifecycle_<data ame>.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_<data name>.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_<name>[0].id}"
```

Then the following "octopusdeploy_lifecycles" data resource must be included in the output:

```
data "octopusdeploy_lifecycles" "lifecycle_<data name>" {
  ids          = null
  partial_name = "<Name>"
  skip         = 0
  take         = 1
}
```

When the "project_group_id" attribute is set to:

```
"${length(data.octopusdeploy_project_groups.project_group_<data name>.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_<data name>.project_groups[0].id : octopusdeploy_project_group.project_group_<name>[0].id}"
```

Then the following "octopusdeploy_project_groups" data resource must be included in the output:

```
data "octopusdeploy_project_groups" "project_group_<data name>" {
  ids          = null
  partial_name = "<Name>"
  skip         = 0
  take         = 1
}
```

And the following "octopusdeploy_project_group" resource must be defined:

```
resource "octopusdeploy_project_group" "project_group_<name>" {
  count = "${length(data.octopusdeploy_project_groups.project_group_<name>.project_groups) != 0 ? 0 : 1}"
  name  = "<Name>"
  ...
}
```

When the "feed_id" attribute is set to:

```
"${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
```

Then the following "octopusdeploy_feeds" data resource must be included in the output:

```
data "octopusdeploy_feeds" "<name>" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "<Name>"
  skip         = 0
  take         = 1
}
```

And the following "octopusdeploy_docker_container_registry" resource must be defined:

```
resource "octopusdeploy_docker_container_registry" "<name>" {
  count                                = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? 0 : 1}"
  name                                 = "<Name>"
  # Populate the rest of the feed attributes here
}
```

When the "environment_id" attribute is set to:

```
"${length(data.octopusdeploy_environments.environment_<data name>.environments) != 0 ? data.octopusdeploy_environments.environment_<data name>.environments[0].id : octopusdeploy_environment.environment_<name>[0].id}"
```

Then the following "octopusdeploy_environments" data resource must be included in the output:

```
data "octopusdeploy_environments" "environment_<name>" {
  ids          = null
  partial_name = "<Name>"
  skip         = 0
  take         = 1
}
```

And the following "octopusdeploy_environment" resource must be defined:

```
resource "octopusdeploy_environment" "environment_<name>" {
  count                        = "${length(data.octopusdeploy_environments.environment_<name>.environments) != 0 ? 0 : 1}"
  name                         = "<Name>"
  # Populate the rest of the environment attributes here
}
```

You will be penalized for referencing a "octopusdeploy_environments" data source or "octopusdeploy_environment" resource that does not exist in the output.

When the "project_id" attribute is set to "${length(data.octopusdeploy_projects.project_<name>.projects) != 0 ? 0 : 1}"

```
data "octopusdeploy_projects" "project_<name>" {
  ids          = null
  partial_name = "<Name>"
  skip         = 0
  take         = 1
}
```

And the following "octopusdeploy_project" resource must be defined:

```
resource "octopusdeploy_project" "project_<name>" {
    count = "${length(data.octopusdeploy_projects.project_<name>.projects) != 0 ? 0 : 1}"
    name = "<Name>"
    # Populate the rest of the project attributes here
}
```

## Count Properties Instructions

* The "count" parameter for any "octopusdeploy_process" resources must be the same as the "count" resource for the "octopusdeploy_project" resource.
* The "count" parameter for any "octopusdeploy_process_step" resources must be the same as the "count" resource for the "octopusdeploy_project" resource.
* The "count" parameter for any "octopusdeploy_process_templated_step" resources must be the same as the "count" resource for the "octopusdeploy_project" resource. This applies to ALL templated steps including Slack notification steps (Start, Finish, Complete), community step template steps, and any other step created with the `octopusdeploy_process_templated_step` resource type. You will be penalized for omitting `count` on any `octopusdeploy_process_templated_step` resource.
* The "count" parameter for any "octopusdeploy_process_steps_order" resources must be the same as the "count" resource for the "octopusdeploy_project" resource.
* The "count" parameter for any "octopusdeploy_process_child_step" resources must be the same as the "count" resource for the "octopusdeploy_project" resource.
* The "count" parameter for any "octopusdeploy_process_child_steps_order" resources must be the same as the "count" resource for the "octopusdeploy_project" resource.
* The "count" parameter for any "octopusdeploy_external_feed_create_release_trigger" resources must be the same as the "count" resource for the "octopusdeploy_project" resource.
* The "count" parameters must be in the format "${length(data.<data type>.<data resource>.<collection>) != 0 ? 0 : 1}"
* You will be penalized for using count arguments like this: "${length(data.<data type>.<data resource>.<collection>) != 0 ? 1 : 1}"
* You will be penalized for using ternary operators that return the same value for both cases.
* **MANDATORY SELF-CHECK before finalizing external feed triggers**: Before outputting an `octopusdeploy_external_feed_create_release_trigger` resource, verify that it has: (1) a `count` attribute matching the project's count pattern, (2) `project_id` using the ternary lookup pattern, (3) `channel_id` using the ternary lookup pattern, (4) a `lifecycle { prevent_destroy = true }` block, (5) a `depends_on` referencing `octopusdeploy_process_steps_order`. If any of these are missing, correct them before outputting. You will be penalized for each missing attribute.

**STOP — verify external feed trigger before outputting**: An `octopusdeploy_external_feed_create_release_trigger` resource MUST contain ALL of the following attributes. If any are missing, the Terraform will fail on idempotent re-apply. Check each:

```hcl
# CORRECT: complete external feed trigger with ALL required attributes
resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_my_project_external_feed_trigger" {
  count      = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"   # REQUIRED
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? data.octopusdeploy_projects.project_my_project.projects[0].id : octopusdeploy_project.project_my_project[0].id}"   # REQUIRED: ternary
  name       = "External Feed Trigger"
  channel_id = "${length(data.octopusdeploy_channels.channel_my_project_application.channels) != 0 ? data.octopusdeploy_channels.channel_my_project_application.channels[0].id : octopusdeploy_channel.channel_my_project_application[0].id}"   # REQUIRED: ternary
  is_disabled = true   # when prompt says "The trigger must be disabled."
  depends_on = [octopusdeploy_process_steps_order.process_step_order_my_project]   # REQUIRED
  lifecycle {
    prevent_destroy = true   # REQUIRED
  }
}
```

Before outputting the trigger, answer YES/NO to each:
- Has `count`? 
- Has `project_id` with ternary lookup (NOT direct reference)?
- Has `channel_id` with ternary lookup (NOT direct reference)?
- Has `lifecycle { prevent_destroy = true }`?
- Has `depends_on` pointing to `octopusdeploy_process_steps_order`?

If any answer is NO, fix the resource before outputting.

## Account Instructions

* You will be penalized for defining a "session_token" attribute on a "octopusdeploy_aws_account" resource.

## Lifecycle Instructions

* Custom lifecycles must include the environments "Development", "Test", and "Production" unless otherwise instructed.

## Tenant Instructions

* If the prompt indicates that tenants are to be created or added, the "octopusdeploy_tenant" resources must be created in addition to the "octopusdeploy_project" resource.
* You will be penalized for creating "octopusdeploy_tenant" resources without an associated "octopusdeploy_project" resource.
* Each resource "octopusdeploy_tenant" must have an associated data "octopusdeploy_tenants". For example, if the following resource is defined:

```
resource "octopusdeploy_tenant" "tenant_australian_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  name        = "Australian Office"
  description = "An example tenant that represents an Australian office"
  tenant_tags = []
  depends_on  = []
  lifecycle {
    prevent_destroy = true
  }
}
```

Then the associated data resource must be defined as follows:

```
data "octopusdeploy_tenants" "tenant_australian_office" {
  ids          = null
  partial_name = "Australian Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
```

* When the prompt includes instructions to define the value of project tenant variables, you must define the value for all environment unless explicitly instructed otherwise.
* When the prompt includes instructions to link a tenant to a project, you must include a "octopusdeploy_tenant_project" resource.
* You will be penalized for defining a "octopusdeploy_tags" data source as this data source does not exist.

## Library Variable Set Instructions

* Each resource "octopusdeploy_library_variable_set" must have an associated data "octopusdeploy_library_variable_sets". For example, if the following resource is defined:

```
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_example_variable_set" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  name        = "Example Variable Set"
  description = ""
}
```

Then the associated data resource must be defined as follows:

```
data "octopusdeploy_library_variable_sets" "library_variable_set_variables_example_variable_set" {
  ids          = null
  partial_name = "Example Variable Set"
  skip         = 0
  take         = 1
}
```

* A library variable set "Variable Template" is defined in the "template" block of a "octopusdeploy_library_variable_set" resource.
* A tenant "Common Variable" is defined in a "octopusdeploy_tenant_project_variable" resource.
* A tenant common variable sets the value of a variable template defined in a library variable set.
* When the prompt indicates that the variable template defines an AWS account, the "template" block must have the "display_settings" attribute set to `{ "Octopus.ControlType" = "AmazonWebServicesAccount" }`.
* Every "octopusdeploy_tenant_common_variable" resource must have a "depends_on" attribute that is an array including the associated "octopusdeploy_tenant_project".
* You will be penalized for creating a "octopusdeploy_tenant_common_variable" resource without a "depends_on" attribute.
* The "label" attribute in a "template" block of a "octopusdeploy_library_variable_set" resource must be omitted if it is an empty string.
* You will be penalized for defining the "label" attribute as an empty string in a "template" block of a "octopusdeploy_library_variable_set" resource.

* You must define the "template_id" property for every "octopusdeploy_tenant_common_variable" resource, for example:

```
# This is the data source returning existing tenants
data "octopusdeploy_tenants" "tenant_australian_office" {
  ids          = null
  partial_name = "Australian Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}

# This is the data source returning existing library variable sets
data "octopusdeploy_library_variable_sets" "library_variable_set_variables_example_variable_set" {
  ids          = null
  partial_name = "Example Variable Set"
  skip         = 0
  take         = 1
}

# This is the library variable set resource
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_example_variable_set" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  name        = "Example Variable Set"
  description = ""

  template {
    name             = "Common.Variable"
    label            = "A common variable that must be defined for each tenant"
    help_text        = "The help text associated with the variable is defined here."
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "MultiLineText" }
  }
}

# This is the tenant resource
resource "octopusdeploy_tenant" "tenant_australian_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  name        = "Australian Office"
  description = "An example tenant that represents an Australian office"
  tenant_tags = []
}

# This is the tenant common variable resource.
resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[0].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Option1"
}
```

* You will be penalized for defining a "octopusdeploy_tenant_common_variable" resource with an empty string for the "template_id" attribute.
* You will be penalized for defining a "octopusdeploy_tenant_common_variable" resource with an empty string for the "library_variable_set_id" attribute.
* The "library_variable_set_id" property for a "octopusdeploy_tenant_common_variable" resource must be defined.
* You will be penalized for setting the "library_variable_set_id" property for a "octopusdeploy_tenant_common_variable" resource to an empty string or null.

## Tenant Tag Instructions

* The "tenant_tags" attribute must be an array with strings that looks like "<tag set name>/<tag name>", for example "Cities/Sydney" or "BU/Sales".
* You will be penalized for defining an item in the "tenant_tags" array as a single string like "Sydney".
* You will be penalized for defining an item in the "tenant_tags" array like "region:us-east".
* The "<tag set name>" must match the name of a resource "octopusdeploy_tag_set".
* The "<tag name>" must match the name of a resource "octopusdeploy_tag".
* The "tenant_tags" attribute must only be defined in an "octopusdeploy_process_step" block.
* You will be penalized for creating resources of type "octopusdeploy_project_tenant_tag".
* For example, if the "tenant_tags" attribute is set to "Cities/Sydney", then the following data "octopusdeploy_tag_sets", resource "octopusdeploy_tag_set" and resource "octopusdeploy_tag" must be included in the output:

```
# A data resource to find the existing tag set
# There is a one-to-one relationship between this resource and the data resource
data "octopusdeploy_tag_sets" "tagset_cities" {
  ids          = null
  partial_name = "Cities"
  skip         = 0
  take         = 1
}

# If there is no existing tag set, create one with this resource
# There is a one-to-one relationship between this resource and the data resource
resource "octopusdeploy_tag_set" "tagset_cities" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "Cities"
  description = "An example tag set that captures cities"
  lifecycle {
    prevent_destroy = true
  }
}

# If there is no existing tag set, create the tag with this resource
# There is a one-to-many relationship between tag sets and tags
resource "octopusdeploy_tag" "tagset_cities_tag_sydney" {
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Sydney"], [])) != 0 ? 0 : 1
  name        = "Sydney"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  # The colours are random
  color       = "#333333"
  description = ""
}

# If there is no existing tag set, create the tag with this resource
# There is a one-to-many relationship between tag sets and tags
resource "octopusdeploy_tag" "tagset_cities_tag_brisbane" {
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Brisbane"], [])) != 0 ? 0 : 1
  name        = "Brisbane"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  # The colours are random
  color       = "#C5AEEE"
  description = ""
}
```

* The "count" attribute on the resource "octopusdeploy_tag" must be set to `length(try([for item in data.octopusdeploy_tag_sets.<tagset data name>.tag_sets[0].tags : item if item.name == "<tag name>"], [])) != 0 ? 0 : 1`
* You will be penalized for using a "count" attribute on the resource "octopusdeploy_tag" using underscores in the place of brackets, question marks, and exclamation points like this: `length(try([for item in data.octopusdeploy_tag_sets.<tagset data name>.tag_sets[0].tags : item if item.name == "<tag name>"], []_ _= 0 _ 0 : 1`
"

## Lifecycle Instructions

* When using a lifecycle other than the "Default Lifecycle", you must include a data "octopusdeploy_lifecycles" and a resource "octopusdeploy_lifecycle", for example:

```
data "octopusdeploy_lifecycles" "lifecycle_application" {
  ids          = null
  partial_name = "Application"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_lifecycle" "lifecycle_application" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? 0 : 1}"
  name        = "Application"
  description = "This is an example lifecycle that automatically deploys to the first environment"

  # You must define one or more "phase" blocks
  phase {
    # the phase is defined here
  }
}
```

* The resource "octopusdeploy_lifecycle" must have "phase" blocks with environments listed in either the "automatic_deployment_targets" array or the "optional_deployment_targets" array.
* You must use the "optional_deployment_targets" array over the "automatic_deployment_targets" array unless instructed that the Environment should be deployed to automatically.
* You will be penalized if you include environments in the "automatic_deployment_targets" array unless otherwise instructed.
* You will be penalized for defining a lifecycle phase with no environments.

* The `unit` property in a `release_retention_policy` or `tentacle_retention_policy` block in a `phase` block must be set to `Days` or `Items`, for example:

```
resource "octopusdeploy_lifecycle" "simple_lifecycle" {
  description = "A test lifecycle"
  name        = "Simple"

  release_retention_policy {
    quantity_to_keep    = 1
    unit                = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep    = 30
    unit                = "Items"
  }

  phase {
    automatic_deployment_targets = []
    optional_deployment_targets  = [octopusdeploy_environment.development_environment.id]
    name                         = octopusdeploy_environment.development_environment.name

    release_retention_policy {
      quantity_to_keep    = 1
      unit                = "Days"
    }

    tentacle_retention_policy {
      quantity_to_keep    = 30
      unit                = "Items"
    }
  }
```

* You will be penalized for setting the `unit` property in a `release_retention_policy` or `tentacle_retention_policy` block in a `phase` block to `Releases`.

## Variable Template Instructions

* You must set the "default_value" in a "template" block to "null" when there is no default value, for example:

```
  template {
    name             = "ConnectionString"
    label            = "Database Connection String"
    help_text        = "Provide the connection string for the API Gateway database."
    default_value    = null
    display_settings = { "Octopus.ControlType" = "SingleLineText" }
  }
```

* You will be penalized for setting the "default_value" to an empty string.

* You must always include the following data source:

```
data "octopusdeploy_lifecycles" "system_lifecycle_firstlifecycle" {
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}
```

## GitHub Connection Instructions

* You will be penalized for defining a data source of type "octopusdeploy_github_connections".

## Resource and Data Instructions

* When referencing a lifecycle, you must create the "resource" type "octopusdeploy_lifecycle" and the "data" type "octopusdeploy_lifecycles".
* When referencing a project group, you must create the "resource" type "octopusdeploy_project_group" and the "data" type "octopusdeploy_project_groups".
* When referencing a feed, you must create the "data" type "octopusdeploy_feeds" and one of the "resource" types:
  * "octopusdeploy_docker_container_registry"
  * "octopusdeploy_aws_elastic_container_registry"
  * "octopusdeploy_maven_feed"
  * "octopusdeploy_github_repository_feed"
  * "octopusdeploy_helm_feed"
  * "octopusdeploy_nuget_feed"
  * "octopusdeploy_artifactory_generic_feed"
  * "octopusdeploy_s3_feed"
* The data "octopusdeploy_feeds" resource must have a "feed_type" attribute set to one of the following:
  * "AwsElasticContainerRegistry"
  * "BuiltIn"
  * "Docker"
  * "GitHub"
  * "Helm"
  * "Maven"
  * "NuGet"
  * "S3"
  * "OciRegistry"
  * "OctopusProject"
  * "ArtifactoryGeneric"
* You will be penalized for setting the "feed_type" attribute to "Git".

## Feed Instructions

* The data "octopusdeploy_feeds" with "type" set to "BuiltIn" must have an empty "partial_name" attribute.
* You must define the data "octopusdeploy_feeds" "feed_docker_hub" once.
* You will be penalized for defining the data "octopusdeploy_feeds" "feed_docker_hub" more than once.
* You must always include a "octopusdeploy_feeds" data source that references the built-in feed, for example:

```
data "octopusdeploy_feeds" "feed_octopus_server__built_in_" {
  feed_type    = "BuiltIn"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}
```

* You will be penalized for not including a "octopusdeploy_feeds" data source that references the built-in feed.
* The built-in feed always exists and must not be created as a resource.

* The "feed_type" attribute on a "octopusdeploy_feeds" data source must be set to one of the following values:
  * "AwsElasticContainerRegistry"
  * "BuiltIn"
  * "Docker"
  * "GitHub"
  * "Helm"
  * "Maven"
  * "NuGet"
  * "S3"
  * "OciRegistry"
  * "OctopusProject"
* If the prompt specifies a "feed_type" that is not in the list, you must define the feed as "NuGet".
* You will be penalized for setting "feed_type" to "Npm".
* You will be penalized for setting the "password" property on a "octopusdeploy_docker_container_registry" resource to an empty string.
* You will be penalized for creating a resource of type resource "octopusdeploy_feed".
* You will be penalized for creating a resource of type resource "octopusdeploy_generic_artifact_feed".
* When creating a Maven feed with anonymous authentication, you must set the "username" and "password" attributes to null.
* When creating a Docker feed with anonymous authentication, you must set the "username" and "password" attributes to null.
* You will be penalized for setting the "username" and "password" attributes to empty strings when creating a Maven feed with anonymous authentication.
* You will be penalized for setting the "username" and "password" attributes to empty strings when creating a Docker feed with anonymous authentication.
* The "is_enhanced_mode" property must only be defined on the "octopusdeploy_nuget_feed" resource.
* You will be penalized for defining the "is_enhanced_mode" property on a "octopusdeploy_maven_feed" resource.
* You will be penalized for creating a resource of type "octopusdeploy_builtin_feed"

**CRITICAL — Google Container Registry feed URI format**: When the prompt says `Create a feed called "Google Container Registry" with a feed URL of "https://gcr.io/v2/"`, the correct Terraform representation uses `feed_uri = "https://gcr.io"` and `api_version = "v2"` as **separate attributes**. Do NOT embed the API version path in `feed_uri`.

**Negative example — GCR API version embedded in feed_uri (FORBIDDEN)**:
```hcl
resource "octopusdeploy_docker_container_registry" "feed_google_container_registry" {
  name     = "Google Container Registry"
  feed_uri = "https://gcr.io/v2/"   ← WRONG: API version must be a separate attribute, not in the URI
  ...
}
```
← WRONG: `feed_uri` must contain only the registry base URL. A `feed_uri` like `"https://gcr.io/v2/"` or `"https://gcr.io/v2."` with the version embedded in the path is invalid.

The **CORRECT** Terraform for a Google Container Registry feed:
```hcl
resource "octopusdeploy_docker_container_registry" "feed_google_container_registry" {
  count        = "${length(data.octopusdeploy_feeds.feed_google_container_registry.feeds) != 0 ? 0 : 1}"
  name         = "Google Container Registry"
  feed_uri     = "https://gcr.io"  ← CORRECT: base URL only
  api_version  = "v2"              ← CORRECT: API version as a separate attribute
  username     = null
  password     = null
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
```

**CRITICAL — GitHub Container Registry feed URI format**: Similarly, when the prompt specifies a GitHub Container Registry feed, use `feed_uri = "https://ghcr.io"` and `api_version = "v2"` as separate attributes — never embed `/v2` in the `feed_uri`.

**CRITICAL — Docker Hub feed URI format**: For Docker Hub, use `feed_uri = "https://index.docker.io"` with `api_version = ""` (empty string). The `api_version` attribute on `octopusdeploy_docker_container_registry` is always specified separately from `feed_uri`.
* You will be penalized for creating data or resource blocks with unbalanced brackets, for example:
```
data "octopusdeploy_feeds" "feed_octopus_server__built_in_" {
  feed_type    = "BuiltIn"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
  # This curly bracket is unbalanced and must be removed
   }
}

resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "Octopus Maven Feed"
  feed_uri                             = "http://octopus-sales-public-maven-repo.s3-website-ap-southeast-2.amazonaws.com/snapshot"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  # The lifecycle block below has unbalanced brackets. There must be a closing curly bracket after the prevent_destroy attribute and before the closing curly bracket for the resource.
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
}
```

## Project Group Instructions

* Only the "Default Project Group" data "octopusdeploy_project_groups" includes a "postcondition" attribute.
* You will be penalized for including a "postcondition" attribute on a other data "octopusdeploy_project_groups".

## Account Instructions

* The "account_type" field must be one of the following, matching the case exactly:
  * "AmazonWebServicesAccount"
  * "AmazonWebServicesRoleAccount"
  * "AmazonWebServicesOidcAccount"
  * "AzureServicePrincipal"
  * "AzureOIDC"
  * "AzureSubscription"
  * "GenericOidcAccount"
  * "GoogleCloudAccount"
  * "None"
  * "SshKeyPair"
  * "Token"
  * "UsernamePassword"
* You will be penalized for using an "account_type" of "AzureOidc". It must be "AzureOIDC".
* You will be penalized for using an "account_type" of "Certificate".
* Account resources types must be one of the following:
  * "octopusdeploy_aws_openid_connect_account"
  * "octopusdeploy_azure_openid_connect"
  * "octopusdeploy_gcp_account"
  * "octopusdeploy_azure_service_principal"
  * "octopusdeploy_ssh_key_account"
  * "octopusdeploy_token_account"
  * "octopusdeploy_username_password_account"
* The "role_arn" property on the resource "octopusdeploy_aws_openid_connect_account" is mandatory.
* You will be penalized for omitting the "role_arn" property on the resource "octopusdeploy_aws_openid_connect_account".
* The resource "octopusdeploy_aws_openid_connect_account" must have a "role_arn" property set to "arn:aws:iam::123456789012:role/MyRole"
* The "azure_environment" attribute for a "octopusdeploy_azure_openid_connect" resource must be set to "AzureCloud" unless specifically instructed otherwise in the prompt.
* The resource "octopusdeploy_azure_openid_connect" must have a "azure_environment" attribute set to one of:
  * "AzureCloud"
  * "AzureChinaCloud"
  * "AzureGermanCloud"
  * "AzureUSGovernment"
* The "application_id" attribute for the resource "octopusdeploy_azure_service_principal" must be set to "00000000-0000-0000-0000-000000000000"
* The "subscription_id" attribute for the resource "octopusdeploy_azure_service_principal" must be set to "00000000-0000-0000-0000-000000000000"
* The "tenant_id" attribute for the resource "octopusdeploy_azure_service_principal" must be set to "00000000-0000-0000-0000-000000000000"

## Octopus Runbook Instructions

* The "retention_policy" block can only be defined for a resource "octopusdeploy_runbook".
* You will be penalized for defining a "octopusdeploy_project_runbook" resource.
* You will be penalized for defining the "unit" property in a "retention_policy" block in a "octopusdeploy_runbook" resource, for example, this resource "octopusdeploy_runbook" is invalid because it includes the "unit" property in the "retention_policy" block:

```
resource "octopusdeploy_runbook" "runbook_my_script_app_4_retrieve_logs" {
    count                       = "${length(data.octopusdeploy_projects.project_my_script_app_4.projects) != 0 ? 0 : 1}"
    name                        = "${var.runbook_my_script_app_4_retrieve_logs_name}"
    project_id                  = "${length(data.octopusdeploy_projects.project_my_script_app_4.projects) != 0 ? data.octopusdeploy_projects.project_my_script_app_4.projects[0].id : octopusdeploy_project.project_my_script_app_4[0].id}"
    environment_scope           = "Unscoped"
    environments                = []
    force_package_download      = false
    default_guided_failure_mode = "EnvironmentDefault"
    description                 = "Simulate the retrieval of logs"
    multi_tenancy_mode          = "Untenanted"

    retention_policy {
      quantity_to_keep    = 1
      # The unit property is invalid and must not be defined in a retention_policy block for a runbook resource
      unit                = "Items"
    }

    connectivity_policy {
      allow_deployments_to_no_targets = true
      exclude_unhealthy_targets       = false
      skip_machine_behavior           = "None"
      target_roles                    = []
    }
}
```

* You will be penalized for setting both the "should_keep_forever" attribute and defining the "quantity_to_keep" attribute in a "octopusdeploy_runbook" resource.
* If the "quantity_to_keep" attribute is defined in a "retention_policy" block in a "octopusdeploy_runbook" resource, the "should_keep_forever" attribute must be omitted.

## Octopus Project Instructions

* The "name" attribute in a "octopusdeploy_project" resource can only contain letters, numbers, periods, commas, dashes, underscores, brackets, square brackets, or hashes.
* The "slug" attribute in a "octopusdeploy_project" resource can only contain lower case letters, numbers, or dashes. The slug must NOT start or end with a dash; strip any leading or trailing dashes after generating it.
* You will be penalized for replacing brackets with underscores in the "name" attribute of a "octopusdeploy_project" resource.
* Retention policies do not apply to resource "octopusdeploy_project".
* You must ignore any mention of retention policies when building the resource "octopusdeploy_project".
* You will be penalized for adding a "retention_policy" block to a resource "octopusdeploy_project".
* You will be penalized for creating "octopusdeploy_project_deployment_settings" resources.
* You will be penalized for creating "octopusdeploy_project_retention_policy" resources.
* The "skip_machine_behavior" property can be set to "None" or "SkipUnavailableMachines"
* If a project name was specified in the prompt, you must use that name for the "name" attribute in the resource "octopusdeploy_project".
* You must include the "lifecycle_id" attribute for every "octopusdeploy_project" resource.
* The "is_version_controlled" attribute must always be "false".
* You will be penalized for setting the "auto_create_release" attribute to "true".
* The name of the data source much also match the name used when referencing a "project_id" attribute. For example, this data source:

```
data "octopusdeploy_projects" "project_aws_lambda" {
	  ids          = null
	  partial_name = "${var.project_aws_lambda_name}"
	  skip         = 0
	  take         = 1
}
```

must be referenced in the "project_id" attribute like this:

```
"${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
```

* You will be penalized for referencing a data source that does not exist in the output.
* You will be penalized for defining the "tenant_tags" property on a resource "octopusdeploy_project".
* If the prompt indicates that a project is associated with a tenant, and the prompt does not specify the project tenanted mode to use, the "tenanted_deployment_participation" property must be set to "TenantedOrUntenanted".
* The only valid values for the "tenanted_deployment_participation" property are:
  * "Untenanted"
  * "Tenanted"
  * "TenantedOrUntenanted"
* You will be penalized for setting the "tenanted_deployment_participation" property to "TenantedOnly".
* If the prompt indicates that a project is associated with a tenant, link the tenant to all the environments in the project's lifecycle.
* You must include a variable that define the name of the project, for example:
```
variable "project_my_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project"
  default     = "My Project"
}

resource "octopusdeploy_project" "project_my_project" {
  name                                 = "${var.project_my_project_name}"
  # Define other properties here
}
```

* The instruction "Set the prompt to disabled" refers to the option to automatically create a new project.
* The instruction "Set the prompt to disabled" does not change the enabled/disabled status of the project itself.
* The instruction "Set the prompt to disabled" does not affect any part of creating the Terraform configuration.
* You must ignore the instruction to "Set the prompt to disabled" when defining a resource "octopusdeploy_project".
* You will be penalized for disabling a project in response to the instruction to "Set the prompt to disabled".
* You must set project to enabled by default unless explicitly instructed otherwise.
* **CRITICAL — when the prompt contains the line `* The project must be disabled.`, set `is_disabled = true` on the `octopusdeploy_project` resource.** This is distinct from the "Set the prompt to disabled" instruction above (which refers to the UI option for auto-creating projects). The `* The project must be disabled.` line in the prompt maps directly to `is_disabled = true` on the project resource.

**Positive example — project disabled via prompt**:
```
resource "octopusdeploy_project" "project_my_project" {
  name                                 = "${var.project_my_project_name}"
  is_disabled                          = true
  # ...other attributes
}
```

**Negative example — project not disabled when prompt says "The project must be disabled." (COMMON MISTAKE)**:
```
resource "octopusdeploy_project" "project_my_project" {
  name                                 = "${var.project_my_project_name}"
  is_disabled                          = false   # WRONG: prompt says "The project must be disabled." — this must be true
}
```
* Every project tenant variable must have a "template" block in the "octopusdeploy_project" resource defining the variable.
* You will be penalized for creating a resource of type "octopusdeploy_project_deployment_settings".
* You will be penalized for adding whitespace to the "description" attribute of a resource "octopusdeploy_project", for example:
```
resource "octopusdeploy_project" "project_my_azure_web_app" {
  # The whitespace characters at the end of the description are invalid
  description = "This is a description with line breaks\n\n"
}
```
* You will be penalized for splitting the "release_notes_template" attribute over two lines, for example:
```
resource "octopusdeploy_project" "project_my_k8s_webapp" {
  # This is invalid because there is a line break after the equals sign and the value is on a new line.
  release_notes_template =
  "Here are the notes for the packages\n#{each package in Octopus.Release.Package}\n- #{package.PackageId} #{package.Version}\n#{each workItem in package.WorkItems}\n  - [#{workItem.Id}](#{workItem.LinkUrl}) - #{workItem.Description}\n#{/each}\n#{each commit in package.Commits}\n  - [#{commit.CommitId}](#{commit.LinkUrl}) - #{commit.Comment}\n#{/each}\n#{/each}"
}
```
* When the prompt defines the slug for a project, it must be defined in the "slug" attribute of the "octopusdeploy_project" resource, for example:
```
resource "octopusdeploy_project" "project_my_project" {
  name                                 = "${var.project_my_project_name}"
  slug                                 = "my-project"
  # Define other properties here
}

## Octopus Project Trigger Instructions

* When defining the "once_daily_schedule" block in the resource "octopusdeploy_project_scheduled_trigger" adhere to the following rules:
  * The "start_time" attribute value should be set to an ISO 8601 formatted string
  * The "timezone" attribute value should be set to a valid "Windows Time Zone Identifier" string.
* For example, this is an example of a scheduled project trigger, set to run at 09:00 each day in the Pacific Standard Time timezone:

```
resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_aws_lambda_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = "This trigger reruns the deployment in the Security environment. This means any new vulnerabilities detected after a production deployment will be identified."
  timezone    = "Pacific Standard Time"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-05-08T09:00:00"
    days_of_week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  }

  deploy_latest_release_action {
    source_environment_id      = "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"
    destination_environment_id = "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"
    should_redeploy            = true
  }
}
```

* You will be penalized for providing an attribute value for "timezone" that isn't a valid "Windows Time Zone Identifier".
* You will be penalized for providing an empty "project_id" attribute on a trigger.

* The "deployment_action_slug" property in the "package" block of the "octopusdeploy_external_feed_create_release_trigger" resource must be set to the slug of a deployment action in the associated project, for example:

```
resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_every_step_project_external_feed_trigger" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  name       = "External Feed Trigger"
  channel_id = "${length(data.octopusdeploy_channels.channel_frontend_application.channels) != 0 ? data.octopusdeploy_channels.channel_frontend_application.channels[0].id : octopusdeploy_channel.channel_frontend_application[0].id}"

  package {
    deployment_action_slug = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_script[0].slug}"
    package_reference      = "mypackage"
  }
  depends_on = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}
```

* If the prompt specifies that a external feed trigger is to be created, and does not specify that a channel is to be created, you must create a channel called "Application" and link that channel to the external feed trigger.

**Negative example — external feed trigger created without creating the "Application" channel (CRITICAL MISTAKE)**:

If the prompt says:
```
* Add a channel called "Application" to the project.
* Add a single external feed trigger that creates a new release for each step that deploys a Docker image.
```

The **WRONG** output omits the `octopusdeploy_channel` resource and uses `"Channels-1"` as a fallback:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  channel_id = "Channels-1"  # WRONG: The "Application" channel was never created
  ...
}
```

The **CORRECT** output always creates the `octopusdeploy_channel` resource AND references it via ternary lookup:
```hcl
resource "octopusdeploy_channel" "channel_application" {
  count      = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? 0 : 1}"
  name       = "Application"
  project_id = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? data.octopusdeploy_projects.project_foo.projects[0].id : octopusdeploy_project.project_foo[0].id}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  count      = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? data.octopusdeploy_projects.project_foo.projects[0].id : octopusdeploy_project.project_foo[0].id}"
  channel_id = "${length(data.octopusdeploy_channels.channel_application.channels) != 0 ? data.octopusdeploy_channels.channel_application.channels[0].id : octopusdeploy_channel.channel_application[0].id}"
  depends_on = [octopusdeploy_process_steps_order.process_step_order_project_foo]
  lifecycle {
    prevent_destroy = true
  }
  ...
}
```
* If the prompt specifies `Add a channel called "Application" to the project and configure a version rule that matches the regex "<regex>" for every step that deploys a Docker image.`, create an `octopusdeploy_channel` resource named "Application" with a `rule` block whose `tag` property is set to the exact regex from the prompt.
* When that regex-based channel rule applies to steps that expose package metadata, add one `action_package` block per matching deployment action. **CRITICAL — if the matching steps are `Octopus.KubernetesDeployRawYaml` steps without `primary_package` or `packages` blocks, you MUST create the channel WITHOUT any `rule` block.** The Octopus API rejects `rule` blocks that have no `action_package` entries with the error "Version rules must specify a package step". Since `KubernetesDeployRawYaml` steps have no package references, do NOT add any `rule` block to the channel — create the channel as a bare named channel with no version rules. Do not drop the channel entirely.
* If the prompt specifies both a regex-based `Application` channel and an external feed trigger, the `octopusdeploy_external_feed_create_release_trigger` resource must reference that regex-based channel instead of creating or linking to a second bare `Application` channel.
* If the prompt specifies an external feed trigger for a project whose deployment steps are `Octopus.KubernetesDeployRawYaml` steps without a `primary_package` or `packages` block, create the `octopusdeploy_external_feed_create_release_trigger` resource without a `package` block. Do not drop the trigger merely because the referenced deployment step has no package metadata.
* **CRITICAL — when the prompt says the external feed trigger must be disabled**, set `is_disabled = true` on the `octopusdeploy_external_feed_create_release_trigger` resource. The prompt will say something like `"The trigger must be disabled."` for migrated pipelines with Docker triggers that were originally disabled. You will be penalized for omitting `is_disabled = true` when the prompt explicitly disables the trigger.

**Negative example — disabled trigger without `is_disabled = true` (COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  ...
  name       = "External Feed Trigger"
  # WRONG: is_disabled attribute is missing even though prompt says "The trigger must be disabled."
}
```

**Correct output — disabled trigger with `is_disabled = true`**:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  ...
  name        = "External Feed Trigger"
  is_disabled = true   # Required because the prompt says "The trigger must be disabled."
}
```
* You will be penalized for setting the "channel_id" attribute to a fixed value like "Channels-1".

**CRITICAL — `channel_id` on ALL triggers MUST use the ternary lookup pattern, even when the channel was just created in the same Terraform configuration**: When a channel `octopusdeploy_channel.channel_application` is created in the same Terraform file, the external feed trigger's `channel_id` MUST still use the ternary pattern `"${length(data.octopusdeploy_channels.channel_application.channels) != 0 ? data.octopusdeploy_channels.channel_application.channels[0].id : octopusdeploy_channel.channel_application[0].id}"`. Using the direct reference `"${octopusdeploy_channel.channel_application.id}"` is FORBIDDEN even when the channel resource exists in the same file.

**Negative example — `channel_id` set to a hard-coded value (COMMON MISTAKE)**:

```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  count      = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? data.octopusdeploy_projects.project_foo.projects[0].id : octopusdeploy_project.project_foo[0].id}"
  channel_id = "Channels-1"  # WRONG: hard-coded channel ID is never valid
  name       = "External Feed Trigger"
}
```

The **CORRECT** output uses a ternary lookup for `channel_id`:

```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  count      = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? data.octopusdeploy_projects.project_foo.projects[0].id : octopusdeploy_project.project_foo[0].id}"
  channel_id = "${length(data.octopusdeploy_channels.channel_application.channels) != 0 ? data.octopusdeploy_channels.channel_application.channels[0].id : octopusdeploy_channel.channel_application[0].id}"
  name       = "External Feed Trigger"
  depends_on = [octopusdeploy_process_steps_order.process_step_order_project_foo]
  lifecycle {
    prevent_destroy = true
  }
}
```

* The `project_id` attribute on an `octopusdeploy_external_feed_create_release_trigger` resource MUST use the ternary lookup pattern, just like the `project_id` on any other resource. You will be penalized for setting `project_id` to a direct resource reference such as `octopusdeploy_project.project_foo.id` without the ternary guard.

**Negative example — `project_id` set to a direct resource reference WITHOUT ternary guard (COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  project_id = "${octopusdeploy_project.project_foo.id}"   ← WRONG: no ternary guard
  channel_id = "${octopusdeploy_channel.channel_application.id}"  ← WRONG: no ternary guard
  ...
}
```

**Correct output — both `project_id` and `channel_id` MUST use ternary lookup**:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "example" {
  project_id = "${length(data.octopusdeploy_projects.project_foo.projects) != 0 ? data.octopusdeploy_projects.project_foo.projects[0].id : octopusdeploy_project.project_foo[0].id}"
  channel_id = "${length(data.octopusdeploy_channels.channel_application.channels) != 0 ? data.octopusdeploy_channels.channel_application.channels[0].id : octopusdeploy_channel.channel_application[0].id}"
  ...
}
```

* Every `octopusdeploy_external_feed_create_release_trigger` resource MUST include a `lifecycle { prevent_destroy = true }` block. You will be penalized for omitting this block.
* The "package" block in a "octopusdeploy_external_feed_create_release_trigger" resource must have a "deployment_action_slug" property that references a deployment action in the associated project.
* You will be penalized for setting the "deployment_action_slug" property in the "package" block of a "octopusdeploy_external_feed_create_release_trigger" resource to an empty string or null when the step it references has no primary package.
* The "package_reference" property in the "package" block in a "octopusdeploy_external_feed_create_release_trigger" resource must have an empty string when referencing the "primary_package" of a step.
* The "package_reference" property in the "package" block in a "octopusdeploy_external_feed_create_release_trigger" resource must be the name of a key in the "packages" block of the referenced step if referencing a named package. For example:

```
resource "octopusdeploy_process_step" "process_step" {
  name          = "Run a script"
  process_id    = "octopusdeploy_process.process_octopub.id"
  packages      = {
    # webapp is a named package
    webapp = {
        acquisition_location = "Server",
        feed_id = "octopusdeploy_maven_feed.feed_octopus_maven_feed.id",
        id = null,
        package_id = "MyPackage",
        properties = { Extract = "True", Purpose = "", SelectionMode = "immediate" }
    }
  }
}

resource "octopusdeploy_process" "process_octopub" {
  project_id = "octopusdeploy_project.my_project.id}"
}

resource "octopusdeploy_external_feed_create_release_trigger" "project_trigger" {
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "octopusdeploy_project.my_project.id}"
  name       = "Second External Feed Trigger"
  channel_id = "octopusdeploy_channel.application.id}"

  package {
    deployment_action_slug = "run-a-script"
    # The package_reference must match the key "webapp" from the "packages" block in the octopusdeploy_process_step resource because there is no primary package
    package_reference      = "webapp"
  }
  depends_on = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}
```

* You will be penalized for setting the "package_reference" property in the "package" block in a "octopusdeploy_external_feed_create_release_trigger" resource to an empty string when the referenced step has no "primary_package" defined.
* You will be penalized for setting the "package_reference" property in the "package" block in a "octopusdeploy_external_feed_create_release_trigger" resource to an empty string when the referenced step is of type "Octopus.KubernetesDeployRawYaml", as this step has no primary package.
* You will be penalized for creating resources of type "octopusdeploy_project_automatic_release_trigger".
* When creating a "octopusdeploy_external_feed_create_release_trigger" resource, but none of the project's steps define a "primary_package" or "packages" block, do not define the "package" block in the "octopusdeploy_external_feed_create_release_trigger" resource. This creates a placeholder trigger.

**CRITICAL — placeholder triggers (no `package` block) MUST still follow ALL resource conventions**: A placeholder `octopusdeploy_external_feed_create_release_trigger` (created without a `package` block because the steps have no package references) is still a full Octopus resource and must include all required attributes. The absence of a `package` block does NOT exempt a trigger from the `lifecycle { prevent_destroy = true }` requirement, the ternary lookup requirement for `project_id` and `channel_id`, the `count` convention, or the `depends_on` requirement.

**Negative example — placeholder trigger missing required attributes (VERY COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_my_project_external_feed_trigger" {
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${octopusdeploy_project.project_my_project.id}"        ← WRONG: no ternary guard
  name       = "External Feed Trigger"
  channel_id = "${octopusdeploy_channel.channel_my_project_application.id}"  ← WRONG: no ternary guard
  depends_on = [octopusdeploy_process_steps_order.process_step_order_my_project]
  # WRONG: missing count attribute
  # WRONG: missing lifecycle { prevent_destroy = true }
}
```

**Correct output — placeholder trigger with ALL required attributes**:
```hcl
resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_my_project_external_feed_trigger" {
  count      = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? data.octopusdeploy_projects.project_my_project.projects[0].id : octopusdeploy_project.project_my_project[0].id}"
  name       = "External Feed Trigger"
  channel_id = "${length(data.octopusdeploy_channels.channel_my_project_application.channels) != 0 ? data.octopusdeploy_channels.channel_my_project_application.channels[0].id : octopusdeploy_channel.channel_my_project_application[0].id}"
  depends_on = [octopusdeploy_process_steps_order.process_step_order_my_project]
  lifecycle {
    prevent_destroy = true
  }
}
```

## Tenant Variable Instructions

* If the prompt specified that "octopusdeploy_tenant_project_variable" tenant variables are to be assigned to tenants, and does not specify which environment to define the variable for, you must define the tenant variable for all environments that the tenant is connected to.
* You will be penalized for setting the "environment_id" property on a "octopusdeploy_tenant_project_variable" resource to "null" or an empty string.
* You will be penalized for setting the "template_id" property on a "octopusdeploy_tenant_project_variable" resource to "null" or an empty string.
* The "template_id" property on a "octopusdeploy_tenant_project_variable" resource must be set to a value like "${length(data.octopusdeploy_projects.<project name>.projects) != 0 ? null : octopusdeploy_project.<project name>[0].template[0].id}"

## Environment Instructions

* You will be penalized for defining the "use_guided_infrastructure" property on a resource "octopusdeploy_environment". This property is not valid for any environment and must not be included in any environment resource.

## Octopus Project Channel Instructions

* Channels defined as resource "octopusdeploy_channel" have the following required properties:
    * "name"
    * "project_id"
* Channels can also have a number of optional properties:
    * A "description"
    * An "is_default" property that indicates whether this channel is the default resource. It should be set to "false" unless otherwise specified.
    * A "lifecycle_id"
    * A "rule" block is an optional nested block used to define package versioning rules per deployment step or package.
    * A "space_id"
    * A "tenant_tags" property is a list of strings, used to associate a channel with specific tenant tags
* A project can have multiple "octopusdeploy_channel" resources.
* The "count" attribute for the "octopusdeploy_channel" resource must be set to "${length(data.octopusdeploy_projects.<name>.projects) != 0 ? 0 : 1}" where "<name>" is the name of a data source "octopusdeploy_projects" that matches the name of the project that the channel is associated with.
* Every "octopusdeploy_channel" resource must have an associated "octopusdeploy_channels" data source, for example:
```
data "octopusdeploy_channels" "application" {
  ids          = []
  partial_name = "Application"
  project_id   = "${length(data.octopusdeploy_projects.project_my_argo_cd_webapp.projects) != 0 ? data.octopusdeploy_projects.project_my_argo_cd_webapp.projects[0].id : octopusdeploy_project.project_my_argo_cd_webapp[0].id}"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_channel" "application" {
  # It is important that the "count" attribute references the "octopusdeploy_projects" data source and not the "octopusdeploy_channels" data source.
  count         = "${length(data.octopusdeploy_projects.project_my_argo_cd_webapp.projects) != 0 ? 0 : 1}"
  name          = "Application"
  project_id    = "${length(data.octopusdeploy_projects.project_my_argo_cd_webapp.projects) != 0 ? data.octopusdeploy_projects.project_my_argo_cd_webapp.projects[0].id : octopusdeploy_project.project_my_argo_cd_webapp[0].id}"
  is_default    = true
  lifecycle_id  = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  space_id      = "${trimspace(var.octopus_space_id)}"
}
```


* You will be penalized for defining a "octopusdeploy_channel" resource without an associated "octopusdeploy_channels" data source.
* You will be penalized for having the "count" attribute for the "octopusdeploy_channel" resource reference a "octopusdeploy_channels" data source, for example:

```
resource "octopusdeploy_channel" "channel_my_blue_green_app_hotfixing_hotfix" {
    # This is invalid - it must not reference a data source "octopusdeploy_channels"
    count       = "${length(data.octopusdeploy_channels.channel_my_blue_green_app_hot_fix.channels) != 0 ? 0 : 1}"
}
```

* You will be penalized for referencing a data source "octopusdeploy_projects" that does not exist in the output.
* You will be penalized for creating a "octopusdeploy_project_channel" resource to represent a channel.
* Here is an example of a channel resource without a "rule" block:

```
data "octopusdeploy_projects" "project_lambda_hotfixing" {
  ids          = null
  partial_name = "Lambda Hotfixing"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_channel" "channel_lambda_hotfixing_hotfix" {
  count         = "${length(data.octopusdeploy_projects.project_lambda_hotfixing.projects) != 0 ? 0 : 1}"
  name          = "Hotfix"
  project_id    = "${length(data.octopusdeploy_projects.project_lambda_hotfixing.projects) != 0 ? data.octopusdeploy_projects.project_lambda_hotfixing.projects[0].id : octopusdeploy_project.project_lambda_hotfixing[0].id}"
  description   = "Hotfix channel for Lambda hotfixing"
  is_default    = false
  lifecycle_id  = "${length(data.octopusdeploy_lifecycles.lifecycle_lambda_hotfix.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_lambda_hotfix.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_lambda_hotfix[0].id}"
  space_id      = "${trimspace(var.octopus_space_id)}"
  lifecycle {
    prevent_destroy = true
  }
}
```

* **CRITICAL — every `octopusdeploy_channel` resource MUST include a `lifecycle { prevent_destroy = true }` block.** You will be penalized for defining an `octopusdeploy_channel` resource without this block. This applies to ALL channel resources, including bare named channels created without `rule` blocks (e.g., the "Application" channel for external feed triggers).

**MANDATORY SELF-CHECK before finalizing channels**: Before outputting any `octopusdeploy_channel` resource, verify that it has: (1) a `count` attribute using the project's data source length pattern (`"${length(data.octopusdeploy_projects...) != 0 ? 0 : 1}"`), (2) `project_id` using the ternary lookup pattern, (3) a `lifecycle { prevent_destroy = true }` block. If any of these are missing, correct them before outputting. You will be penalized for each missing attribute.

**Negative example — `octopusdeploy_channel` resource missing `count`, ternary `project_id`, and `lifecycle` (VERY COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_channel" "channel_my_project_application" {
  # WRONG: missing count attribute
  name       = "Application"
  project_id = "${octopusdeploy_project.project_my_project.id}"   # WRONG: direct reference, no ternary guard
  is_default = false
  # WRONG: missing lifecycle { prevent_destroy = true }
}
```

**Correct output — channel with ALL required attributes**:
```hcl
data "octopusdeploy_channels" "channel_my_project_application" {
  ids          = []
  partial_name = "Application"
  project_id   = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? data.octopusdeploy_projects.project_my_project.projects[0].id : octopusdeploy_project.project_my_project[0].id}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_channel" "channel_my_project_application" {
  count      = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"   # REQUIRED
  name       = "Application"
  project_id = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? data.octopusdeploy_projects.project_my_project.projects[0].id : octopusdeploy_project.project_my_project[0].id}"   # REQUIRED: ternary
  is_default = false
  depends_on = [octopusdeploy_process_steps_order.process_step_order_my_project]   # REQUIRED
  lifecycle {
    prevent_destroy = true   # REQUIRED
  }
}
```

* **CRITICAL — every `octopusdeploy_channel` resource associated with an external feed trigger MUST include `depends_on = [octopusdeploy_process_steps_order.<project>]`** to ensure the channel is created after the deployment process is fully configured. Without this dependency, the external feed trigger may be created before the channel is fully associated with the project, causing deployment issues. You will be penalized for omitting `depends_on` from any `octopusdeploy_channel` resource that is referenced by an `octopusdeploy_external_feed_create_release_trigger`.

Here is an example of a channel resource with a "rule" block that applies when the release version matches the tag hotfix (using the regex ^hotfix$), and it targets specific deployment actions (steps):

```
data "octopusdeploy_projects" "project_lambda_hotfixing" {
  ids          = null
  partial_name = "Lambda Hotfixing"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_channel" "channel_lambda_hotfixing_hotfix" {
  count         = "${length(data.octopusdeploy_projects.project_lambda_hotfixing.projects) != 0 ? 0 : 1}"
  name          = "Hotfix"
  project_id    = "${length(data.octopusdeploy_projects.project_lambda_hotfixing.projects) != 0 ? data.octopusdeploy_projects.project_lambda_hotfixing.projects[0].id : octopusdeploy_project.project_lambda_hotfixing[0].id}"
  description   = "Hotfix channel for Lambda hotfixing"
  is_default    = false
  lifecycle_id  = "${length(data.octopusdeploy_lifecycles.lifecycle_lambda_hotfix.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_lambda_hotfix.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_lambda_hotfix[0].id}"
  space_id      = "${trimspace(var.octopus_space_id)}"
  rule {
        action_package {
          deployment_action = "deploy-database-changes"
        }
        action_package {
          deployment_action = "deploy-rate-service"
        }
        action_package {
          deployment_action = "deploy-trading-site"
        }
        tag           = "^hotfix$"
        version_range = ""
    }
  lifecycle {
    prevent_destroy = true
  }
}
```

* Channel version rules must supply a package, for example:

```
resource "octopusdeploy_channel" "channel_every_step_project_hotfix" {
  count       = "${length(data.octopusdeploy_projects.channel_every_step_project_hotfix.projects) != 0 ? 0 : 1}"
  name        = "Hotfix"
  description = "This is an example channel with package version rules"
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  is_default  = false

  rule {

    action_package {
      deployment_action = "Deploy a Helm Chart"
    }

    tag           = "^featurebranch$"
    version_range = "[1.0,)"
  }

  tenant_tags = []
  depends_on  = [octopusdeploy_process_steps_order.process_step_order_every_step_project,octopusdeploy_process_steps_order.process_step_order_every_step_project_example_runbook,octopusdeploy_process_steps_order.process_step_order_every_step_project_runbook_scoped_to_projects_lifecycle_environment,octopusdeploy_process_steps_order.process_step_order_every_step_project_runbook_with_no_environments]
  lifecycle {
    prevent_destroy = true
  }
}
```

* **ABSOLUTE RULE — every `rule` block in an `octopusdeploy_channel` resource MUST have at least one `action_package` block**: The Octopus API enforces this requirement and rejects channels with `rule` blocks that have no `action_package` entries, returning the error "Version rules must specify a package step". If there are no package-based deployment steps to reference (e.g., all steps are `Octopus.KubernetesDeployRawYaml` without package blocks), do NOT add any `rule` block to the channel at all. A channel without a `rule` block is valid and serves as a named channel for triggers.
* **CRITICAL — `octopusdeploy_channel` resources with `rule` blocks MUST include `depends_on` referencing `octopusdeploy_process_steps_order`**: When a channel has a `rule` block with `action_package` entries that reference deployment action slugs, the slugs must already exist before the channel is created. You MUST add `depends_on = [octopusdeploy_process_steps_order.process_step_order_<project>]` to any channel with a `rule` block to ensure the step slugs are available. You will be penalized for omitting `depends_on` from a channel that has `rule` blocks.
* You will be penalized for defining a "octopusdeploy_channel" resource with a "rule" block with an empty version, for example: 

```
resource "octopusdeploy_channel" "channel_dev_deployment_application" {
  count      = "${length(data.octopusdeploy_projects.project_dev_deployment.projects) != 0 ? 0 : 1}"
  name       = "Application"
  project_id = "${length(data.octopusdeploy_projects.project_dev_deployment.projects) != 0 ? data.octopusdeploy_projects.project_dev_deployment.projects[0].id : octopusdeploy_project.project_dev_deployment[0].id}"
  is_default = false
  space_id   = "${trimspace(var.octopus_space_id)}"
  rule {
    tag           = "^master.*"
    version_range = ""
  }
  lifecycle {
    prevent_destroy = true
  }
}
```

## Octopus Global Deployment Freeze Instructions

* You will be penalized for adding the "description" property to the "octopusdeploy_deployment_freeze" resource.
* You will be penalized for adding the "space_id" property to the "octopusdeploy_deployment_freeze" resource.
* The "end" property of the "octopusdeploy_deployment_freeze" resource must be in the future.

## Octopus Deployment Process Instructions

* **CRITICAL — source system parameter references in script bodies must be converted to Octopus variable syntax**: Inline script bodies (in `Octopus.Action.Script.ScriptBody` or kubectl commands) generated from `deleteManifest`, `scaleManifest`, or `runJob` stage types may contain Spring Expression Language (SpEL) expressions that reference pipeline parameters, such as `${ parameters.model_version }`. These expressions use the `${ }` syntax which does NOT evaluate in Octopus Deploy. You MUST convert them to Octopus variable syntax: replace `${ parameters.<name> }` with `#{<name>}`. For example:
  * `${ parameters.model_version }` → `#{model_version}`
  * `${ parameters.namespace }` → `#{namespace}`
  This conversion ensures the script uses the correct Octopus variable reference at runtime. If the script contains any such converted references, add a comment at the top of the script or in the step notes: `# NOTE: Source system parameter references have been converted to Octopus variable syntax (#{variable_name}).`

* **CRITICAL — SpEL expressions in Terraform string values must escape the `$` character**: When a Terraform string value (e.g., in `parameters`, `notes`, or `execution_properties`) must contain a SpEL expression verbatim (because it could not be converted to Octopus variable syntax), the `$` character MUST be escaped as `$$` to prevent Terraform from treating it as a string interpolation sequence. For example, if the prompt contains the notification message text `${execution.name} has started.` and this text cannot be converted, the Terraform string must be `"$${execution.name} has started."`. Do NOT emit `"${execution.name} has started."` as Terraform will attempt to evaluate the expression and produce an error. Where the prompt provides already-converted Octopus variable syntax (e.g., `#{Octopus.Release.Number}`), no escaping is needed — only `${}` patterns require `$$`.

* You must consider the attributes in the "execution_properties" block and the "properties" block of the example steps to be mandatory, unless otherwise specified (the properties on script steps that define inline scripts or those sourced from packages is an example where example properties should not be considered mandatory).
* Every "octopusdeploy_project" resource must have an associated "octopusdeploy_process" resource.
* Every "octopusdeploy_process" resource must have an associated "octopusdeploy_process_steps_order" resource.
* Every "octopusdeploy_process_steps_order" resource must have an associated "octopusdeploy_process_step" resource.
* You will be penalized for not defining steps for a project or runbook.
* Steps are defined in the "octopusdeploy_process_step" and "octopusdeploy_process_child_step" resources.
* The order of the steps are defined in the "octopusdeploy_process_steps_order" resource.
* The order of child steps are defined in the "octopusdeploy_process_child_steps_order" resource.
* If the prompt indicates that a stage was skipped because it was hard-disabled, do not create any placeholder step resource for it and do not include it in the "octopusdeploy_process_steps_order" resource.
* When a skipped or ignored stage is removed from the dependency graph, the Terraform step order must reflect the rewritten dependency chain from the prompt. Do not preserve an order that still assumes the skipped stage exists.
* You will be penalized for using asterisks, for example "*****", as placeholders in step properties.
* The "Octopus.Step.ConditionVariableExpression" property can only be defined in the "properties" block.
* You will be penalized for defining the "Octopus.Step.ConditionVariableExpression" property in the "execution_properties" block.
* The "condition" attribute on an "octopusdeploy_process_step" block must be set to one of the following:
  * "Always"
  * "Failure"
  * "Success"
  * "Variable"
* The same `condition` values apply to `octopusdeploy_process_templated_step` resources — they accept the same valid values as `octopusdeploy_process_step`.
* If the prompt specifies a condition that is not in the list above, you must set the "condition" attribute to "Success".
* **CRITICAL — condition mapping for Slack notification step phrases in the prompt**:
  * When the prompt says `Only run the step when the previous step has failed.` for a step, set `condition = "Failure"` on that step.
  * When the prompt says `Always run the step.` for a step, set `condition = "Always"` on that step.
  * When neither phrase is present (default), set `condition = "Success"` on that step.
  * This mapping applies to both `octopusdeploy_process_step` and `octopusdeploy_process_templated_step` resources.

**Quick reference — condition value mapping table**:

| Prompt phrase | `condition` value |
|---|---|
| `Only run the step when the previous step has failed.` | `"Failure"` |
| `Always run the step.` | `"Always"` |
| *(no condition phrase)* | `"Success"` ← default |
| `Set condition to "Variable"` with expression | `"Variable"` |

**MANDATORY SELF-CHECK — after generating all step resources, verify completeness of `octopusdeploy_process_steps_order`**: Before finalizing any Terraform output, scan every `octopusdeploy_process_step` and `octopusdeploy_process_templated_step` resource you created. For EACH such resource, confirm its ID appears in the `steps` array of the corresponding `octopusdeploy_process_steps_order` resource. If any step resource is missing from the steps order array, add it immediately. This applies to ALL steps including disabled steps, parallel steps, and notification steps. A step resource that exists in Terraform but does not appear in `octopusdeploy_process_steps_order` will not execute at deployment time.

**CRITICAL — "Review template-derived pipeline behavior" step must be the LAST entry in `octopusdeploy_process_steps_order`**: When a `templatedPipeline` project contains a "Review template-derived pipeline behavior" script step, the reference to that step in the `steps` array of `octopusdeploy_process_steps_order` MUST appear as the LAST element. The correct order is: all Slack Notification - Start references, then all deployment stage references, then all Slack Notification - Finish references, then all Slack Notification - Complete references, and finally the "Review template-derived pipeline behavior" reference at the very end. Do NOT place the Review step reference between the Start notification and the Finish/Complete notification references.

**Negative example — Review step placed between Start and Finish in steps order (COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_process_steps_order" "process_step_order_my_project" {
  count      = ...
  process_id = ...
  steps      = [
    octopusdeploy_process_templated_step.process_step_slack_notification_start[0].id,
    octopusdeploy_process_step.process_step_review_template[0].id,          # ← WRONG: before Finish/Complete
    octopusdeploy_process_templated_step.process_step_slack_notification_finish[0].id,
    octopusdeploy_process_templated_step.process_step_slack_notification_complete[0].id,
  ]
}
```

**Correct output** — Review step reference is LAST:
```hcl
resource "octopusdeploy_process_steps_order" "process_step_order_my_project" {
  count      = ...
  process_id = ...
  steps      = [
    octopusdeploy_process_templated_step.process_step_slack_notification_start[0].id,
    octopusdeploy_process_templated_step.process_step_slack_notification_finish[0].id,
    octopusdeploy_process_templated_step.process_step_slack_notification_complete[0].id,
    octopusdeploy_process_step.process_step_review_template[0].id,          # ← CORRECT: last
  ]
}
```
* When the "condition"attribute is set to "Variable", the "properties" block must include the "Octopus.Step.ConditionVariableExpression" property.
* You will be penalized for setting the "condition" attribute to "Variable" without defining the "Octopus.Step.ConditionVariableExpression" property in the "properties" block.
* Adding a step requires a new "octopusdeploy_process_step" resource to be defined and then added to the "octopusdeploy_process_steps_order" resource in the "steps" array. For example, if this is the initial set of steps:

```
data "octopusdeploy_projects" "project_azure_web_app" {
  ids          = null
  partial_name = "My Project"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_project" "project_azure_web_app" {
  count                                = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  name                                 = "My Project"
  # ...
}

resource "octopusdeploy_process" "process_azure_web_app" {
  count      = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? data.octopusdeploy_projects.project_azure_web_app.projects[0].id : octopusdeploy_project.project_azure_web_app[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_steps_order" "process_step_order_azure_web_app" {
  count      = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? null : octopusdeploy_process.process_azure_web_app[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_web_app_validate_setup[0].id}"]
}

resource "octopusdeploy_process_step" "process_step_azure_web_app_validate_setup" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  name                  = "Validate setup"
  # ...
}
```

Then adding a new step called "Deploy an Azure Web App (Web Deploy)" would require the following changes:

```
data "octopusdeploy_projects" "project_azure_web_app" {
  ids          = null
  partial_name = "My Project"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_project" "project_azure_web_app" {
  count                                = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  name                                 = "My Project"
  # ...
}

resource "octopusdeploy_process" "process_azure_web_app" {
  count      = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? data.octopusdeploy_projects.project_azure_web_app.projects[0].id : octopusdeploy_project.project_azure_web_app[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_steps_order" "process_step_order_azure_web_app" {
  count      = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? null : octopusdeploy_process.process_azure_web_app[0].id}"
  # The new step is added to the steps array
  steps      = [
  "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_web_app_validate_setup[0].id}",
  "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_web_app_deploy_web_app[0].id}"
  ]
}

resource "octopusdeploy_process_step" "process_step_azure_web_app_validate_setup" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  name                  = "Validate setup"
  # ...
}

# This is the new step being added
resource "octopusdeploy_process_step" "process_step_azure_web_app_deploy_web_app" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_web_app.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Web App (Web Deploy)"
  # ...
}
```

* The "name" attribute in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource can only contain letters, numbers, periods, commas, dashes, underscores or hashes.
* The "slug" attribute in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource can only contain lower case letters, numbers, or dashes.
* You will be penalized for using asterisks, for example "*****", as placeholders in the "slug" or "name" attributes.
* You must set the "slug" attribute in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource to a value like "step-name" derived from the "name" attribute by converting all letters to lowercase and replacing spaces with dashes.
* The "slug" attribute in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource must NOT start or end with a dash. After replacing spaces and special characters with dashes, you must strip any leading or trailing dashes from the result. For example, a step name "Start -main-" would produce the intermediate slug "start--main-" which after stripping leading/trailing dashes and collapsing consecutive dashes becomes "start-main".
* You will be penalized for generating a "slug" attribute that starts or ends with a dash, such as "start-" or "-deploy".
* The "slug" attribute in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource must be unique across the project.
* The "name" attribute in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource must be unique across the project.
* You must include all the "octopusdeploy_process_step" resources referenced in the "octopusdeploy_process_steps_order" resource "steps" array, for example:
* **MANDATORY SELF-CHECK — step count verification**: Before finalizing the Terraform output, count the number of `octopusdeploy_process_step` and `octopusdeploy_process_templated_step` resources defined. Then count the number of step references in the `octopusdeploy_process_steps_order` `steps` array. These two counts MUST be equal. If any step resource is missing from the `steps` array, or if the `steps` array references a non-existent resource, correct the discrepancy before outputting.

```
data "octopusdeploy_projects" "project_my_app" {
  ids          = null
  partial_name = "My App"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_process_steps_order" "process_step_order_azure_function" {
  count  = "${length(data.octopusdeploy_projects.project_my_app.projects) != 0 ? 0 : 1}"
  steps  = ["${length(data.octopusdeploy_projects.project_my_app.projects) != 0 ? null : octopusdeploy_process_step.process_step_deploy_app[0].id}"]
  # ...
}

resource "octopusdeploy_process_step" "process_step_deploy_app" {
  count  = "${length(data.octopusdeploy_projects.project_my_app.projects) != 0 ? 0 : 1}"
  # ...
}
```

* You will be penalized for defining a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource with a duplicate "slug" attribute within the same project, for example, the following is invalid because the "slug" attribute is duplicated:

```
resource "octopusdeploy_process_step" "step1" {
    slug = "step1"
}

resource "octopusdeploy_process_step" "step2" {
    slug = "step2"
}

resource "octopusdeploy_process_step" "step3" {
    slug = "step1"
}
```

* You will be penalized for defining a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource with a duplicate "name" attribute within the same project, for example, the following is invalid because the "name" attribute is duplicated:

```
resource "octopusdeploy_process_step" "step1" {
    name = "step1"
}

resource "octopusdeploy_process_step" "step2" {
    name = "step2"
}

resource "octopusdeploy_process_step" "step3" {
    name = "step1"
}
```

* You will be penalized for defining a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource with a "name" attribute that contains any characters other than letters, numbers, periods, commas, dashes, underscores or hashes.
* You will be penalized for defining a "name" attribute with the characters "/" and "\".
* Target tags must only be defined in the "Octopus.Action.TargetRoles" properties on a "octopusdeploy_process_step", for example:

```
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_an_azure_web_app__web_deploy_" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy an Azure Web App (Web Deploy)"
  type                  = "Octopus.AzureWebApp"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Note the Octopus.Action.TargetRoles key in the properties attribute which defines the target tags."
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "WebAppPackage", properties = { SelectionMode = "immediate" } }
  package_requirement   = "LetOctopusDecide"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "AzureWebApp"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.UseChecksum" = "False"
      }
}
```

* You will be penalized for using target tags with the format "name=value" in the "target_roles" attribute.
* You will be penalized for adding the "target_roles" attribute on an "action".
* You will be penalized for adding the "excluded_environments" attribute on a "step".
* You will be penalized for adding target tags to the "tenant_tags" attribute.
* When the "Octopus.Action.Script.ScriptSource" property is set to "Package", the "Octopus.Action.Script.Syntax" and "Octopus.Action.Script.ScriptBody" property must not be defined, for example:

```
resource "octopusdeploy_process_step" "process_step_every_step_project_run_a_script_from_a_package" {
  name                  = "Run a Script from a package"
  # The primary_package block is defined because the execution_properties "Octopus.Action.Script.ScriptSource" attribute is set to "Package"
  primary_package       = {
    acquisition_location = "Server"
    feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
    id = null
    package_id = "${var.project_every_step_project_step_run_a_script_from_a_package_packageid}"
    properties = {
        SelectionMode = "immediate"
    }
  }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.Script.ScriptFileName" = "MyScript.ps1"
      }
}
```

* You will be penalized for using the "Octopus.Action.Script.Syntax" or "Octopus.Action.Script.ScriptBody" property when the "Octopus.Action.Script.ScriptSource" property is set to "Package".
* When the "execution_properties" "Octopus.Action.Script.ScriptSource" property is set to "Inline", the "primary_package" property must not be defined in a "octopusdeploy_process_step" resource, for example:

```
resource "octopusdeploy_process_step" "my_step" {
    name = "Open Firewall Port"
    # There is no primary_package block because the "Octopus.Action.Script.ScriptSource" is set to "Inline"
    execution_properties = {
        "Octopus.Action.Azure.AccountId" = "aws-account"
        "Octopus.Action.Script.ScriptBody" = "echo 'hi'"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "OctopusUseBundledTooling" = "False"
    }
}
```

* You will be penalized for using the "primary_package" property when the "Octopus.Action.Script.ScriptSource" property is set to "Inline".
* If the prompt specifies an inline script as well as a script from a package, you must:
    * Ignore the package
    * Not define a "primary_package" block
    * Only define the inline script in the "Octopus.Action.Script.ScriptBody" property in the "execution_properties" block
    * Set the "Octopus.Action.Script.ScriptSource" property to "Inline" in the "execution_properties" block
    * Exclude the "Octopus.Action.Script.Syntax" property in the "execution_properties" block

* You will be penalized for defining a script step with no script.
* Steps of type "Octopus.AzureAppService" must have at least one item in the "target_roles" attribute.
* Steps of type "Octopus.AwsUploadS3" must have a "Octopus.Action.AwsAccount.Variable" property in the "execution_properties" block.
* Steps of the following types must have a "primary_package" block:
   * "Octopus.IIS"
   * "Octopus.AzureWebApp"
   * "Octopus.TentaclePackage"
   * "Octopus.WindowsService"
   * "Octopus.AwsUploadS3"
   * "Octopus.JavaArchive"
   * "Octopus.HelmChartUpgrade"
   * "Octopus.AzureAppService"
* You will be penalized for defining a "packages" block in steps with the types:
   * "Octopus.IIS"
   * "Octopus.AzureWebApp"
   * "Octopus.TentaclePackage"
   * "Octopus.WindowsService"
   * "Octopus.AwsUploadS3"
   * "Octopus.JavaArchive"
   * "Octopus.HelmChartUpgrade"
   * "Octopus.AzureAppService"
* The step of type "Octopus.HelmChartUpgrade" must define a property "Octopus.Action.Helm.ClientVersion" with the value of "V3".
* You will be penalized for adding the property "Octopus.Action.Azure.AccountId" to steps of type "Octopus.AzureWebApp".
* You will be penalized for defining a "version" attribute on the "primary_package" block.
* The "start_trigger" attribute must only be defined once.
* You will be penalized for defining an empty "properties" block, for example "properties = {}".
* You will be penalized for defining a "properties_additional" block.
* You will be penalized for defining multiple "features" attributes.
* You must include the "container" nested child block if one exists for a "octopusdeploy_process_step" resource in the sample Terraform configurations.
* The "container" property is used to define the step's "Container Image".
* Instructions that reference a step's "Container Image" result in the "container" property being defined or edited.
* The "container" property has the following required properties:
    * "feed_id"
    * "image"
* For example here is an example "container" property for a "octopusdeploy_process_step":
```
{
    feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}",
    image = "octopuslabs/aws-workertools"
}
```
* You will be penalized for editing the "packages" block with a prompt that includes details concerning a "Container Image".
* For example, if the prompt asks to set the "Container Image" to "octopuslabs/k8s-workertools", and the sample Terraform defines a step with a package of "nginx", you must edit the "container" property with the specific image, while leaving the "packages" blocks unmodified:
```
resource "octopusdeploy_process_step" "deploy_k8s_yaml" {
  # The prompt asks to set the Container Image to "octopuslabs/k8s-workertools"
  container = {
    feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
    image = "ghcr.io/octopusdeploylabs/k8s-workertools"
  }
  # The packages do not change, so we keep the existing package definition
  packages = {
      nginx = {
          acquisition_location = "NotAcquired"
          feed_id = "${length(data.octopusdeploy_feeds.docker.feeds) != 0 ? data.octopusdeploy_feeds.docker.feeds[0].id : octopusdeploy_docker_container_registry.docker[0].id}"
          id = null
          package_id = "nginx"
          properties = { Extract = "False", Purpose = "DockerImageReference", SelectionMode = "immediate" }
      }
  }
}
```
* The "container" property must have an equals sign "=" after the property name, for example:
```
container = {
    # map properties here
}
```
* You will be penalized for not including the "container" property if one exists in the sample Terraform configurations.
* Steps with actions of the following types must have at least one role defined in the "target_roles" array:
   * "Octopus.AzureWebApp"
   * "Octopus.KubernetesDeployRawYaml"
* The "Octopus.Action.DeployRelease.ProjectId" property for a step of type "Octopus.DeployRelease" must reference the project ID of a project from a data "octopusdeploy_projects", for example:

```
resource "octopusdeploy_process_step" "process_step_orchestrator_project_deploy_a_release" {
  type                  = "Octopus.DeployRelease"
  execution_properties  = {
    "Octopus.Action.DeployRelease.ProjectId" = "${data.octopusdeploy_projects.project_child_project.projects[0].id}"
    ...
  }
  ...
}
```

* You will be penalized for defining a step of type "Octopus.DeployRelease" with a string like "Projects-#" for the "Octopus.Action.DeployRelease.ProjectId" execution property.
* You will be penalized for setting the "container" property on a step when the "Octopus.Action.RunOnServer" property is set to "false".
* Steps of type "Octopus.AwsRunScript" must have the "Octopus.Action.Aws.Region" execution_property defined, for example:

```
resource "octopusdeploy_process_step" "aws_script_step" {
  type                  = "Octopus.AwsRunScript"
  execution_properties  = {
    # The "Octopus.Action.Aws.Region" must be defined
    "Octopus.Action.Aws.Region" = "us-east-1"
  }
}
```

* Steps of type "Octopus.AzureResourceGroup" and "Octopus.AzurePowerShell" must have the "Octopus.Action.Azure.AccountId" property in the execution_properties defined, for example:

```
resource "octopusdeploy_process_step" "azure_resource_group" {
  type                  = "Octopus.AzureResourceGroup"
  execution_properties  = {
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
      }
}
```

* If no Azure account has been specified in the prompt, and a step of type "Octopus.AzureResourceGroup" or "Octopus.AzurePowerShell" is created, you must create an account of type "octopusdeploy_azure_openid_connect" with default settings and assign it to the "Octopus.Action.Azure.AccountId" property in the execution_properties.

* You will be penalized for defining a "Octopus.Action.Azure.AccountId" execution property with an empty string.

* You will be penalized for defining a "primary_package" block when the "Octopus.Action.Script.ScriptSource" execution property is set to "Inline".

* Steps of type "Octopus.Script" must have the "OctopusUseBundledTooling" execution_properties defined, for example:

```
resource "octopusdeploy_process_step" "process_step_child_project_run_a_script" {
  type                  = "Octopus.Script"
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
      }
}
```

* Orchestration or orcestrator projects contain steps of type "Octopus.DeployRelease" that deploy a child project.
* Each "Octopus.DeployRelease" step must have a "Octopus.Action.DeployRelease.ProjectId" execution property and a "primary_package" with the "package_id" set to the child project ID.
* The ID of the child project can be obtained from a data "octopusdeploy_projects" data source.
* The following is an example of a "Octopus.DeployRelease" step that references a data "octopusdeploy_projects" data source for the child project ID and a data "octopusdeploy_feeds" data source for the feed ID:

```
# This data source is used to find an existing parent project by its name.
data "octopusdeploy_projects" "project_every_step_project" {
  ids          = null
  partial_name = "Orchestrator Project"
  skip         = 0
  take         = 1
}

# This data source find the built-in Octopus Server Releases feed.
data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_" {
  feed_type    = "OctopusProject"
  ids          = null
  partial_name = "Octopus Server Releases"
  skip         = 0
  take         = 1
}

# This data source is used to find an existing child project by its name.
data "octopusdeploy_projects" "project_every_step_project" {
  ids          = null
  # Replace this attribute with the name of the project you want to deploy
  partial_name = "Child project name"
  skip         = 0
  take         = 1
}

# This resource creates a step that deploys the child project.
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_release" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Release"
  type                  = "Octopus.DeployRelease"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step is used to deploy a release of a child project."
  package_requirement   = "LetOctopusDecide"
  primary_package       = {
    acquisition_location = "NotAcquired",
    # The feed_id is set to the built-in Octopus Server Releases feed found in the data source
    feed_id = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}",
    id = null,
    # The package_id is set to the child project ID found via the data source
    package_id = "${data.octopusdeploy_projects.project_child_project.projects[0].id}",
    properties = null
  }
  slug                  = "deploy-a-release"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        # The "Octopus.Action.DeployRelease.ProjectId" property is set to the child project ID found via the data source
        "Octopus.Action.DeployRelease.ProjectId" = "${data.octopusdeploy_projects.project_child_project.projects[0].id}"
      }
}
```

* When the prompt says `Set the "Wait for deployment to complete" property to true`, add `"Octopus.Action.DeployRelease.WaitForDeployment" = "True"` to the `execution_properties` block of the `Octopus.DeployRelease` step.
* When the prompt says `Set the "Wait for deployment to complete" property to false`, add `"Octopus.Action.DeployRelease.WaitForDeployment" = "False"` to the `execution_properties` block of the `Octopus.DeployRelease` step.
* When the prompt does not specify a "Wait for deployment to complete" value for a `Octopus.DeployRelease` step, default to `"Octopus.Action.DeployRelease.WaitForDeployment" = "True"`.

* The "Octopus.Action.DeployRelease.ProjectId" and "package_id" properties must reference only a data source.
* You will be penalized for setting the "Octopus.Action.DeployRelease.ProjectId" or "package_id" property to something like `"${length(data.octopusdeploy_projects.project_reporting_microservice.projects) != 0 ? data.octopusdeploy_projects.project_reporting_microservice.projects[0].id : octopusdeploy_project.project_reporting_microservice[0].id}"`
* You will be penalized for setting the "Octopus.Action.DeployRelease.ProjectId" property to a fixed value like "Projects-8916", "Projects-8915", and "Projects-8917".
* You will be penalized for setting the "feed_id" attribute in the "primary_package" block to a fixed value like "Feeds-5936", "Feeds-5678", and "Feeds-91011".
* You must not recreate the following, as these resources and data sources are only used to demonstrate the orchestration project step:
    * data "octopusdeploy_projects" "project_child_project"
    * resource "octopusdeploy_project" "project_child_project"
* You must always include the `data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_"` data source.
* The "feed_id" attribute in the "primary_package" block of a step of type "Octopus.DeployRelease" must always be set to the built-in Octopus Server Releases feed found in the `data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_"` data source.
* The template path for a cloud formation step must be defined in the "Octopus.Action.Aws.CloudFormationTemplate" property in the "execution_properties" block.
* You must only define attributes on "execution_properties" and "properties" blocks that appear in the supplied examples.
* You will be penalized for defining attributes in the "execution_properties" and "properties" blocks that do not exist in the examples.
* You will be penalized for defining properties that start with "Octopus.Action.Aws.CloudFormation" that do not exist in the examples.
* You will be penalized for defining a property in the "execution_properties" block called "Octopus.Action.Aws.CloudFormation.Template".
* You will be penalized for defining a property in the "execution_properties" block called "Octopus.Action.Aws.CloudFormation.TemplateFile".
* You will be penalized for defining a property in the "execution_properties" block called "Octopus.Action.Aws.CloudFormation.TagsEnabled".
* You will be penalized for defining a property in the "execution_properties" block called "Octopus.Action.Aws.CloudFormation.StackName".
* You will be penalized for defining a property in the "execution_properties" block called "Octopus.Action.Manual.ResponsibleUserIds".
* You will be penalized for defining a property in the "execution_properties" block called "Octopus.Action.Manual.Roles".
* You will be penalized for defining the Octopus.Action.Manual.ResponsibleTeamIds" property as an empty string, for example:
```
resource "octopusdeploy_process_step" "process_step_my_azure_web_app_5_manual_intervention" {
  execution_properties  = {
    # An empty string is not a valid value for the "Octopus.Action.Manual.ResponsibleTeamIds" property
    "Octopus.Action.Manual.ResponsibleTeamIds"         = ""
  }
}
```


* You will be penalized for defining multiple "execution_properties" blocks within a single resource.
* The "execution_properties" property must be defined as a map, for example:
```
execution_properties = {
    # Define properties here
}
```
* You will be penalized for defining an "execution_properties" block like this, with "name" and "value" attributes:
```
execution_properties {
  name  = "<some name>"
  value = "<some value>"
}
```
* You will be penalized for defining an "execution_properties" block like this without the equal sign:
```
execution_properties {
}
```
* You will be penalized for defining an "properties" block like this without the equal sign:
```
properties {
}
```
* You will be penalized for defining multiple "execution_properties" blocks within a single resource, for example:
```
execution_properties = {
    # Define properties here
}
execution_properties {
}
```
* You will be penalized for defining multiple "properties" blocks within a single resource, for example:
```
properties = {
    # Define properties here
}
properties {
}
```
* Each "octopusdeploy_community_step_template" resource has a corresponding "octopusdeploy_community_step_template" data source that must be used to check for the existence of the community step template before creating it, for example:
```
data "octopusdeploy_community_step_template" "my_community_step_template" {
  website = "https://library.octopus.com/step-templates/<guid goes here>"
}

resource "octopusdeploy_community_step_template" "my_community_step_template" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.my_community_step_template.steps) != 0 ? data.octopusdeploy_community_step_template.my_community_step_template.steps[0].id : null}"
  count                        = "${length(data.octopusdeploy_community_step_template.my_community_step_template.steps) != 0 ? 0 : 1}"
}
```
* You will be penalized for referencing a "octopusdeploy_step_template" data source "actions" property, for example:
```
 count = "${length(try(data.octopusdeploy_step_template.my_step_template.step_template.actions, [])) != 0 ? 0 : 1}"
```

* You will be penalized for defining both the "environments" and "excluded_environments" attributes in a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource.
* If the prompt defines both environments to include and environments to exclude for a step, you must only define the "environments" attribute.
* You must escape the dollar sign and curly braces in the "Octopus.Action.Azure.ResourceGroupTemplate" property using a double dollar sign, for example:

```
"Octopus.Action.Azure.ResourceGroupTemplate" = "resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {\n  name: 'analytics$${uniqueString(resourceGroup().id)}'
```

* You must escape the dollar sign and curly braces in the "Octopus.Action.Aws.CloudFormationTemplate" property using a double dollar sign, for example:

```
"Octopus.Action.Aws.CloudFormationTemplate" = "AWSTemplateFormatVersion: '2010-09-09'\\nDescription: 'Lambda Blue/Green Deployment'\\nResources:\\n  LambdaFunction:\\n    Type: AWS::Lambda::Function\\n    Properties:\\n      FunctionName: !Sub '$${AWS::StackName}-function'\\n      Runtime: python3.9\\n      Handler: index.handler\\n      Code:\\n        S3Bucket: !Sub '$${Project.AWS.Lambda.S3.BucketName}'\\n        S3Key: 'lambda-function.zip'\\n      Environment:\\n        Variables:\\n          DB_HOST: $${DB_HOST}\\n          API_KEY: $${API_KEY}"

```

* The "Octopus.Action.RunOnServer" property in the "execution_properties" block must be set to "true" steps of type "Octopus.Script" that do not have any target roles.

* You will be penalized for setting the "image" property in the "container" property to an empty string.
* If the prompt indicates that a container image should be used, but does not specify an image name, you must set the "image" property in the "container" property to "octopusdeploy/worker-tools:6.5.0-ubuntu.22.04".
* If the "container" property is defined with a "feed_id" but the prompt does not specify a container image, you must set the "image" property in the "container" property to "octopusdeploy/worker-tools:6.5.0-ubuntu.22.04".
* Additional packages (also known as "referenced packages") are defined in the "packages" block of a "octopusdeploy_process_step" resource, for example:

```
packages = {
    package-id = {
        acquisition_location = "NotAcquired",
        feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}",
        id = null,
        package_id = "${var.project_kubernetes_web_app_step_deploy_a_kubernetes_web_app_via_yaml_package_octopub_selfcontained_packageid}",
        properties = {
            Extract = "False",
            Purpose = "DockerImageReference",
            SelectionMode = "immediate"
        }
    }
}
```

* You will be penalized for only defining the last half of a "packages" block, for example:

```
", id = null, package_id = "mypackage", properties = { SelectionMode = "immediate" } }
```

* You will be penalized for defining values in the "execution_properties" block which are empty strings.
* You will be penalized for defining the "target_roles" property on a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource.
* When the prompt includes instructions to generate a custom script that is not provided by the example configurations, you must use provide a script comprised of comments about the intended functionality and a `echo` or `Write-Host` statement indicating that the script is a placeholder.
* You will be penalized for generating complex scripts for script steps that are not copies of example configurations.
* Using client side apply means the same as disabling server side apply for Kubernetes steps.
* If the prompt includes instructions to enable client side apply for a Kubernetes step, you must set the "Octopus.Action.Kubernetes.ServerSideApply.Enabled" property in the "execution_properties" block to "False".
* Steps of type "Octopus.Manual" must have a "Octopus.Action.Manual.Instructions" property in the "execution_properties" block.
* Steps of type "Octopus.Manual" must set `"Octopus.Action.RunOnServer" = "true"` in the `execution_properties` block.
* Steps of type "Octopus.Manual" must always include `"Octopus.Action.Manual.BlockConcurrentDeployments" = "True"` in the `execution_properties` block. Omitting this property is a common mistake that causes concurrent deployments to proceed past the manual intervention gate without pausing.
* You will be penalized for defining the "Octopus.Step.Manual.Instructions" property in the "execution_properties" block.
* When the prompt defines manual-intervention instructions, the value of "Octopus.Action.Manual.Instructions" must preserve the prompt text exactly. Do not rewrite `${ ... }` SpEL expressions into Octopus `#{...}` syntax, do not normalize punctuation, and do not strip or replace Unicode characters.
* If the prompt appends a NOTE explaining that the instructions contain SpEL expressions, include that NOTE verbatim at the end of the same "Octopus.Action.Manual.Instructions" string. Do not "fix" the embedded expression text.
* You will be penalized for defining a value in the "execution_properties" block with `jsonencode({})` and then ending with a double quote, for example:
`"Octopus.Action.Azure.ResourceGroupTemplateParameters" = jsonencode({})"`
* You must define a value in the "execution_properties" block with `jsonencode({})` without ending with a double quote or new line, for example:
`"Octopus.Action.Azure.ResourceGroupTemplateParameters" = jsonencode({})`
* You will be penalized for defining the "Octopus.Action.Aws.S3.BucketName" value in the "execution_properties" block for a step of type "Octopus.AwsRunCloudFormation".
* You will be penalized for defining both the "excluded_environments" and "environments" attributes on a "octopusdeploy_process_step" or "octopusdeploy_process_child_step" resource.
* You will be penalized for including an incomplete primary_package block, for example:
```
resource "octopusdeploy_process_step" "process_step_serverless_api_9231_deploy_lambda" {
 count                 = "${length(data.octopusdeploy_projects.project_serverless_api_9231.projects) != 0 ? 0 : 1}"
 name                  = "Deploy Lambda"
 type                  = "Octopus.AwsRunScript"
 process_id            = "${length(data.octopusdeploy_projects.project_serverless_api_9231.projects) != 0 ? null : octopusdeploy_process.process_serverless_api_9231[0].id}"
 channels              = null
 condition             = "Success"
 container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", image = "octopuslabs/aws-workertools" }
 environments          = null
 excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
 notes                 = "Deploy Lambda function from S3 package."
 package_requirement   = "LetOctopusDecide"
 # The primary_package block is incomplete
 ", id = null, package_id = "${var.project_serverless_api_9231_step_deploy_lambda_packageid}", properties = { SelectionMode = "immediate" } }
 slug                  = "deploy-lambda"
 start_trigger         = "StartAfterPrevious"
 tenant_tags           = null
 worker_pool_variable  = "Project.WorkerPool"
 
 execution_properties  = {
       "Octopus.Action.Script.ScriptBody" = "Write-Host \"Deploying Lambda function from package\""
       "Octopus.Action.Aws.Region" = "#{AWS_REGION}"
       "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
       "Octopus.Action.RunOnServer" = "true"
       "Octopus.Action.Script.ScriptSource" = "Inline"
       "OctopusUseBundledTooling" = "False"
       "Octopus.Action.Script.Syntax" = "PowerShell"
       "Octopus.Action.Aws.AssumeRole" = "False"
       "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
     }
}
```
* Every item in the "tenant_tags" array must reference a tag defined in a resource "octopusdeploy_tag" and the tag set defined in a resource "octopusdeploy_tag_set".
* Step template and community step template steps must use the "octopusdeploy_process_templated_step" resource.
* You will be penalized for using the "octopusdeploy_process_step" resource for steps that are based on step templates or community step templates.
* You will be penalized for defining a property called "Octopus.Action.Script.FileName" in the execution_properties block of a "octopusdeploy_process_step" resource of type "Octopus.Script". The correct property name is "Octopus.Action.Script.ScriptFileName".
* If the prompt includes instructions to retain the original steps from the sample Terraform configurations, you will be penalized for including comments like "# ... include all original Azure Web App steps here, in order" in place of the original steps.
* Every step defined in a "octopusdeploy_process_steps_order" resource must also be defined as a resource, for example "octopusdeploy_process_step" or "octopusdeploy_process_templated_step".
* You will be penalized for defining a step in a "octopusdeploy_process_steps_order" resource that is not defined as a resource.
* When the prompt includes instructions to add runbooks or steps not found in the template project without explicilt defining the script code, you must only define a script with a single comment in the "Octopus.Action.Script.ScriptBody" property that indicates the intended functionality of the script, for example:

```
resource "octopusdeploy_process_step" "process_step_my_lambda_web_app_swap_loadbalancer" {
  execution_properties  = {
    "Octopus.Action.Script.ScriptBody" = "# This is a placeholder script that would swap load balancers"
  }
}
```
* You will be penalized for generating an example script in the "Octopus.Action.Script.ScriptBody" when the script is not provided in the sample Terraform configurations or in the prompt.
* When the prompt contains instructions to create a script, you must recreate the script code exactly.
* When a prompt defines a container image or other docker image, you must recreate the image name exactly.
* You will be penalized for changing the image name in any way, for example, when hte prompt indicates to use the image "octopusdeploylabs/azure-workertools", you will be penalized for changing it to "octopuslabs/azure-workertools" or "octopusdeploylabs/azure-workertools:latest".
* The name associated with a step must be unique within the process, and must not be the same as any other step name in the process.
* You will be penalized for defining two steps with the same name within a process.
* You will be penalized for writing long "notes" field with unbalanced quotes, for example:
```
resource "octopusdeploy_process_step" "process_step_argo_cd_manifest_update_update_argo_cd_application_manifests" {
  # This is invalid syntax because the notes field does not have a closing quote
  notes                 = "The projects is configured to use the sample application hosted at https://mockgit.octopus.com/repo/argocd in the `octopub-manifest` directory.\n\nThe repo requires credentials, but accepts any username and password, for example:\n\n
}
```
* If the sample project contains a long "notes" field, you must recreate it exactly as it is, including all line breaks and special characters, and ensuring that all quotes are balanced.
* You will be penalized for producing only half of the "notes" attribute.
* The "notes" attribute can contain markdown, for example:
resource "octopusdeploy_process_step" "process_step_argo_cd_manifest_update_update_argo_cd_application_manifests" {
  notes                 = "Here is a code block\n\n```\n# This is some code in a code block\n```"
}

* The step start trigger is defined by the "start_trigger" attribute, and must be set to one of the following values:
  * "StartWithPrevious"
  * "StartAfterPrevious"
* The "StartWithPrevious" setting corresponds with the "Run in parallel with the previous step" option in the UI.
* The "StartAfterPrevious" setting corresponds with the "Wait for all previous steps to complete, then start" option in the UI.
* **CRITICAL — in fork-without-reconvergence pipelines, the `steps` order in `octopusdeploy_process_steps_order` must reflect the fully-linearized branch sequence**: When the prompt describes a fork-without-reconvergence pattern (parallel group of branch roots followed by Branch A continuation steps, then Branch B continuation steps with a migration NOTE), the `steps` array MUST list all Branch A continuation steps BEFORE the first Branch B continuation step. Do NOT interleave Branch A and Branch B continuation steps. The presence of `start_trigger = "StartAfterPrevious"` on both a Branch A continuation and a Branch B continuation does NOT mean they can be reordered — each step's position in the `steps` array must exactly follow the prompt's instruction order.
* A step of type "Octopus.KubernetesDeployRawYaml" with "Octopus.Action.Script.ScriptSource" set to "GitRepository" must define a "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" property. If no file name is specified in the prompt, you must set the "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" property to "custom-resource.yaml".
* You wll be penalized for defining a step of type "Octopus.KubernetesDeployRawYaml" with "Octopus.Action.Script.ScriptSource" set to "GitRepository" and not defining the "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" property.
* **ABSOLUTE RULE — `file_path_filters` MUST be set from the "Set the File Paths to" instruction**: When the prompt includes `Set the File Paths to "<path>"` for a "Deploy Kubernetes YAML" step that uses "Files from a Git repository" as its YAML source, you MUST set `file_path_filters = ["<path>"]` in the `git_dependencies` block. Additionally, set `Octopus.Action.KubernetesContainers.CustomResourceYamlFileName = "<path>"` in the `execution_properties` block using the SAME value. Both `file_path_filters` and `CustomResourceYamlFileName` must reflect the exact file path string from the prompt instruction. Leaving `file_path_filters = null` when the prompt specifies a file path means the GitRepository source will not correctly filter to the specified file — this is a deployment-breaking error.
* **ABSOLUTE RULE — you will be penalized for setting `file_path_filters = null` when the prompt specifies "Set the File Paths to '<path>'"** for a GitRepository-sourced Deploy Kubernetes YAML step. The null value is forbidden whenever a file path instruction is present.

**Example — Deploy Kubernetes YAML step with File Paths instruction**:

Given a prompt instruction: `Set the File Paths to "resource-0172".`

The **CORRECT** Terraform sets both `file_path_filters` and `CustomResourceYamlFileName` to the same value:
```
git_dependencies = { "" = { default_branch = "master", file_path_filters = ["resource-0172"], git_credential_type = "Anonymous", repository_uri = "https://example.invalid/url-0234" } }
execution_properties = {
  "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "resource-0172"
  "Octopus.Action.Script.ScriptSource" = "GitRepository"
  ...
}
```

The **WRONG** Terraform leaves `file_path_filters` as null — FORBIDDEN when a File Paths instruction is present:
```
git_dependencies = { "" = { default_branch = "master", file_path_filters = null, ... } }
```
* If the prompt says `Set the step namespace to "<namespace>".` for a step of type "Octopus.KubernetesDeployRawYaml", you must define `"Octopus.Action.KubernetesContainers.Namespace" = "<namespace>"` in the `execution_properties` block using that exact value.
* A step of type "Octopus.KubernetesDeployRawYaml" with must not set the "Octopus.Action.KubernetesContainers.Namespace" property to an empty string. If the prompt does not specify a namespace, do not define the "Octopus.Action.KubernetesContainers.Namespace" property.
* A step of type "Octopus.KubernetesDeployRawYaml" must have property indented YAML content in the "Octopus.Action.KubernetesContainers.CustomResourceYaml" property if the YAML source is set to "Inline YAML".
* When the prompt provides an inline YAML block for `Octopus.Action.KubernetesContainers.CustomResourceYaml`, copy that YAML content verbatim into the Terraform string while preserving its structure, list items, and indentation. Do not flatten nested keys, regenerate the YAML from a lossy intermediate representation, or remove `image`, `namespace`, `initContainers`, or other fields present in the prompt.
* If the prompt's inline YAML block contains multiple YAML documents separated by standalone `---` lines, keep the ENTIRE multi-document payload in the single `Octopus.Action.KubernetesContainers.CustomResourceYaml` value. Do not split the YAML into multiple Terraform resources, multiple step resources, or separate prompt sections.
* For multi-document inline YAML, preserve the original document order exactly, keep each `---` separator on its own line, and ensure each document restarts its top-level keys at column 0 while maintaining 2-space indentation inside that document.
* For inline YAML copied from the prompt, treat the prompt's indentation as authoritative. Never left-shift nested keys such as `labels`, `annotations`, `containers`, `env`, `ports`, `metrics`, or `scaleTargetRef` to the same column as their parent key.
* If the prompt includes a Deployment document followed by a HorizontalPodAutoscaler document in one inline YAML block, both documents must remain in the same `Octopus.Action.KubernetesContainers.CustomResourceYaml` value and both documents must preserve their own nested indentation after the `---` separator.
* When the prompt explicitly says `The step must be disabled.`, set `is_disabled = true` on the corresponding `octopusdeploy_process_step` or `octopusdeploy_process_templated_step` resource. Do not omit the resource and do not change the step order to compensate.
* **ABSOLUTE RULE — steps whose inline YAML content is a TODO placeholder comment MUST have `is_disabled = true`, regardless of whether the prompt explicitly says "The step must be disabled."**: Whenever the `Octopus.Action.KubernetesContainers.CustomResourceYaml` property value begins with `# TODO:`, you MUST set `is_disabled = true` on that step resource. Do NOT wait for the prompt to say "The step must be disabled." — the presence of a TODO placeholder in YAML is sufficient on its own to require disabling. A disabled step with a TODO YAML body is preserved in the deployment process so engineers can see it, but it will not execute until the TODO is resolved and the step is re-enabled.
* **CRITICAL — "Files from a Git repository" steps MUST NOT be disabled unless the prompt explicitly says so**: When the prompt says `Set the YAML Source to "Files from a Git repository"`, the step does NOT have a TODO placeholder — it has a real git source. Such a step MUST NOT have `is_disabled = true` unless the prompt includes an explicit `The step must be disabled.` instruction. Do NOT apply the `is_disabled = true` rule for TODO placeholders to GitRepository steps — the two cases are distinct. Similarly, the `Octopus.Action.Script.ScriptSource` for a GitRepository step MUST be `"GitRepository"` — NEVER `"Inline"`. Using `"Inline"` for a git-sourced step is forbidden even if the step also has `Octopus.Action.KubernetesContainers.CustomResourceYaml` defined.

**Negative example — GitRepository step incorrectly disabled and using "Inline" ScriptSource (COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_manifest" {
  name        = "Deploy -canary-"
  is_disabled = true  # WRONG: the prompt did not say "The step must be disabled." and there is no TODO YAML
  execution_properties = {
    "Octopus.Action.Script.ScriptSource" = "Inline"  # WRONG: should be "GitRepository" for a git-sourced step
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = ""
    ...
  }
}
```

**Correct output — GitRepository step enabled with correct ScriptSource**:
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_manifest" {
  name        = "Deploy -canary-"
  # No is_disabled — step is enabled by default because it has a real git source
  git_dependencies = { "" = { default_branch = "main", file_path_filters = ["deploy-to-prod-canary.yaml"], git_credential_type = "Anonymous", repository_uri = "https://example.invalid/url-0034" } }
  execution_properties = {
    "Octopus.Action.Script.ScriptSource"                          = "GitRepository"  ← CORRECT
    "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "deploy-to-prod-canary.yaml"
    ...
  }
}
```

**Positive example — disabled step with TODO YAML**:
```hcl
resource "octopusdeploy_process_step" "process_step_my_project_run_job_manifest" {
  name                  = "Run Job -Manifest-"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "${octopusdeploy_process.process_my_project.id}"
  is_disabled           = true   # Required because the YAML content is a TODO placeholder
  condition             = "Success"
  notes                 = "Original stage name: Run Job (Manifest). This step originally loaded its manifest from Google Cloud Storage at gs://example-bucket/path."
  properties = {
    "Octopus.Action.TargetRoles" = "Kubernetes"
  }
  execution_properties = {
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "# TODO: replace with manifest downloaded from gs://example-bucket/path"
    "Octopus.Action.Script.ScriptSource"                     = "Inline"
    "Octopus.Action.RunOnServer"                             = "true"
    "OctopusUseBundledTooling"                               = "False"
  }
}
```

**Negative example — TODO YAML step not disabled (COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_process_step" "process_step_my_project_run_job_manifest" {
  name                  = "Run Job -Manifest-"
  is_disabled           = false  # WRONG: a TODO placeholder YAML step must be disabled
  execution_properties = {
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "# TODO: replace with manifest..."
  }
}
```

**Negative example — TODO YAML step missing `is_disabled` entirely (ALSO A COMMON MISTAKE)**:
```hcl
resource "octopusdeploy_process_step" "process_step_my_project_deploy" {
  name                  = "Deploy"
  type                  = "Octopus.KubernetesDeployRawYaml"
  # WRONG: is_disabled = true is MISSING. Any step with a # TODO: YAML value must have is_disabled = true
  execution_properties = {
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "# TODO: replace with correctly indented multi-document manifest..."
  }
}
```
* You will be penalized for defining the properties "Octopus.Action.GitRepository.ExternalRepositoryUrl" or "Octopus.Action.GitRepository.FilePathFilters" on a step of type "Octopus.KubernetesDeployRawYaml".
* All steps must have a unique name. If two steps have the same name, add a number at the end of the step name to make it unique, for example "Deploy a Kubernetes Web App via YAML 2".
* Any "octopusdeploy_process_templated_step" resource based on the community step template with the URL "https://library.octopus.com/step-templates/99e6f203-3061-4018-9e34-4a3a9c3c3179" (which is the "Slack - Send Simple Notification" community step template) must set "Octopus.Action.RunOnServer" = "true" in the "execution_properties" block.
* **CRITICAL — omit `ssn_Message` when the prompt does not specify a message value**: If the prompt instruction for a Slack notification step does NOT include `Set the "ssn_Message" property to "..."`, do NOT add an `"ssn_Message"` key to the `parameters` block at all. Only include `"ssn_Message"` when the prompt explicitly provides a message string. An absent `ssn_Message` is different from an empty string — do not substitute an empty string placeholder.
* **ABSOLUTE RULE — do NOT add extra Slack notification parameters that are not mentioned in the prompt**: The only parameters to include in a Slack notification `parameters` block are those explicitly mentioned in the step prompt (e.g., `ssn_HookUrl`, `ssn_Channel`, `ssn_Message`). Do NOT add `ssn_IconUrl`, `ssn_Username`, `ssn_Color`, or any other parameter unless the prompt explicitly requests it. Adding unrequested parameters is a common mistake that causes review failures. If the prompt only says `Set the "ssn_HookUrl" property to "..."` and `Set the "ssn_Channel" property to "..."`, the resulting `parameters` block must contain ONLY `ssn_HookUrl` and `ssn_Channel` — nothing else.

**Negative example — extra Slack parameters added without being in the prompt (COMMON MISTAKE AND FORBIDDEN)**:
```hcl
# Prompt only says: Set "ssn_HookUrl" and "ssn_Channel"
parameters = {
  "ssn_HookUrl"  = "#{Project.Slack.WebhookUrl}"
  "ssn_Channel"  = "my-channel"
  "ssn_IconUrl"  = "https://octopus.com/content/resources/favicon.png"  # WRONG: not in prompt
  "ssn_Username" = "Octopus Deploy"                                        # WRONG: not in prompt
  "ssn_Color"    = "good"                                                  # WRONG: not in prompt
}
```

**Correct output — only parameters mentioned in the prompt**:
```hcl
parameters = {
  "ssn_HookUrl" = "#{Project.Slack.WebhookUrl}"
  "ssn_Channel" = "my-channel"
}
```
* It is CRITICAL that the order of the steps in the prompt is maintained in the Terraform configurations. You MUST add each step, one by one, from top to bottom and left to right, as defined in the prompt.
* The following prompt must define the "Slack Notification - Start" step first, then the "Deploy user-profile worker -dev-" step, and then the "Deploy user-track worker -dev-" step, in that specific order, in the "octopusdeploy_process_steps_order" resource:

```
Create a project called "Deploy Workers (dev&prod) and Cronjobs (dev&prod)" in the "Default Project Group" project group with no steps.
* Set the project description to "Deploys all workers except the custom-attribute-backfill worker".
* Add a community step template step with the name "Slack Notification - Start" and the URL "https://library.octopus.com/step-templates/99e6f203-3061-4018-9e34-4a3a9c3c3179" to the start of the deployment process. Set the "ssn_HookUrl" property to "#{Project.Slack.WebhookUrl}". Set the "ssn_Channel" property to "us-release".
* Add a "Deploy Kubernetes YAML" step to the deployment process and name the step "Deploy user-profile worker -dev-". Set the YAML Source to "Inline YAML". Set the YAML content to `# TODO: replace with manifest downloaded from gs://example-bucket/storage-1626`. Set the target tag to Kubernetes. Set the step description to "Original stage name: Deploy user-profile worker (dev). This step originally loaded its manifest from Google Cloud Storage at gs://example-bucket/storage-1626. The manifest must be inlined or the step must be reconfigured to read from a supported source." Set the start trigger to "Run in parallel with the previous step".
* Add a "Deploy Kubernetes YAML" step to the deployment process and name the step "Deploy user-track worker -dev-". Set the YAML Source to "Inline YAML". Set the YAML content to `# TODO: replace with manifest downloaded from gs://example-bucket/storage-1627`. Set the target tag to Kubernetes. Set the step description to "Original stage name: Deploy user-track worker (dev). This step originally loaded its manifest from Google Cloud Storage at gs://example-bucket/storage-1627. The manifest must be inlined or the step must be reconfigured to read from a supported source." Set the start trigger to "Run in parallel with the previous step".
```

* You will be penalized for not maintaining the order of the steps as defined in the prompt in the "octopusdeploy_process_steps_order" resource.
* You must correctly escape dollar signs and curly braces.
* This is an example of an incorrectly escaped value:

```
"ssn_Message" = "*Triggered by:* ${ trigger.user }\n*Container image:* ${ #triggerResolvedArtifactByType(\"docker/image\")[\"reference\"] } (NOTE: Contains SpEL expressions — convert to Octopus variable syntax, e.g. #{Octopus.Deployment.Trigger.Name}, before use)"
```

* This is an example of a correctly escaped value:

```
"ssn_Message" = "*Triggered by:* $${ trigger.user }\n*Container image:* $${ #triggerResolvedArtifactByType(\"docker/image\")[\"reference\"] } (NOTE: Contains SpEL expressions — convert to Octopus variable syntax, e.g. #{Octopus.Deployment.Trigger.Name}, before use)"
```

* **CRITICAL — SpEL expressions MUST be escaped in ALL Terraform string values, not just ssn_Message**: Any Terraform property value (including `notes`, `"Octopus.Action.Manual.Instructions"`, and any other `execution_properties` value) that contains `${...}` SpEL syntax must escape the dollar sign as `$${...}`. Failure to do so causes Terraform to attempt to interpolate the expression and produce a Terraform validation error.
* You will be penalized for generating Terraform where any execution_property value or notes value contains unescaped `${...}` expressions that are not Terraform variables.
* **CRITICAL — when a prompt instruction contains SpEL expressions that have already been converted to Octopus variable syntax (e.g., `#{Octopus.Release.Number}`), do NOT re-escape them as `$${...}`**. Only apply the `$${...}` escaping to SpEL expressions that remain in `${...}` form. Octopus variable syntax using `#{...}` does not require any escaping in Terraform string values.
* **CRITICAL — step descriptions with embedded string content**: When a `notes` attribute value is derived from a prompt instruction containing phrases like `at gs://...` or other path/URL references, do NOT add quotation marks around the URL or path inside the Terraform string value. The URL must appear without surrounding quotes in the `notes` string. For example:
  * **WRONG**: `notes = "This step loaded its manifest from Google Cloud Storage at \"gs://my-bucket/path\". The manifest must be inlined."`
  * **CORRECT**: `notes = "This step loaded its manifest from Google Cloud Storage at gs://my-bucket/path. The manifest must be inlined."`

## Octopus step template instructions

* When the prompt includes instructions to create a community step template and includes a url to https://library.octopus.com/step-templates, you must create both a resource "octopusdeploy_community_step_template" and a data "octopusdeploy_community_step_template" to check for the existence of the community step template before creating it.
* You will be penalized for creating a "octopusdeploy_process_step" resource instead of a "octopusdeploy_community_step_template" resource when the prompt includes instructions to create a community step template.
* The "website" attribute in a data "octopusdeploy_community_step_template" must be copied literally.
* You will be penalized for changing the "website" attribute in a data "octopusdeploy_community_step_template".
* The "properties" attribute must be added to "octopusdeploy_step_template" resources.
* The "id" property in the objects in the "parameters" array must be a GUID.
* You will be penalized for defining an "id" property in the objects in the "parameters" array to plain text like "array-input".
* You will be penalized for including two commas to separate items in the "parameters" array, for example:
```
# This is invalid because there are two commas after the default_sensitive_value property
parameters      = [{ default_sensitive_value = null,, display_settings = { "Octopus.ControlType" = "MultiLineText" }, help_text = "The array to sort", id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890", label = "Array", name = "Array" }]
```

## Octopus Variable Syntax Instructions

* Octopus variable syntax must be defined as "#{<variable name>}"
* You will be penalized for using the syntax "${<variable name>}" for Octopus variables.
* You will be penalized for using the syntax "$<variable name>" for Octopus variables.

## Octopus Variable Instructions

* Variables defined as resource "octopusdeploy_variable" must have a "type" attribute set to one of the following:
  * "AmazonWebServicesAccount"
  * "AzureAccount"
  * "GoogleCloudAccount"
  * "UsernamePasswordAccount"
  * "Certificate"
  * "Sensitive"
  * "String"
  * "WorkerPool"
* You will be penalized for defining the "lifecycle" block on a resource "octopusdeploy_variable".
* You will be penalized for setting the resource "octopusdeploy_variable" "type" attribute to "Token".
* When the "is_sensitive" property on a resource "octopusdeploy_variable" is set to "true", the "type" attribute must be set to "Sensitive".
* When defining the value for a resource "octopusdeploy_variable" with a "type" of "Sensitive", the "sensitive_value" attribute must be set to "CHANGEME", and the "value" attribute must not be defined.
* **CRITICAL — project variables derived from `templatedPipeline` `variables` entries must always use `type = "String"`**: When the prompt says `Add a project variable called "<name>" with the value "<value>"` and the variable originates from a `templatedPipeline` `variables` object, the Terraform variable resource MUST use `type = "String"` regardless of whether the value looks like a boolean (`"true"`, `"false"`), a number (`"15"`, `"900"`), a URL, or any other non-string type. Do NOT use `type = "Boolean"`, `type = "Integer"`, or any other type — all `templatedPipeline` variable values are stored as strings in Octopus. Exception: if the prompt explicitly says `Add a sensitive project variable`, use `type = "Sensitive"` and `is_sensitive = true` instead.
* When the prompt says `Add a sensitive project variable called "<name>" with the description "<description>".`, create a project-scoped `octopusdeploy_variable` resource with `name = "<name>"`, `description = "<description>"`, `type = "Sensitive"`, `is_sensitive = true`, and `sensitive_value = "CHANGEME"`. Do not define a `value` attribute for that variable.
* When the prompt says `Add a sensitive prompted project variable called "<name>" with the description "<description>" and the label "<label>". The variable must be prompted for when creating a release.`, create a project-scoped `octopusdeploy_variable` resource with `name = "<name>"`, `description = "<description>"`, `type = "Sensitive"`, `is_sensitive = true`, `sensitive_value = "CHANGEME"`, and a `prompt` block with `label = "<label>"`, `is_required = true` (or `false` if the prompt says "must not be required"), and `display_settings { control_type = "Sensitive" }`. Do not define a `value` attribute for that variable.

For example, this is a sensitive variable:

```
resource "octopusdeploy_variable" "a_sensitive_variable" {
  count        = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_my_project.projects) == 0 ?octopusdeploy_project.project_my_project[0].id : data.octopusdeploy_projects.project_azure_my_project[0].id}"
  name         = "A.Sensitive.Variable"
  type         = "Sensitive"
  is_sensitive = true
  sensitive_value = "CHANGEME"
}
```

This is an example of a regular variable:

```
resource "octopusdeploy_variable" "azure_function_project_azure_location_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "canadacentral"
  name         = "Project.Azure.Location"
  type         = "String"
  is_sensitive = false
}
```

* You will be penalized for setting the "value" and "sensitive_value" attributes in the same resource "octopusdeploy_variable".
* You will be penalized for setting the "sensitive_value" attribute to anything other than "CHANGEME".
* You will be penalized for assigning an empty scope like "scope {}" to a resource "octopusdeploy_variable".
* You will be penalized for assigning a "scope" block in a resource "octopusdeploy_variable" with all null values, for example:
```
resource "octopusdeploy_variable" "variables_common_settings_apiendpoint_1" {
count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_common_settings.library_variable_sets) != 0 ? 0 : 1}"
owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_common_settings.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_common_settings.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_common_settings[0].id}"
value        = "https://api.example.com"
name         = "ApiEndpoint"
type         = "String"
description  = ""
is_sensitive = false
# This is invalid as all the attributes in the scope block are null
scope {
  actions      = null
  channels     = null
  environments = null
  machines     = null
  roles        = null
  tenant_tags  = null
  processes    = null
}
lifecycle {
  ignore_changes  = [sensitive_value]
  prevent_destroy = true
}
depends_on = []
}
```

* You will be penalized for including more than one resource "octopusdeploy_variable" with the same name.
* The only valid attributes for the "scope" block  for a "octopusdeploy_variable" resource are:
  * "actions"
  * "channels"
  * "environments"
  * "machines"
  * "roles"
  * "tenant_tags"
* You will be penalized for defining "tenants" in the "scope" block for a "octopusdeploy_variable" resource.
* The "tenant_tags" attribute in the "scope" block for a "octopusdeploy_variable" resource must be in the format "Tag Set Name/Tag Name", with two phrases separated by a forward slash, where the first phrase is the tag set name, and the second phrase is the tag name, for example "Region/West". Here is an example of a tenant tag defined for a variable:

```
resource "octopusdeploy_variable" "tag_scoped" {
  scope {
    tenant_tags = ["Region/West"]
  }
}
```

* The "Tag Set Name" in the "tenant_tags" attribute must match the name of a tag set defined in a resource "octopusdeploy_tag_set".
* The "Tag Name" in the "tenant_tags" attribute must match a tag defined in a tag defined in a resource "octopusdeploy_tag".
* Every tag belongs to a tag set.
* If tags were specified in the prompt, but no tag set was specified in the prompt, you must create a tag set of "Default" and assign all tags to that tag set, for example:

```
data "octopusdeploy_tag_sets" "default_tag_set" {
  ids          = null
  partial_name = "Default"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_tag_set" "default_tag_set" {
  name        = "Default"
  description = "The default tag set"
  count       = length(data.octopusdeploy_tag_sets.default_tag_set.tag_sets) != 0 ? 0 : 1
}
```

* You will be penalized for defining a tenant tag in the "tenant_tags" attribute with a single word like "West" or "Enterprise-Client" in the "tenant_tags" attribute in the "scope" block for a "octopusdeploy_variable" resource.
* Variables of type "WorkerPool" must query the hosted worker pool data source first and then the default worker pool data source second. This is done by setting the "value" attribute to "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}", for example:

```
resource "octopusdeploy_variable" "worker_pool_variable" {
  count        = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) == 0 ?octopusdeploy_project.project_kubernetes_web_app[0].id : data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Octopus.Project.WorkerPool"
  type         = "WorkerPool"
  description  = "Using a variable to define the worker pool used by steps allows the worker pool to be easily changed in a central location."
  is_sensitive = false
}
```

* You will be penalized for defining a resource "octopusdeploy_variable" of type "WorkerPool" with the "value" attribute to "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : null}".
* If the prompt includes instructions to create a variable in a library variable set or as a tenant variable, you must not create any project variables with the same name. Custom variables defined in tenants or library variables sets take precedence over project variables.
* You will be penalized for defining a "tenant_id" property in a "octopusdeploy_variable" resource.
* You will be penalized for defining an empty `scope` block for a `octopusdeploy_variable` resource.
* The names of "octopusdeploy_variable" resources must start with a letter or underscore.
* You will be penalized for defining a name for a "octopusdeploy_variable" resource that starts with a number or special character.
* The "label" attribute in a "prompt" block of a "octopusdeploy_variable" resource must be set to an empty string if the prompt should not display a label for the variable.
* You will be penalized for omitting the "label" attribute as an empty string in a "prompt" block of a "octopusdeploy_variable" resource.

## Runbook Instructions

* The "runbook_id" attribute of resource "octopusdeploy_runbook_process" is in the format "${length(data.octopusdeploy_projects.<project>.projects) != 0 ? null : octopusdeploy_runbook.<runbook>[0].id}"
* You will be penalized for creating a "octopusdeploy_runbook" or "octopusdeploy_runbooks" data source as these data sources do not exist.
* The "count" property for a "octopusdeploy_runbook" resource is based on the parent project, for example:
```
data "octopusdeploy_projects" "project_my_project" {
  ids          = null
  partial_name = "My project"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_runbook" "runbook_my_runbook" {
  count                       = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"
}
```

## Worker Pool Instructions

* You must always include the data "octopusdeploy_worker_pools" "workerpool_default_worker_pool", for example:

```
data "octopusdeploy_worker_pools" "workerpool_default_worker_pool" {
  ids          = null
  partial_name = "Default Worker Pool"
  skip         = 0
  take         = 1
}
```

* The "worker_pool_id" attribute must first test the length of the "worker_pools" property exposed by the data source associated with a hosted worker pool, return the first worker pool if the hosted worker pool array is not empty, otherwise return the first worker pool from the default worker pool data source, for example:

```
worker_pool_id = ${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}
```

## Octopus Target Instructions

* Targets must be scoped to at least one environment
* You will be penalized for defining a target with an empty "environments" attribute.
* If a target has no environments specified, the "environments" attribute must include all environments.
* Each resource "octopusdeploy_kubernetes_cluster_deployment_target" must have an associated data "octopusdeploy_deployment_targets". For example, if the following resource is defined:

```
resource "octopusdeploy_kubernetes_cluster_deployment_target" "kubernetes_cluster_target_example" {
  count       = "${length(data.octopusdeploy_deployment_targets.kubernetes_cluster_target_example.deployment_targets) != 0 ? 0 : 1}"
  name        = "Kubernetes Target"
}
```

Then the associated data resource must be defined as follows:

```
data "octopusdeploy_deployment_targets" "kubernetes_cluster_target_example" {
  partial_name         = "Kubernetes Target"
  skip                 = 0
  take                 = 1
}
```

* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_ssh_connection_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_listening_tentacle_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_polling_tentacle_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_cloud_region_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_offline_package_drop_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_azure_cloud_service_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_azure_service_fabric_cluster_deployment_target".
* You will be penalized for defining a "description" attribute on a resource "octopusdeploy_azure_web_app_deployment_target".
* You will be penalized for setting the "machine_policy_id" attribute to an empty string.
* If no machine policy is specified in the prompt for a target, the "machine_policy_id" attribute must be set by looking up the existing machine policy called "Default Machine Policy", for example:

```
data "octopusdeploy_machine_policies" "default_machine_policy" {
  ids          = null
  partial_name = "Default Machine Policy"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_mock_k8s" {
  # The machine policy must be assigned by looking up the existing machine policy called "Default Machine Policy"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
}
```
* If no machine policy is specified in the prompt for a target, you will be penalized for setting the "machine_policy_id" attribute to "MachinePolicies-1" or any other fixed value.
* You will be penalized for defining a block with the name "health_check_container" in a resource "octopusdeploy_kubernetes_cluster_deployment_target". The correct block name is "container".
* The "octopusdeploy_kubernetes_cluster_deployment_target" resource has a container block with no equals sign, for example:
```
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_target" {
  container {
    feed_id = "Feeds-5455"
    image   = "octopusdeploy/worker-tools:6.4.0-ubuntu.22.04"
  }
}
```
* You will be penalized for defining a "conatiner" argument with an equals sign, for example:
```
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_target" {
  # This is invalid because "container" should not have an equals sign
  container = {
    feed_id = "Feeds-5455"
    image   = "octopusdeploy/worker-tools:6.4.0-ubuntu.22.04"
  }
}
```

## Octopus Machine Policy Instructions
* You will be penalized for adding the "tenant_ids" attribute to a resource "octopusdeploy_machine_policies" data source.
* You will be penalized for adding the "environment_ids" attribute to a resource "octopusdeploy_machine_policies" data source.
* You will be penalized for adding the "project_ids" attribute to a resource "octopusdeploy_machine_policies" data source.
* The valid values for the "tentacle_update_behavior" attribute are "NeverUpdate" or "Update" for a "octopusdeploy_machine_policy" resource.
* You will be penalized for setting the "tentacle_update_behavior" attribute to "UpdateAutomatically" for a "octopusdeploy_machine_policy" resource.

## Octopus Account Instructions

* You must set the "token" attribute on a "octopusdeploy_token_account" resource to "CHANGEME".
* If the prompt indicates that an account is associated with a tenant, and the prompt does not specify the project tenanted mode to use, the "tenanted_deployment_participation" property must be set to "TenantedOrUntenanted".
* If the prompt indicates that an account is associated with a tenant, the tenants must be included in the "tenants" attribute of the account resource.
* If the prompt indicates that an account is associated with tenant tags, the tags must be included in the "tenant_tags" attribute of the account resource.
* You must create one distinct "octopusdeploy_aws_openid_connect_account" resource for each AWS OIDC account specified in the prompt.
* You must create one distinct "octopusdeploy_accounts" data source for each "octopusdeploy_aws_openid_connect_account" resource.
* You will be penalized for using a `locals` block to define account names.
* Every "octopusdeploy_aws_openid_connect_account" resource must have an associated "octopusdeploy_accounts" data source with the "account_type" set to "AmazonWebServicesOidcAccount", for example, if the prompt specified that there are two AWS OIDC accounts called "My OIDC Account" and "My other OIDC Account", the following Terraform configuration would be required:

```
resource "octopusdeploy_aws_openid_connect_account" "my_oidc_account" {
  count                             = "${length(data.octopusdeploy_accounts.my_oidc_account.accounts) != 0 ? 0 : 1}"
  name                              = "My OIDC Account"
  description                       = "An AWS OIDC account. See https://octopus.com/docs/infrastructure/accounts/aws for more information. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AmazonWebServicesOidcAccount\". Note the \"role_arn\" property is mandatory for accounts of type \"AmazonWebServicesOidcAccount\"."
  role_arn                          = "arn:aws:iam::381713788115:role/OIDCAdminAccess"
  account_test_subject_keys         = ["space"]
  environments                      = []
  execution_subject_keys            = ["space"]
  health_subject_keys               = ["space"]
  session_duration                  = 3600
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
  }
}

data "octopusdeploy_accounts" "my_oidc_account" {
  ids          = null
  partial_name = "My OIDC Account"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesOidcAccount"
}

resource "octopusdeploy_aws_openid_connect_account" "my_other_oidc_account" {
  count                             = "${length(data.octopusdeploy_accounts.my_other_oidc_account.accounts) != 0 ? 0 : 1}"
  name                              = "My other OIDC Account"
  description                       = "An AWS OIDC account. See https://octopus.com/docs/infrastructure/accounts/aws for more information. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AmazonWebServicesOidcAccount\". Note the \"role_arn\" property is mandatory for accounts of type \"AmazonWebServicesOidcAccount\"."
  role_arn                          = "arn:aws:iam::381713788115:role/OIDCAdminAccess"
  account_test_subject_keys         = ["space"]
  environments                      = []
  execution_subject_keys            = ["space"]
  health_subject_keys               = ["space"]
  session_duration                  = 3600
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
  }
}

data "octopusdeploy_accounts" "my_other_oidc_account" {
  ids          = null
  partial_name = "My other OIDC Account"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesOidcAccount"
}
```

* When the prompt indicates that a step requires an account, the associated account data source and resource must be created.

## Worker Instructions

* The "octopusdeploy_ssh_connection_worker" resources must define the "account_id", "fingerprint", and "host" attributes.
* You will be penalized for supplying empty strings to the "account_id", "fingerprint", and "host" attributes in the "octopusdeploy_ssh_connection_worker" resource.
* If no machine policy is specified in the prompt for a worker, the "machine_policy_id" attribute must be set by looking up the existing machine policy called "Default Machine Policy"
* If no worker pool is specified in the prompt for a worker, you must use a data source to look for an existing worker pool with a suitable name and assign the worker to that worker pool, and if that pool does not exist, create a new worker pool and assign the worker to that worker pool.

## Platform Hub Instructions

* The Platform Hub version control settings are defined in a "octopusdeploy_platform_hub_version_control_username_password_settings" resource.
* You will be penalized for creating a "octopusdeploy_git_credential" in conjuction with a "octopusdeploy_platform_hub_version_control_username_password_settings" resource, unless specifically instructed to do so in the prompt.

## Terraform Instructions
* All resource and data names must start with a character or underscore.
* When resource names are based on a string that starts with a number, for example "123 My Resource", you must prefix the resource name with an underscore, for example " _123_my_resource", "_08_script_project", or "_14_kubernetes_with_mock_target_octopus_project_workerpool_1".
* You will be penalized for creating resource names or data names that start with a number, for example "14_kubernetes_with_mock_target_kubernetes_deployment_name_1" or "14_kubernetes_with_mock_target_octopusprintvariables_1".
* You can only use the following built-in terraform functions:
    * "jsondecode"
    * "jsonencode"
    * "keys"
    * "length"
    * "list"
    * "trim"
    * "trimprefix"
    * "trimspace"
    * "trimsuffix"
    * "try"
* Resource names must be unique per type.
* Data names must be unique per type.
* You will be penalized for defining resources or adding attributes that are not included in the sample Terraform configurations.
* Every resource must have a "count" attribute.
* Each "count" attribute must be defined in the format "${length(data.<data type>.<data resource>.<collection>) != 0 ? 0 : 1}".
* You will be penalized for defining a "count" attribute with the value of "1".
* You will be penalized for using heredoc syntax.
* You must only respond with the Terraform configuration.
* A block starting with "{" and ending with "}" must write each child property on a new line.
* You will be penalized for writing a single line block like this: "lifecycle { ignore_changes = [sensitive_value] prevent_destroy = true }".
* You will be penalized for writing a block starting with "{" and ending with "}" on a single line.
* You must use the password "CHANGEME" for all passwords and secret keys.
* You must use username "CHANGEME" for all usernames.
* You must only create the following types of steps:
  * "Octopus.Script" - Run a Script step
  * "Octopus.AzurePowerShell" - Run an Azure Script step
  * "Octopus.AwsRunScript" - Run an AWS CLI Script step
  * "Octopus.GoogleCloudScripting" - Run gcloud in a Script step
  * "Octopus.AzureResourceGroup" - Deploy an Azure Resource Manager template step
  * "Octopus.KubernetesRunScript" - Run a kubectl script step
  * "Octopus.IIS" - Deploy to IIS step
  * "Octopus.TentaclePackage" - Deploy a Package step
  * "Octopus.WindowsService" - Deploy a Windows Service step
  * "Octopus.AzureWebApp" - Deploy an Azure Web App (Web Deploy) step
  * "Octopus.AwsUploadS3" - Upload a package to an AWS S3 bucket step
  * "Octopus.JavaArchive" - Deploy Java Archive step
  * "Octopus.HelmChartUpgrade" - Deploy a Helm Chart step
  * "Octopus.KubernetesDeployRawYaml" - Deploy Kubernetes YAML step
  * "Octopus.Kubernetes.Kustomize" - Deploy with Kustomize step
  * "Octopus.TerraformApply" - Apply a Terraform template step
  * "Octopus.TerraformDestroy" - Destroy Terraform resources step
  * "Octopus.TerraformPlan" - Plan to apply a Terraform template step
  * "Octopus.TerraformPlanDestroy" - Plan a Terraform destroy step
  * "Octopus.AwsRunCloudFormation" - Deploy an AWS CloudFormation template step
  * "Octopus.AwsApplyCloudFormationChangeSet" - Apply an AWS CloudFormation Change Set step
  * "Octopus.AwsDeleteCloudFormation" - Delete an AWS CloudFormation stack step
  * "Octopus.ArgoCDUpdateImageTags" - Update ArgoCD Image Tags step
  * "Octopus.DeployRelease" - Deploy a Release step
* The "octopusdeploy" provider must set the "space_id" attribute to the value "trimspace(var.octopus_space_id)".
* The Terraform variable "octopus_space_id" must be included, for example:
```
variable "octopus_space_id" {
    type        = string
    nullable    = false
    sensitive   = false
    description = "The ID of the Octopus space to populate."
}
```

* Terraform string interpolation must be implemented as "${}".
* You will be penalized for using two curly brackets for string interpolation like "${{}}".
* Dollar signs in script steps must be escaped with a second dollar sign like "$$", for example:

```
"Octopus.Action.Script.ScriptBody" = "echo $$variable"
```

* Percent signs in script steps must be escaped with a second percent sign like "%%", for example:

```
"Octopus.Action.Script.ScriptBody" = "curl -w \"%%{http_code}\" http://example.org"
```

This is another example using the heredoc syntax:

```
"Octopus.Action.Script.ScriptBody" = <<EOT
    curl -w \"%%{http_code}\" http://example.org
EOT
```

* Script steps that reference variables like "${VARIABLE}" must escape the dollar sign like "$${VARIABLE}", for example:

```
"Octopus.Action.Script.ScriptBody" = "echo $${VARIABLE}"
"Octopus.Action.Azure.ResourceGroupTemplate" = "param location string = resourceGroup().location\nresource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {\n  name: 'octoglobal$${uniqueString(resourceGroup().id)}'\n  location: location\n  sku: {\n    name: 'Standard_LRS'\n  }\n  kind: 'StorageV2'\n}\n"
```

* You must define the "Octopus.Action.TargetRoles" property in the "properties" block for steps that deploy to targets, including steps of type:
    * "Octopus.TentaclePackage"
    * "Octopus.TomcatDeploy"
    * "Octopus.AzureAppService"
    * "Octopus.IIS"
    * "Octopus.WindowsService"
    * "Octopus.AzureWebApp"
    * "Octopus.JavaArchive"
    * "Octopus.HelmChartUpgrade"
    * "Octopus.KubernetesDeployRawYaml"
    * "Octopus.Kubernetes.Kustomize"
    * "Octopus.TransferPackage"

 * You must take EXTREME CARE when escaping quotes in the generated Terraform.
 * This is an example of a property that is not escaped correctly:

 ```
 "ssn_Message" = "Image: $${trigger[\"artifacts\"].?[name == _"registry.example.invalid_image-0095_"][0][_"version_"]}"
 ```

 * This is an example of the same property with correct escaping:

 ```
 "ssn_Message" = "Image: $${trigger[\"artifacts\"].?[name == _\"registry.example.invalid_image-0095_\"][0][_\"version_\"]}"
 ```

## Terraform Variable Instructions

* All terraform variables must have default values, for example:

```
variable "project_group_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "My Project Group"
}
```

* You will be penalized for defining a "scope" block in a terraform variable.
* You will be penalized for defining the "type" in a variable with an value that includes double quotes, for example `type = "string"`. The correct syntax is `type = string` without double quotes.
* You will be penalized for omitting the equals sign between the variable properties and their values, for example:

```
variable "project_group_name" {
  type        = string
  # This is wrong because there is no equals sign between "nullable" and "false"
  nullable     false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "My Project Group"
}

## Penalties and General Instructions

* You will be penalized for creating resources with names that start with a number, for example, a resource named "123_my_resource" or "05_script_project" is invalid.
* You will be penalized for generating invalid Terraform.
* You will be penalized for setting the "space_id" attribute in the "octopusdeploy" provider to a value like "Spaces-1".
* You will be penalized if you include any markdown.
* You will be penalized for including any code blocks.
* You will be penalized for including any instructions.
* You will be penalized for returning any other text.
* You will be penalized for including any comments.
* You will be penalized for using "locals" blocks.
* You will be penalized for using for loops to create resources or data sources.
* You will be penalized for using syntax like `%{ for idx, name in local.names ~}`.
* You will be penalized for using dynamic blocks.
* You will be penalized for using the `replace()` or `lower()` Terraform functions.
* You will be penalized for writing a summary at the end of your response, especially a message around length constraints.
* You will be penalized for duplicating resource names for a resource type, for example, the following terraform is invalid because the resource name "step1" for resource type "octopusdeploy_process_step" is duplicated:

```
resource "octopusdeploy_process_step" "step1" { ... }
resource "octopusdeploy_process_step" "step2" { ... }
resource "octopusdeploy_process_step" "step1" { ... }
```

* You will be penalized for duplicating data names for a data type, for example, the following terraform is invalid because the data name "project1" for data type "octopusdeploy_projects" is duplicated:

```
data "octopusdeploy_projects" "project1" { ... }
data "octopusdeploy_projects" "project2" { ... }
data "octopusdeploy_projects" "project1" { ... }
```

* You will be penalized for not including all required resources and data blocks.
* You will be penalized for stopping the Terraform configuration generation before it is complete.
* You will be penalized for stopping generation mid-resource or mid-block.
* You will be penalized for generating partial configurations that reference undefined resources or data sources.
* You must generate the complete Terraform configuration in a single response.
* You must verify that all opening braces { have corresponding closing braces } before completing your response.
* If you cannot complete the entire configuration due to length constraints, you must prioritize completing the current resource block rather than leaving it incomplete.
* You will be penalized for using syntax like `${var.step_name | lower | replace(" ", "-")}`, as Terraform does not support the pipe character to modify varibale values.
* You will be penalized for leaving any resources out for brevity.
* You must include all requested resources.
* You will be penalized for redacting, anonymizing, or replacing any values (names, namespaces, image references, environment variable values, etc.) with asterisks or placeholders.
* **CRITICAL — disabled steps must be included in `octopusdeploy_process_steps_order` with `is_disabled = true`**: When the prompt says `The step must be disabled.` for a step, that step MUST still appear in the `steps` array of `octopusdeploy_process_steps_order` AND the corresponding `octopusdeploy_process_step` resource MUST have `is_disabled = true`. A disabled step is NOT an omitted step. Omitting a disabled step from the process order is a critical error.

## Git Repository Branch Instructions

* When the prompt says `Set the Repository Branch to "<branch>"` for a "Deploy Kubernetes YAML" step, the `git_dependencies` block of the corresponding `octopusdeploy_process_step` resource MUST set `default_branch = "<branch>"` using the exact branch name from the prompt.
* If the prompt does NOT include a `Set the Repository Branch to` instruction for a step, use `default_branch = "main"` as the default value.
* You will be penalized for setting `default_branch = "main"` when the prompt explicitly specifies a different branch.
* **CRITICAL — each step's `default_branch` must be set INDEPENDENTLY**: In a project with multiple "Deploy Kubernetes YAML" steps, each step may have a DIFFERENT branch. You MUST read the `Set the Repository Branch to` instruction for EACH step individually and apply it to THAT step's `git_dependencies` block only. Do NOT assume all steps in the same project share the same branch. Do NOT copy the branch from one step to another.

**Negative example — branch copied from step 1 to all other steps (FORBIDDEN)**:
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_service" {
  name = "Deploy Service"
  ...
  git_dependencies = { "" = { default_branch = "master", ... } }
}

resource "octopusdeploy_process_step" "process_step_deploy_worker" {
  name = "Deploy Worker"
  ...
  # WRONG: "master" was copied from step 1, but the prompt said Set the Repository Branch to "develop" for this step
  git_dependencies = { "" = { default_branch = "master", ... } }
}
```

**Correct output — each step uses its own branch from the prompt**:
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_service" {
  name = "Deploy Service"
  ...
  git_dependencies = { "" = { default_branch = "master", ... } }   # prompt said: Set the Repository Branch to "master"
}

resource "octopusdeploy_process_step" "process_step_deploy_worker" {
  name = "Deploy Worker"
  ...
  git_dependencies = { "" = { default_branch = "develop", ... } }  # prompt said: Set the Repository Branch to "develop"
}
```

**Example — step prompt with explicit branch**:

Given a step prompt:
```
* Add a "Deploy Kubernetes YAML" step ... Set the Repository URL to "https://example.invalid/url-0001". Set the File Paths to "deploy/app.yaml". Set the Repository Branch to "master". Set the target tag to Kubernetes.
```

The **CORRECT** Terraform includes `default_branch = "master"`:
```
git_dependencies {
  default_branch         = "master"
  git_credential_type    = "Anonymous"
  repository_uri         = "https://example.invalid/url-0001"
  file_path_filters      = ["deploy/app.yaml"]
}
```

The **WRONG** Terraform defaults to "main" and ignores the prompt:
```
git_dependencies {
  default_branch         = "main"
  git_credential_type    = "Anonymous"
  repository_uri         = "https://example.invalid/url-0001"
  file_path_filters      = ["deploy/app.yaml"]
}
```

## Prompted Variable Select Options Instructions

* When the prompt includes `The variable must have the following selectable options: <option1>, <option2>, ...` for a project variable, the corresponding `octopusdeploy_variable` resource MUST use `control_type = "Select"` in its `display_settings` block and MUST include one `select_option` block for each option.
* Each `select_option` block must set both `display_name` and `value` to the option string from the prompt.

## Prompted Variable (Non-Select) Instructions

* When the prompt includes `The variable must be prompted for when creating a release.` WITHOUT a selectable options instruction, the `octopusdeploy_variable` resource MUST include a `prompt` block with `control_type = "SingleLineText"` in `display_settings`. **CRITICAL EXCEPTION**: When the variable has `type = "Sensitive"` and `is_sensitive = true` (i.e., the prompt says `Add a sensitive prompted project variable`), the `prompt` block MUST use `control_type = "Sensitive"` instead of `"SingleLineText"`. This is MANDATORY — you will be penalized for using `control_type = "SingleLineText"` on a prompted variable that also has `is_sensitive = true`.
* When the prompt says `The variable must be required.`, set `is_required = true` in the `prompt` block.
* When the prompt says `The variable must not be required.`, set `is_required = false` in the `prompt` block.
* The `description` attribute in the `prompt` block must match the variable description from the prompt instruction.
* The `label` attribute in the `prompt` block must match the label from the prompt instruction.
* **IMPORTANT — when the prompt specifies a label that equals the variable name**: This is the correct behavior when the original `parameterConfig` entry had an empty `label` field — the variable name is used as a fallback label. In Terraform, set `label = "<variable name>"` using the exact variable name string. Do NOT set an empty string for label in this case.

**Example — sensitive prompted variable with `control_type = "Sensitive"` (REQUIRED)**:

Given a prompt:
```
* Add a sensitive prompted project variable called "apiToken" with the description "API authentication token" and the label "API Token". The variable must be prompted for when creating a release. The variable must be required.
```

The **CORRECT** Terraform uses `type = "Sensitive"`, `is_sensitive = true`, `sensitive_value = "CHANGEME"`, and `control_type = "Sensitive"`:
```hcl
resource "octopusdeploy_variable" "variable_apitoken" {
  name            = "apiToken"
  type            = "Sensitive"
  description     = "API authentication token"
  is_sensitive    = true
  sensitive_value = "CHANGEME"
  prompt {
    description = "API authentication token"
    label       = "API Token"
    is_required = true
    display_settings {
      control_type = "Sensitive"
    }
  }
}
```

The **WRONG** output (uses `SingleLineText` on a sensitive variable — FORBIDDEN):
```hcl
  prompt {
    display_settings {
      control_type = "SingleLineText"   ← WRONG for sensitive variables
    }
  }
```

**Example — prompted variable whose label equals the variable name (empty label fallback)**:

Given a prompt:
```
* Add a project variable called "dryRun", with the description "dry run without making changes", and the label "dryRun". The variable must be prompted for when creating a release. The variable must not be required. The variable must have the following selectable options: false, true.
```

The **CORRECT** Terraform uses `label = "dryRun"` (same as the variable name):
```hcl
resource "octopusdeploy_variable" "variable_dryrun" {
  name         = "dryRun"
  type         = "String"
  description  = "dry run without making changes"
  value        = "false"
  is_sensitive = false
  prompt {
    description = "dry run without making changes"
    label       = "dryRun"
    is_required = false
    display_settings {
      control_type = "Select"
      select_option {
        display_name = "false"
        value        = "false"
      }
      select_option {
        display_name = "true"
        value        = "true"
      }
    }
  }
}
```

**Example — prompted string variable without selectable options**:

Given a prompt:
```
* Add a project variable called "key", with a default value of "", the description "Identifier of the job", and the label "Job Key". The variable must be prompted for when creating a release. The variable must be required.
```

The **CORRECT** Terraform:
```
resource "octopusdeploy_variable" "variable_key" {
  count        = "${length(data.octopusdeploy_projects.project_my_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_my_project.projects) == 0 ? octopusdeploy_project.project_my_project[0].id : data.octopusdeploy_projects.project_my_project.projects[0].id}"
  name         = "key"
  type         = "String"
  description  = "Identifier of the job"
  value        = ""
  is_sensitive = false
  prompt {
    description = "Identifier of the job"
    label       = "Job Key"
    is_required = true
    display_settings {
      control_type = "SingleLineText"
    }
  }
}
```

The **WRONG** output (missing `prompt` block — the variable is not prompted for during release creation):
```
resource "octopusdeploy_variable" "variable_key" {
  ...
  name  = "key"
  type  = "String"
  value = ""
  # WRONG: no prompt block, so this variable won't be prompted during release creation
}
```
* Preserve the option order from the prompt exactly.
* When the prompt includes an option named `(none)`, generate a `select_option` block with `display_name = "(none)"` and `value = ""`. The value MUST be an empty string `""` — do NOT use `"_none_"` or any other placeholder. Do NOT ignore or skip `(none)` options — they represent a valid empty-string choice for non-required variables.
* You will be penalized for generating `value = "_none_"` — use `value = ""` for the `(none)` option.
* Ignore any empty option strings that are NOT represented as `(none)` in the prompt (i.e., empty strings that were never included in the prompt in the first place).
* The top-level `description` attribute on `octopusdeploy_variable` MUST be set to the variable description from the prompt instruction. This is separate from the `description` field inside the `prompt` block. Both must be populated with the same value. Omitting the top-level `description` attribute is a bug.
* If the prompt does NOT include a selectable options instruction, use `control_type = "SingleLineText"` in the `display_settings` block (the default).
* You will be penalized for using `control_type = "SingleLineText"` when the prompt specifies selectable options.
* You will be penalized for omitting any `select_option` block when selectable options are specified.

**Example — prompted variable with selectable options**:

Given a prompt:
```
* Add a project variable called "account-purpose", with a default value of "", the description "account purpose name", and the label "account-purpose". The variable must be prompted for when creating a release. The variable must not be required. The variable must have the following selectable options: wakai, mercoin, escrow, partner_invoice.
```

The **CORRECT** Terraform uses `control_type = "Select"` and includes `select_option` blocks:
```
resource "octopusdeploy_variable" "variable_account_purpose" {
  ...
  description = "account purpose name"
  prompt {
    description = "account purpose name"
    label       = "account-purpose"
    is_required = false
    display_settings {
      control_type = "Select"
      select_option {
        display_name = "wakai"
        value        = "wakai"
      }
      select_option {
        display_name = "mercoin"
        value        = "mercoin"
      }
      select_option {
        display_name = "escrow"
        value        = "escrow"
      }
      select_option {
        display_name = "partner_invoice"
        value        = "partner_invoice"
      }
    }
  }
}
```

**Example — non-required selectable variable with `(none)` option (empty-string choice)**:

Given a prompt:
```
* Add a project variable called "isretry", with a default value of "-is_retry=true", the description "Whether this is a retry run", and the label "Is Retry". The variable must be prompted for when creating a release. The variable must not be required. The variable must have the following selectable options: (none), -is_retry=true.
```

The **CORRECT** Terraform includes a `select_option` with `value = ""` for the `(none)` entry:
```hcl
resource "octopusdeploy_variable" "variable_isretry" {
  name         = "isretry"
  type         = "String"
  description  = "Whether this is a retry run"
  value        = "-is_retry=true"
  is_sensitive = false
  prompt {
    description = "Whether this is a retry run"
    label       = "Is Retry"
    is_required = false
    display_settings {
      control_type = "Select"
      select_option {
        display_name = "(none)"
        value        = ""
      }
      select_option {
        display_name = "-is_retry=true"
        value        = "-is_retry=true"
      }
    }
  }
}
```

## Step Description Notes from Runtime Artifact Binding

* When the prompt says `Set the step description to "NOTE: This step originally required the following Docker images to be bound at runtime: ..."`, the description note MUST be set in the `notes` property of the `octopusdeploy_process_step` resource with the exact verbatim text from the prompt.
* If the step already has an `notes` entry for another reason (e.g., the stage name contained special characters), the two description texts must be concatenated, separated by a space, in the same `notes` property.
* Preserve the comma-separated Docker image list exactly as it appears in the prompt. Do not reorder the images, do not deduplicate them, and do not redact registry names, repositories, tags, or quotes.

## Step Count Validation

**ABSOLUTE RULE — the number of `octopusdeploy_process_step` resources MUST equal the number of non-notification steps described in the prompt**: Before finalizing your Terraform output, count the step prompts in the prompt (lines beginning with `* Add a "..."` or `* Add a community step template step`) and verify that you have created exactly the same number of `octopusdeploy_process_step` (or `octopusdeploy_process_templated_step`) resources. If the count differs, you have either missed a step or created a duplicate — both are bugs that MUST be corrected.

**MANDATORY STEP UNIQUENESS CHECK**: Scan all `octopusdeploy_process_step` resource names in your Terraform output. If two resources have names ending in `_2`, `_3`, etc., verify that these correspond to steps in the prompt whose step NAMES are actually duplicated (e.g., two steps both named "Deploy -Manifest-"). If a `_2` suffix was added to a step whose prompt name is unique (different from all other step names), the suffix is wrong — use the step's actual unique name without the suffix.

## Ordering of Parallel Steps in `octopusdeploy_process_steps_order`

**CRITICAL — all steps in a parallel group must be CONSECUTIVE in `octopusdeploy_process_steps_order`**: In Octopus Deploy, `start_trigger = "StartWithPrevious"` means "start at the same time as the immediately preceding step in the list." For this to work correctly, all members of a parallel group MUST be adjacent (consecutive) in the `steps` array of `octopusdeploy_process_steps_order`. If a parallel group has members {A, B, C} and they are placed as A, B, [other step], C in the steps order, step C will run in parallel with [other step], not with A — which is wrong.

**CRITICAL — duplicate step IDs in `octopusdeploy_process_steps_order` are FORBIDDEN**: Each step ID must appear exactly once in the `steps` array. If a prompt describes N steps, the `steps` array must contain exactly N elements. Having N+k elements (more than the prompt's steps) indicates that N steps from the prompt were duplicated, which is a bug.

**CRITICAL — the `steps` array order in `octopusdeploy_process_steps_order` must EXACTLY match the step order from the prompt, left-to-right**: Every step must appear at the position corresponding to its order in the prompt. In fork-without-reconvergence scenarios, where Branch A continuation steps are listed before Branch B continuation steps, the `steps` array must preserve this same ordering. Do NOT reorder steps based on topological or dependency analysis — reproduce the prompt's ordering verbatim.

**Negative example — duplicate steps in process_steps_order (FORBIDDEN)**:
```hcl
# WRONG: "deploy_cronjob_x" and "deploy_cronjob_x_2" both appear, but there is only ONE step named "Deploy cronjob-x" in the prompt
steps = [
  "${octopusdeploy_process_step.process_step_deploy_cronjob_x.id}",      # step 1
  "${octopusdeploy_process_step.process_step_deploy_cronjob_x_2.id}",    # step 2 ← DUPLICATE
]
```

**CORRECT output** (each step appears once):
```hcl
# CORRECT: each unique step from the prompt appears exactly once
steps = [
  "${octopusdeploy_process_step.process_step_deploy_cronjob_x.id}",      # appears once only ✓
]
```

## Step Names Must Match Prompt Exactly

**CRITICAL — the `name` attribute of each `octopusdeploy_process_step` MUST reproduce verbatim the step name from the prompt**: When the prompt says `name the step "Deploy cronjob-docomo-point-reconcile"`, the Terraform must contain `name = "Deploy cronjob-docomo-point-reconcile"`. Do NOT append ` 2`, ` 3`, or any suffix unless the prompt itself contains that suffix in the step name.

**Negative example — suffix added to a step name that is unique in the prompt (FORBIDDEN)**:
```hcl
# Prompt says: name the step "Deploy cronjob-docomo-point-reconcile-sweep-days"
# WRONG: suffix added even though this name is unique in the prompt
resource "octopusdeploy_process_step" "process_step_deploy_cronjob_docomo_point_reconcile_sweep_days_2" {
  name = "Deploy cronjob-docomo-point-reconcile-sweep-days 2"  ← WRONG: should be without " 2"
  ...
}
```

**CORRECT output** (name matches prompt exactly):
```hcl
resource "octopusdeploy_process_step" "process_step_deploy_cronjob_docomo_point_reconcile_sweep_days" {
  name = "Deploy cronjob-docomo-point-reconcile-sweep-days"  ← CORRECT: verbatim from prompt
  ...
}
```

## `notes` Attribute Must Reproduce Step Descriptions Verbatim

**CRITICAL — the `notes` attribute must reproduce the step description from the prompt verbatim, including any migration NOTEs about concurrent execution**: When the prompt says `Set the step description to "NOTE (migration): In the original pipeline, this step ran concurrently with ..."`, the `notes` value MUST include that text exactly as written. Do NOT omit the migration NOTE or summarize it. Do NOT redact service names, stage names, or namespace values that appear in the description.

**CRITICAL — migration NOTEs from expression-based checkPreconditions stages must be preserved verbatim in the `notes` attribute**: When the prompt includes a step description starting with `NOTE (migration): This step was originally gated by an expression-based checkPreconditions stage...` or `NOTE (migration): This step was originally on a conditional branch controlled by an expression-based checkPreconditions stage...`, the entire NOTE text must appear verbatim in the `notes` attribute of the corresponding `octopusdeploy_process_step` resource. Do NOT omit, truncate, or paraphrase the expression NOTE.

**CRITICAL — never redact names in `notes` fields**: Service names, stage names, namespace names, Kubernetes resource names, and GCS bucket paths that appear in the step description must all be reproduced verbatim in the `notes` attribute. The presence of words like `api`, `auth`, `key`, `token`, `secret`, `service`, or `credential` in a description does NOT make those words sensitive — they are resource identifiers that must be preserved exactly.

## Slack Notification Step: Reproducing Explicit `ssn_Color` Instructions

When the prompt explicitly says `Set the "ssn_Color" property to "danger"` (or any other value), the `parameters` block of the corresponding `octopusdeploy_process_templated_step` MUST include `"ssn_Color" = "danger"` (or the specified value). This is consistent with the general rule that all prompt-specified parameters must be reproduced.

**CRITICAL — when the prompt says `Set the "ssn_Color" property to "danger"`, reproduce it exactly in the `parameters` block.** Do NOT substitute a different value or omit it.

```hcl
resource "octopusdeploy_process_templated_step" "process_step_my_project_slack_notification_finish" {
  condition = "Failure"
  ...
  parameters = {
    "ssn_Color"   = "danger"   ← CORRECT: verbatim from prompt — "Set the ssn_Color property to danger"
    "ssn_HookUrl" = "#{Project.Slack.WebhookUrl}"
    "ssn_Channel" = "my-channel"
  }
}
```

**NOTE**: Do NOT add `ssn_Color` unless the prompt explicitly mentions it. The prompt controls whether `ssn_Color` appears. If the prompt does not say `Set the "ssn_Color" property to "..."`, omit `ssn_Color` from the `parameters` block entirely.

## Disabled TODO Script Steps (patchManifest and Unknown Stage Types)

When the prompt includes a "Run a Script" step that must be disabled (i.e., the prompt contains `The step must be disabled.`), the generated `octopusdeploy_process_step` resource MUST include `is_disabled = true`. This applies to:

* `patchManifest` stage TODO steps (which always must be disabled)
* Any other stage type where the prompt says the step must be disabled

**CRITICAL — `is_disabled = true` is REQUIRED when the prompt says `The step must be disabled.`**: Do not omit this attribute.

```hcl
resource "octopusdeploy_process_step" "process_step_patch_manifest_my_service" {
  name          = "Patch -Manifest- my-service"
  type          = "Octopus.Script"
  process_id    = "${octopusdeploy_process.process_my_project[0].id}"
  is_disabled   = true    ← REQUIRED when prompt says "The step must be disabled."
  condition     = "Success"
  start_trigger = "StartAfterPrevious"
  execution_properties = {
    "Octopus.Action.RunOnServer"         = "true"
    "OctopusUseBundledTooling"           = "False"
    "Octopus.Action.Script.ScriptSource" = "Inline"
    "Octopus.Action.Script.Syntax"       = "PowerShell"
    "Octopus.Action.Script.ScriptBody"   = <<-EOT
      # TODO: convert Spinnaker patchManifest stage — no direct Octopus Deploy equivalent.
      # Target resource: deployment my-service
      # Namespace: my-namespace
      # Merge strategy: strategic
      # Patch body:
      # spec:
      #   template:
      #     spec:
      #       containers:
      #         - name: my-service
      #           env:
      #             - name: FEATURE_FLAG
      #               value: "#{feature_flag}"
    EOT
  }
  properties = {}
}
```

## `octopusdeploy_process_step` `properties` Block for Server-Side Script Steps

Server-side "Run a Script" steps (`Octopus.Script`) that are generic TODO placeholders (not targeting a specific Kubernetes cluster) do NOT need `"Octopus.Action.TargetRoles"` in the `properties` block. These steps run on the Octopus server worker pool, not on a Kubernetes target.

* For `Octopus.Script` steps that are generic TODO placeholders (e.g., `patchManifest` conversions, unknown stage type placeholders): use `properties = {}` (empty map) and do NOT include `"Octopus.Action.TargetRoles"`.
* For `Octopus.KubernetesRunScript` steps (e.g., `deleteManifest`, `scaleManifest`, `undoRolloutManifest`): use `properties = { "Octopus.Action.TargetRoles" = "Kubernetes" }`.

**Negative example — adding TargetRoles to a generic TODO script step (UNNECESSARY)**:
```hcl
resource "octopusdeploy_process_step" "..." {
  type = "Octopus.Script"
  properties = {
    "Octopus.Action.TargetRoles" = "Kubernetes"   ← WRONG for generic Octopus.Script TODO steps
  }
}
```

**Correct output** (generic TODO script step has empty properties):
```hcl
resource "octopusdeploy_process_step" "..." {
  type       = "Octopus.Script"
  properties = {}   ← CORRECT for server-side generic script steps
}
```

## `octopusdeploy_variable` Prompt Block for Prompted Variables with Select Options

When the prompt says `The variable must have the following selectable options: <option1>, <option2>, ...`, the `octopusdeploy_variable` resource must include a `prompt` block with a `display_settings` block using `control_type = "Select"` and one `select_option` sub-block per option.

```hcl
resource "octopusdeploy_variable" "my_project_limit_credit_1" {
  owner_id     = "${octopusdeploy_project.my_project[0].id}"
  name         = "limit_credit"
  type         = "String"
  value        = "false"
  is_sensitive = false

  prompt {
    label       = "limit_credit"
    is_required = true

    display_settings {
      control_type = "Select"

      select_option {
        display_name = "false"
        value        = "false"
      }
      select_option {
        display_name = "true"
        value        = "true"
      }
    }
  }
  lifecycle {
    ignore_changes = [sensitive_value]
  }
  depends_on = []
}
```

**CRITICAL — `control_type = "Select"` is REQUIRED when the prompt says the variable must have selectable options.** Do not use `control_type = "SingleLineText"` or omit the `display_settings` block when the prompt explicitly lists selectable options.
* Words such as `api`, `server`, `worker`, `web`, `auth`, `gateway`, `proxy`, `backend`, `frontend`, `key`, `token`, `service`, `manager`, `scheduler`, `cache`, `queue`, `db` are NOT secrets, API keys, or credentials and MUST NOT be replaced with asterisks (`*****`) or any other anonymization placeholder.