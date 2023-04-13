# Flow control (in development)

The workflow contains several flow control operations. These flow control operations are not implemented by plugins, but are part of the workflow engine itself.

## Abort

The abort flow control is a quick way to exit out of a workflow. This is useful when entering a terminal error state and the workflow output data would be useless anyway.

```mermaid
stateDiagram-v2
  [*] --> Step1
  Step1 --> Abort: Output 1
  Step1 --> Step2: Output 2
  Step2 --> [*]
```

However, this is only required if you want to abort the workflow immediately. If you want an error case to result in the workflow failing, but whatever steps can be finished being finished, you can leave error outputs unconnected.

## Do-while

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

## Condition

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

## Multiply

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

## Synchronize

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