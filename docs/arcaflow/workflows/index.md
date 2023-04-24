# Creating Arcaflow workflows

Arcaflow workflows consist of three parts:

<h2>Inputs</h2>

The input section of a workflow is much like a plugin schema: it describes the data model of the workflow itself. This is useful because the input can be validated ahead of time. Any input data can then be referenced by the individual plugin steps.

[Learn more about inputs &raquo;](input.md){ .md-button }

<h2>Steps</h2>

Steps hold the individual parts of the workflow. You can feed data from one step to the next, or feed data from the input to a step.

[Learn more about steps &raquo;](step.md){ .md-button }

<h2>Outputs</h2>

Outputs hold the final result of a workflow. Outputs can reference outputs of steps.

[Learn more about output &raquo;](output.md){ .md-button }