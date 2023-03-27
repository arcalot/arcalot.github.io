# Running Arcaflow

Before you proceed, you will need to perform the following steps:

1. [Download and configure Arcaflow](setup.md)
2. Create a YAML file with your workflow input data (e.g. `input.yaml)

=== "Linux/MacOS"
    
    ```
    /path/to/arcaflow -input path/to/input.yaml
    ```

=== "Windows"

    ```
    c:\path\to\arcaflow.exe -input path/to/input.yaml
    ```

You can pass the following additional options to Arcaflow:

| Option                           | Description                                                                    |
|----------------------------------|--------------------------------------------------------------------------------|
| `-config /path/to/config.yaml`   | Set an Arcaflow configuration file. (See the [configuration guide](setup.md).) |
| `-context /path/to/workflow/dir` | Set a different workflow directory. (Defaults to the current directory.)       |
| `-workflow workflow.yaml`        | Set a different workflow file. (Defaults to `workflow.yaml`.)                  |

## Execution

Once you start Arcaflow, it will perform the following three phases:

1. It will start all plugins using your local deployer (see the [configuration guide](setup.md)), load their schemas, and then stop the plugins.

!!! Note
    The loading phase **only** reads the plugin schemas; it does not run any of the functional steps of the plugins.

2. It will execute the workflow.
3. Once the workflow execution is complete, it will output the resulting data.

!!! tip
    You can redirect the standard output to capture the output data and still read the log messages on the standard error.