# Writing your first Python plugin

In this guide you will learn how to write a basic "Hello World" plugin for Arcaflow and then run it without the engine as a standalone tool. In order to proceed this tutorial, you will need to install Python version 3.9 or higher on your machine. The tutorial will make use of the [Arcaflow Python SDK](https://github.com/arcalot/arcaflow-plugin-sdk-python) to provide the required functionality.

## Step 1: Setting up your environment

If you have Python installed, you will need to set up your environment. You can use any dependency manager you like, but here are three methods to get you started quickly.

!!! note "Official plugins"
    If you wish to contribute an official Arcaflow plugin on GitHub, please use Poetry. For simplicity, we only accept Poetry plugins.


=== "From the template repository"

    1. Clone or download the [template repository](https://github.com/arcalot/arcaflow-plugin-template-python)
    2. Figure out what the right command to call your Python version is:
           ```
           python3.10 --version
           python3.9 --version
           python3 --version
           python --version
           ```
       Make sure you have at least Python 3.9.
    3. Create a [virtualenv](https://virtualenv.pypa.io/en/latest/) in your project directory using the following command, replacing your Python call:
           ```
           python -m venv venv
           ```
    4. Activate the venv:
           ```
           source venv/bin/activate
           ```
    5. Install the dependencies:
           ```
           pip install -r requirements.txt
           ```

=== "Using pip"

    1. Create an empty folder.
    2. Create a `requirements.txt` with the following content:
           ```
           arcaflow-plugin-sdk
           ```
    3. Figure out what the right command to call your Python version is:
           ```
           python3.10 --version
           python3.9 --version
           python3 --version
           python --version
           ```
       Make sure you have at least Python 3.9.
    4. Create a [virtualenv](https://virtualenv.pypa.io/en/latest/) in your project directory using the following command, replacing your Python call:
           ```
           python -m venv venv
           ```
    5. Activate the venv:
           ```
           source venv/bin/activate
           ```
    6. Install the dependencies:
           ```
           pip install -r requirements.txt
           ```
    7. Copy the [example plugin](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/arcaflow_plugin_template_python/example_plugin.py), [example config](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/example.yaml) and the [tests]https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/tests/test_example_plugin.py) to your directory.

=== "Using Poetry"

    1. Assuming you have [Poetry](https://python-poetry.org) installed, run the following command:
           ```
           poetry new your-plugin
           ```
       Then change the current directory to `your-plugin`.
    2. Figure out what the right command to call your Python version is:
           ```
           which python3.10
           which python3.9
           which python3
           which python
           ```
       Make sure you have at least Python 3.9.
    3. Set Poetry to Python 3.9:
           ```
           poetry env use /path/to/your/python3.9
           ```
    4. Check that your `pyproject.toml` file has the following lines:
           ```toml
           [tool.poetry.dependencies]
           python = "^3.9"
           ```
    4. Add the SDK as a dependency:
           ```
           poetry add arcaflow-plugin-sdk
           ```
    5. Copy the [example plugin](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/arcaflow_plugin_template_python/example_plugin.py), [example config](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/example.yaml) and the [tests]https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/tests/test_example_plugin.py) to your directory.
    6. Activate the venv:
           ```
           poetry shell
           ```

Now you are ready to start hacking away at your plugin! You can open the `example_plugin.py` file and follow along, or you can create a new Python file and write the code.

## Step 2: Creating an input and output data model

Plugins in Arcaflow must explain how they want their input data and what kind of output they produce. Let's start with the input data model. In our case, we want to ask the user for a name. Normally, you would write this in Python:

```python title="plugin.py"
def hello_world(name):
    return f"Hello, {name}"
```

However, **that's not how the Arcaflow SDK works**. You must always specify the *data type* of any variable. Additionally, every function can only have **one input** and it must be a **dataclass**.

So, let's change the code a little:

```python title="plugin.py"
import dataclasses


@dataclasses.dataclass
class InputParams:
    name: str
    
def hello_world(params: InputParams):
    # ...
```

So far so good, but we are not done yet. The output also has special rules. One plugin function can have more than one possible output, so you need to say which output it is and you need to also return a dataclass.

For example:

```python title="plugin.py"
import dataclasses


@dataclasses.dataclass
class InputParams:
    name: str
    
    
@dataclasses.dataclass
class SuccessOutput:
    message: str

    
def hello_world(params: InputParams):
    return "success", SuccessOutput(f"Hello, {params.name}")
```

!!! tip
    If your plugin has a problem, you could create and return an `ErrorOutput` instead. In the Arcaflow workflow you can then handle each output separately. 

## Step 3: Decorating your step function

Of course, Arcaflow doesn't know what to do with this code yet. You will need to add a decorator to the `hello_world` function in order to give Arcaflow the necessary information:

```python title="plugin.py"
from arcaflow_plugin_sdk import plugin


@plugin.step(
    id="hello-world",
    name="Hello world!",
    description="Says hello :)",
    outputs={"success": SuccessOutput},
)
def hello_world(params: InputParams):
    # ...
```

Let's go through the parameters:

* `id` provides the step identifier. If your plugin provides more than one step function, you need to specify this in your workflow.
* `name` provides the human-readable name of the plugin step. This will help render a user interface for the workflow.
* `description` is a longer description for the function and may contain line breaks.
* `outputs` specifies the possible outputs and the dataclasses associated with these outputs. This is important so Arcaflow knows what to expect.

!!! tip
    If you want, you can specify the function return type like this, but Arcaflow won't use it:
    ```python
    def hello_world(params: InputParams) -> typing.Tuple[str, ...]:
    ```
    Unfortunately, Python doesn't give us a good way to extract this information, so it's safe to skip.

## Step 4: Running the plugin

There is one more piece missing to run a plugin: the calling code. Add the following to your file:

```python title="plugin.py"
import sys
from arcaflow_plugin_sdk import plugin


if __name__ == "__main__":
    sys.exit(
        plugin.run(
            plugin.build_schema(
                # List your step functions here:
                hello_world,
            )
        )
    )
```

Now your plugin is ready. You can [package it up for a workflow](../packaging.md), or you can run it as a standalone tool from the command line:

```
python example_plugin.py -f input-data.yaml
```

You will need to provide the input data in YAML format:

```yaml title="input-data.yaml"
name: Arca Lot
```

!!! tip
    If your plugin provides more than one step function, you can specify the correct one to use with the `-s` parameter.

!!! tip
    To prevent output from breaking the functionality when attached to the Arcaflow Engine, the SDK hides any output your step function writes to the standard output or standard error. You can use the `--debug` flag to show any output on the standard error in standalone mode.

!!! tip
    You can generate a JSON schema file for your step input by running
    
    ```
    python example_plugin.py --json-schema input >example.schema.json
    ```
    
    If you are using the [YAML plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml), add the following line to the top of your input file for code completion:
        ```yaml
        # yaml-language-server: $schema=example.schema.json
        ```

## Next steps

In order to create an actually useful plugin, you will want to [create a data model for your plugin](data-model.md). Once the data model is complete, you should look into [packaging your plugin](../packaging.md).