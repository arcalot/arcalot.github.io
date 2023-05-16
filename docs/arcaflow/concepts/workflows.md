# Arcaflow Workflows (concept)

!!! tip
    This document describes the *concept* of Arcaflow Workflows. We describe the process of writing a workflow [in this section](../workflows/index.md)

## Steps

Workflows are a way to describe a sequence or parallel execution of individual steps. The steps are provided exclusively by plugins. The simplest workflow looks like this:

```mermaid
stateDiagram-v2
  [*] --> Step
  Step --> [*]
```

However, this is only true if the step only has one output. Most steps will at least have two possible outputs, for success and error states:

```mermaid
stateDiagram-v2
  [*] --> Step
  Step --> [*]: yes
  Step --> [*]: no
```

Plugins can declare as many outputs as needed, with custom names. The workflow engine doesn't make a distinction based on the names, all outputs are treated equal for execution.

An important rule is that one step must always end in exactly one output. No step must end without an output, and no step can end in more than one output. This provides a mechanism to direct the flow of the workflow execution.

Plugins must also explicitly declare what parameters they expect as input for the step, and the data types of these and what parameters they will produce as output.

## Interconnecting steps

When two steps are connected, they will be executed after each other:

```mermaid
stateDiagram-v2
  Step1: Step 1
  Step2: Step 2
  [*] --> Step1
  Step1 --> Step2
  Step2 --> [*]
```

Similarly, when two steps are not directly connected, they may be executed in parallel:

```mermaid
stateDiagram-v2
  Step1: Step 1
  Step2: Step 2
  [*] --> Step1
  [*] --> Step2
  Step1 --> [*]
  Step2 --> [*]
```

You can use the interconnection to direct the flow of step outputs:

```mermaid
stateDiagram-v2
  Step1: Step 1
  Step2: Step 2
  Step3: Step 3
  [*] --> Step1
  Step1 --> Step2: success
  Step1 --> Step3: error
  Step2 --> [*]
  Step3 --> [*]
```

## Passing data between steps 

When two steps are connected, you have the ability to pass data between them. Emblematically described:

```mermaid
stateDiagram-v2
  Step1: Step 1
  Step2: Step 2
  [*] --> Step1
  Step1 --> Step2: input_1 = $.steps.step1.outputs.success
  Step2 --> [*]
```

The data type of the input on Step 2 in this case must match the result of the expression. If the data type does not match, the workflow will not be executed.

## Undefined inputs

Step inputs can either be required or optional. When a step input is required, it must be configured or the workflow will fail to execute. However, there are cases when the inputs cannot be determined from previous steps. In this case, the workflow start can be connected and the required inputs can be obtained from the user when running the workflow:

```mermaid
stateDiagram-v2
  Step1: Step 1
  Step2: Step 2
  [*] --> Step1
  [*] --> Step2: input_1 = $.input.option_1
  Step1 --> Step2: input_2 = $.steps.step1.outputs.success
  Step2 --> [*]
```

This is typically the case when credentials, such as database access, etc. are required.

## Outputs

The output for each step is preserved for later inspection. However, the workflow can explicitly declare outputs. These outputs are usable in scripted environments as a direct output of the workflow:

```mermaid
stateDiagram-v2
  [*] --> Step
  Step --> [*]: output_1 = $.steps.step1.outputs.success
```

!!! tip "Background processes"
    Each plugin will only be invoked once, allowing plugins to run background processes, such as server applications. The plugins must handle SIGINT and SIGTERM events properly.

## Flow control (WIP)

The workflow contains several flow control operations. These flow control operations are not implemented by plugins, but are part of the workflow engine itself.

### Foreach

The foreach flow control allows you to loop over a sub-workflow with a list of input objects.

```mermaid
stateDiagram-v2
  [*] --> ForEach
  state ForEach {
    [*] --> loop_list_input
    loop_list_input --> sub_workflow
    sub_workflow --> loop_list_input
    state sub_workflow {
      [*] --> Step1
      Step1 --> [*]
    }
    sub_workflow --> [*]: Sub Output
  }
  ForEach --> [*]: Output
```

!!! warning
    The features below are in-development and not yet implemented in the released codebase.

### Abort

The abort flow control is a quick way to exit out of a workflow. This is useful when entering a terminal error state and the workflow output data would be useless anyway.

```mermaid
stateDiagram-v2
  [*] --> Step1
  Step1 --> Abort: Output 1
  Step1 --> Step2: Output 2
  Step2 --> [*]
```

However, this is only required if you want to abort the workflow immediately. If you want an error case to result in the workflow failing, but whatever steps can be finished being finished, you can leave error outputs unconnected.

### Do-while

A do-while block will execute the steps in it as long as a certain condition is met. The condition is derived from the output of the step or steps executed inside the loop:

```mermaid
stateDiagram-v2
  [*] --> DoWhile
  state DoWhile {
    [*] --> Step1
    Step1 --> [*]: output_1_condition=$.step1.output_1.finished == false   
  }
  DoWhile --> [*]
```

If the step declares multiple outputs, multiple conditions are possible. The do-while block will also have multiple outputs:

```mermaid
stateDiagram-v2
  [*] --> DoWhile
  state DoWhile {
    [*] --> Step1
    Step1 --> [*]: Output 1 condition
    Step1 --> [*]: Output 2 condition   
  }
  DoWhile --> [*]: Output 1
  DoWhile --> [*]: Output 2
```

You may decide to only allow exit from a loop if one of the two outputs is satisfied:

```mermaid
stateDiagram-v2
  [*] --> DoWhile
  state DoWhile {
    [*] --> Step1
    Step1 --> Step1: Output 1
    Step1 --> [*]: Output 2
  }
  DoWhile --> [*]: Output 1
```

### Condition

A condition is a flow control operation that redirects the flow one way or another based on an expression. You can also create multiple branches to create a switch-case effect.

```mermaid
stateDiagram-v2
  state if_state <<choice>>
  Step1: Step 1
  [*] --> Step1
  Step1 --> if_state
  Step2: Step 2
  Step3: Step 3
  if_state --> Step2: $.step1.output_1 == true
  if_state --> Step3: $.step1.output_1 == false
```

### Multiply

The multiply flow control operation is useful when you need to dynamically execute sub-workflows in parallel based on an input condition. You can, for example, use this to run a workflow step on multiple or all Kubernetes nodes.

```mermaid
stateDiagram-v2
  Lookup: Lookup Kubernetes hosts
  [*] --> Lookup
  Lookup --> Multiply
  state Multiply {
    [*] --> Stresstest
    Stresstest --> [*]
  }
  Multiply --> [*]
```

The output of a Multiply operation will be a map, keyed with a string that is configured from the input.

!!! tip
    You can think of a Multiply step like a for-each loop, but the steps being executed in parallel.

### Synchronize

The synchronize step attempts to synchronize the execution of subsequent steps for a specified key. The key must be a constant and cannot be obtained from an input expression.

```mermaid
stateDiagram-v2
  [*] --> Step1
  [*] --> Step2
  Synchronize1: Synchronize (key=a)
  Synchronize2: Synchronize (key=a)
  Step1 --> Synchronize1
  Step2 --> Synchronize2
  Synchronize1 --> Step3
  Synchronize2 --> Step4
  Step3 --> [*]
  Step4 --> [*]
```