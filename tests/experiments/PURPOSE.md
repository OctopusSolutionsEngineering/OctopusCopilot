This directory holds tests that function as experiments. Unlike unit tests, it is expected that some of these tests
fail to demonstrate scenarios that push the boundaries of the LLM or are hard to verify in an automated fashion.
The files in this directory do not end with the suffix "_test" so they wre not run automatically by the CI/CD pipelines.

"Dynamic" tests refer to those that query a live Octopus instance. They are a quick way to verify the performance of
the LLM with a large set of realistic data.

Dynamic tests are based on the idea of querying data across dimensions:

* A one-dimensional query returns the properties of a single resource, like a project's description or a target's role.
* A two-dimensional query returns the result of the intersection between two resources, like the roles associated with
  an environment or targets associated with a project.
* A three-dimensional query returns the result of the intersection between three resources, like the targets associated
  with a project and environment, or certificates associated with a tenant and environment.
* And so on.

"Static" tests refer to those that use static data. They test assumptions about how LLMs use data and respond to
different prompts.

# Running the tests in PyCharm

The issue at
https://intellij-support.jetbrains.com/hc/en-us/community/posts/360000024199-Python-SubTest?utm_source=pocket_saves
describes how to configure PyCharm to display the output of subtests individually.