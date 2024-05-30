# Creating Arcaflow workflows

Arcaflow workflows consist of four parts:


<h2>Version</h2>

The schema version must be at the root of your workflow file. It indicates the semantic version of the workflow file structure being used.

[Learn more about versioning &raquo;](versioning.md){ .md-button }

<h2>Inputs</h2>

The input section of a workflow is much like a plugin schema: it describes the data model of the workflow itself. This is useful because the input can be validated ahead of time. Any input data can then be referenced by the individual plugin steps.

[Learn more about inputs &raquo;](input.md){ .md-button }

<h2>Steps</h2>

Steps hold the individual parts of the workflow. You can feed data from one step to the next, or feed data from the input to a step.

[Learn more about steps &raquo;](step.md){ .md-button }

<h2>Outputs</h2>

Outputs hold the final result of a workflow. Outputs can reference outputs of steps.

[Learn more about output &raquo;](output.md){ .md-button }

<h2>Schema Names</h2>

[Learn more about our schema naming conventions &raquo;](schemas.md){ .md-button }