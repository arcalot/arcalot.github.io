# Releasing Your Python Plugin

Turning your plugin into a Python package is one requirement for it to become an official Arcaflow Python Plugin.

## Python Project without Plugin Template

### New Project

=== "Poetry"

    Create your [Python Project with Poetry](https://python-poetry.org/docs/master/basic-usage/), `plugin-project`[^1], and change directory into the project root. You should see a directory structure similar to this with the following files.

    ```
    $ poetry new plugin-project
    Created package plugin_project in plugin-project

    $ tree plugin-project
    plugin-project
    ├── plugin_project
    │   └── __init__.py
    ├── pyproject.toml
    ├── README.md
    └── tests
        └── __init__.py

    2 directories, 4 files

    $ cd plugin-project
    ```

    Ensure `python3` is at least 3.9.

    ```
    $ python3 --version
    Python 3.9.15
    ```

    If `python3` is at least version 3.9, then determine its path.

    ```
    $ which python3
    /usr/bin/python3
    ```

    Set Poetry to use your Python that is at least 3.9.

    ```
    poetry env use /usr/bin/python3
    ```

    Alternativley,

    ```
    poetry env use $(which python3)
    ```

    Check that your `pyproject.toml` is using at least Python 3.9 by looking for the following line.

    ```toml
    [tool.poetry.dependencies]
    python = "^3.9"
    ```

    Add the [arcaflow plugin sdk for python](https://github.com/arcalot/arcaflow-plugin-sdk-python) as a software dependency for your Python project.

    ```
    poetry add arcaflow-plugin-sdk-python
    ```

    You should now have a `poetry.lock` file in your project root. Poetry maintains the state of your `pyproject.toml`, and its exact software dependencies as hashes in the `poetry.lock` file.


=== "Without Poetry"

    Create your Python Project, `plugin-project`, and its sub-directories, the package's main module directory, `plugin_project`[^1], and the `tests` directory, and then change directory into the project root.

    ```
    $ mkdir --parent plugin-project/{plugin_project,tests}
    $ cd plugin-project
    ```

    Turn your sub-directories into Python modules.

    ```
    touch {plugin-project,tests}/__init__.py
    ```

    Create your `pyproject.toml` to track your project's software dependencies and build system dependencies.

    ```
    touch pyproject.toml
    ```

    Ensure you have at least Python 3.9.

    ```
    python --version
    Python 3.9.15
    ```

    Create a Python virtual environment named `.venv`.

    ```
    python -m venv .venv
    ```

    Activate the Python virtual environment, `.venv`.

    ```
    source .venv/bin/activate
    ```

    Install the minimum plugin dependencies.

    ```
    pip install arcaflow-plugin-sdk
    ```

### Initializing a Pre-Existing Project

Assuming your pre-existing project is named `plugin-project`, and contains the sub-directories `plugin_project`, and `tests`, on your local file system.

=== "Poetry"

    Follow Poetry's command line interface wizard's prompts to create your `pyproject.toml`. Don't forget to add the Arcaflow Python Plugin SDK as a software dependency, `arcaflow-plugin-sdk`. At the time of writing, the progressing through the wizard should look approximately like this.

    ```
    $ poetry init

    This command will guide you through creating your pyproject.toml config.

    Package name [my-first-plugin]:
    Version [0.1.0]:
    Description []:
    Author:  A. Robot Programmer
    License []:
    Compatible Python versions [^3.9]:

    Would you like to define your main dependencies interactively? (yes/no) [yes] yes
    ...

    Package to add or search for (leave blank to skip): arcaflow-plugin-sdk
    Found 20 packages matching arcaflow-plugin-sdk
    Showing the first 10 matches

    Enter package # to add, or the complete package name if it is not listed []:
    [ 0] arcaflow-plugin-sdk
    [ 1] arcaflow
    [ 2] arcaflow-lib-kubernetes
    [ 3] plugin-sdk-automation
    [ 4] tracardi-plugin-sdk
    [ 5] laniakea-plugin-sdk
    [ 6] dce-plugin-sdk
    [ 7] python-plugin-sdk
    [ 8] ayx-plugin-sdk
    [ 9] PlugSy
    [10]
    > 0
    Enter the version constraint to require (or leave blank to use the latest version):
    Using version ^0.10.1 for arcaflow-plugin-sdk

    ```


=== "Without Poetry"

    Create your `pyproject.toml` to track your project's software dependencies and build system dependencies.

    ```
    touch pyproject.toml
    ```

    Manually fill out your `pyproject.toml`. Use [PyPa's guide to configuring pyproject.toml for setuptools](https://setuptools.pypa.io/en/latest/userguide/pyproject_config.html).

### Validate Dependencies in Virtual Environment

Change into the root directory of your plugin project.

=== "Poetry"

    Start your project's Python virtual environment.

    ```
    $ poetry shell
    Spawning shell within ~/.cache/pypoetry/virtualenvs/plugin-project-8vZa8fhA-py3.9
    ```

    Start an interactive Python session, and import `arcaflow_plugin_sdk`.

    ```
    $ python3
    Python 3.9.15 (main, Aug  9 2022, 13:32:42) [GCC 12.1.1 20220507 (Red Hat 12.1.1-1)] on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import arcaflow_plugin_sdk
    ```

    If there are no errors, then the plugin sdk has been successfully imported.

=== "Without Poetry"

    Start your project's Python virtual environment.

    ```
    $ source .venv/bin/activate
    ```

    Start an interactive Python session, and import `arcaflow_plugin_sdk`.

    ```
    $ python3
    Python 3.9.15 (main, Aug  9 2022, 13:32:42) [GCC 12.1.1 20220507 (Red Hat 12.1.1-1)] on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import arcaflow_plugin_sdk
    ```

    If there are no errors, then the plugin sdk has been successfully imported.


## Python Project from [Plugin Template]((https://github.com/arcalot/arcaflow-plugin-template-python))

### Create the Plugin Package

1. Fulfill requirements.
      1. Python 3.9
2. Fork, then clone the [template repository](https://github.com/arcalot/arcaflow-plugin-template-python).
3. Change into the template repository directory.
4. Plugin starting directory structure.

    ```
    $ tree .
    .
    └── arcaflow-plugin-template-python        <- GitHub repo
    ├── arcaflow_plugin_template_python    <- Python module
    │   └── example_plugin.py
    ├── docker-compose.yaml
    ├── Dockerfile
    ├── example.yaml
    ├── LICENSE
    ├── poetry.lock
    ├── pyproject.toml
    ├── README.md
    ├── requirements.txt
    └── tests
        └── test_example_plugin.py
    ```
5. Rename the following with your desired package name[^1].

      1. GitHub repo
      2. README title
      3. Python module

      4. `package` variable in `Dockerfile`
      ```Dockerfile
      ENV package arcaflow_plugin_template_python
      ```

      5. Image source label in `Dockerfile` with your repository's URL.
      ```Dockerfile
      LABEL org.opencontainers.image.source="https://github.com/arcalot/arcaflow-plugin-template-python"
      ```

      6. Image name in `docker-compose.yaml`
      ```yaml
      version: '3.2'
      services:
      plugin:
      image: arcaflow-plugin-template    <-
      build: .
      volumes:
      - source: ./example.yaml
        target: /config/example.yaml
        type: bind
      ```

      7.  Plugin module import in your `tests`.
      ```python
      #!/usr/bin/env python3
      import unittest
      from arcaflow_plugin_template_python import example_plugin
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      ```

### Create Package Virtual Environment

=== "Poetry"

    1. Fulfill requirements.
        1. Poetry 1.2

    2. Rename the Python package in your `pyproject.toml` with your desired package name[^1].

        ```toml
        [tool.poetry]
        name = "arcaflow-plugin-template-python"        <-
        version = "0.1.0"
        description = ""
        authors = ["Arcalot"]
        license = "Apache-2.0+GPL-2.0-only"
        ...
        ```

    3. Set this package's Python virtual environment to use your Python 3.9.

        ```
        $ poetry env use $(which python3)
        ```

    4. Install the software dependencies from `poetry.lock`.

        ```
        $ poetry install
        ```

    5. Activate the Python virtual environment.

        ```
        $ poetry shell
        ```

=== "Without Poetry"

    1. Create [pyproject.toml](https://setuptools.pypa.io/en/latest/userguide/pyproject_config.html).

    2. Configure `pyproject.toml` metadata

        ```toml
        [build-system]
        requires = ["setuptools>=61.0", "setuptools-scm", "wheel"]
        build-backend = "setuptools.build_meta"

        [project]
        name = "arcaflow-plugin-template-python"              <-
        description = "My plugin description"
        readme = "README.md"
        requires-python = ">=3.9"
        keywords = ["one", "two"]
        license = {text = "Apache-2.0+GPL-2.0-only"}
        classifiers = [
            "Programming Language :: Python :: 3",
        ]
        dependencies = [
            "arcaflow-plugin-sdk"
            'importlib-metadata; python_version<"3.8"',
        ]
        dynamic = ["version", "readme"]

        [tool.setuptools.dynamic]
        version = { attr = "arcaflow-plugin-template-python.0.1.0}
        readme = {file = ["REAMDE.md"]}
        ```

    3. Rename the Python project by changing the value of `pyproject.project.name`

        For example,
            ```toml
            [project]
            name = "moonshot-plugin-project"
            ```

    4. Create a [virtualenv](https://virtualenv.pypa.io/en/latest/) in your project directory using the following command, replacing your Python call.

        ```shell
        $ python -m venv .venv
        ```

    5. Activate the Python virtual environment.

        ```shell
        $ source .venv/bin/activate
        ```

    6. Install Python project dependencies.

        ```shell
        $ pip install -r requirements.txt
        ```

### Validate Working Environment

1. Run the test plugin.

    ```
    $ python3 example_plugin.py -f example.yaml
    ```

2.  Run the unit tests.

    ```
    $ python3 test_example_plugin.py
    ```

3.  Generate a JSON schema.

    ```
    $ python3 example_plugin.py --json-schema input >example.schema.json
    ```

    If you are using the [YAML plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml), add the following line to the top of your config file for code completion.

    ```
    # yaml-language-server: $schema=example.schema.json
    ```

4.  Copy and customize the [Dockerfile](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/Dockerfile) from the example repository.

5.   Set up your CI/CD system as you see fit.


Now you are ready to start hacking away at your plugin!


## Publishing Your Plugin Package

Create an [API token with your PyPi user account](https://pypi.org/help/#apitoken), and save it in your favorite secrets manager.

[Test PyPi](https://test.pypi.org/) is intended for trying out process of publishing your package. Register an account, and save your username and password to the following environment variables.

```shell
export TESTPYPI_USERNAME=<test pypi username>
export TESTPYPI_PASSWORD=<test pypi password>
```

=== "Poetry"

     Add your PyPi token to the Poetry configuration file.

     ```shell
     $ poetry config pypi-token.<any name> <PYPI API TOKEN>
     ```

     Alternatively, you can use environment variables to provide your PyPi credentials.

     ```shell
     $ export POETRY_PYPI_TOKEN_PYPI=my-token
     $ export POETRY_HTTP_BASIC_PYPI_USERNAME=<username>
     $ export POETRY_HTTP_BASIC_PYPI_PASSWORD=<password>
     ```

     Generate distribution archives (build) ([at the moment, only pure python wheels are supported](https://python-poetry.org/docs/cli/#build)).

     ```shell
     $ poetry build
     ```

     Check the results of a publish dry run are successful.

     ```shell
     $ poetry publish --dry-run

     Publishing arcaflow-plugin-template-python (0.1.0) to PyPI
     - Uploading arcaflow_plugin_template_python-0.1.0-py3-none-any.whl 100%
     - Uploading arcaflow_plugin_template_python-0.1.0.tar.gz 100%
     ```

     Upload the distribution archives (publish)!

     ```shell
     $ poetry publish

     Publishing arcaflow-plugin-template-python (0.1.0) to PyPI
     - Uploading arcaflow_plugin_template_python-0.1.0-py3-none-any.whl 100%
     - Uploading arcaflow_plugin_template_python-0.1.0.tar.gz 100%
     ```

     Alternatively, build and publish in one command.

     ```shell
     $ poetry publish --build
     ```

=== "Without Poetry"

     Change into the project's root directory.

     Install [build](https://github.com/pypa/build) and [twine](https://github.com/pypa/build).

     ```shell
     $ python3 -m pip install --upgrade build twine
     ```

     Generate distribution archives.

     ```shell
     $ python3 -m build
     ```

     You should see the `dist` directory at your project's root, with archive files.

     ```shell
     dist/
     ├── example_package_YOUR_USERNAME_HERE-0.0.1-py3-none-any.whl
     └── example_package_YOUR_USERNAME_HERE-0.0.1.tar.gz
     ```

     Upload distribution archives.

     ```
     $ python3 -m twine upload --repository testpypi --username=$TESTPYPI_USERNAME --password=$TESTPYPI_PASSWORD dist/*

     Uploading distributions to
     https://test.pypi.org/legacy/
     Uploading
     arcaflow_plugin_template_python-0.1.0-py3-none-any.whl
     100% ━━━━━━━━━━━━ 9.1/9.1 kB • 00:00 • 3.7 MB/s
     Uploading
     arcaflow_plugin_template_python-0.1.0.tar.gz
     100% ━━━━━━━━━━━━ 8.5/8.5 kB • 00:00 • 1.5 MB/s

     View at:
     https://test.pypi.org/project/arcaflow-plugin-template-python/0.1.0/
     ```


## Poetry Installation

1. Ensure your `python3` is at least version 3.9.

    ```
    $ python3 --version
    Python 3.9.15
    ```

2. Install Poetry using one of their [supported methods](https://python-poetry.org/docs/#installation) for your environment.

    For example, on a Linux distribution
    ```
    $ curl -sSL https://install.python-poetry.org | python3 -
    ```
    Make sure to install Poetry into the Python you found above[^2]

3. Verify your Poetry version.

    ```shell
    $ poetry --version
    Poetry (version 1.2.2)
    ```

[^1]: Naming your module directory the same as its encompassing project directory is a common convention for Python projects. Module directories must also be valid Python identifiers (i.e. variable names). The directory name of your Python module _must_ match the name in your pyproject.toml, allowing for `-` substituting for `_` (i.e `arcaflow-plugin-template-python` ~= `arcaflow_plugin_template_python`), so that the directory name transforms into a module name that is a valid Python identifier.

[^2]: You want to ensure that Poetry is installed into __exactly one Python executable__ on your system. If something goes wrong with your package's Python virtual environment, you do not want to spend additional time figuring out which Poetry executable is responsible for managing that specific Python virtual environment.