# Creating official Arcaflow plugins

Official Arcaflow plugins have more [stringent requirements than normal](https://github.com/arcalot/arcaflow-plugins-incubator#readme). This document describes how to create a plugin that conforms to those requirements.

## Development environment

Official Python plugins are standardized on Poetry and a Linux-based development environment. 

## Installing Poetry

First, please ensure your `python3` executable is at least version 3.9.

```
$ python3 --version
Python 3.9.15
```

??? "How to install Python"
    === "RHEL, CentOS, Fedora"
        ```
        $ dnf -y install python3.9
        ```
    === "Ubuntu"
        ```
        $ apt-get -y install python3.9
        ```

!!! tip
    If the `python3` command doesn't work for you, but `python3.9` does, you can alias the command:
    ```
    $ alias python3="python3.9"
    ```

Install Poetry using one of their [supported methods](https://python-poetry.org/docs/#installation) for your environment.

!!! warning
    Make sure to install Poetry into **exactly one Python executable** on your
    system. If something goes wrong with your package's Python virtual environment,
    you do not want to also spend time figuring out which Poetry executable is
    responsible for it.

Now, verify your Poetry version.

```
$ poetry --version
Poetry (version 1.2.2)
```

## Setting up your project

Create your plugin project, `plugin-project`, and change directory into the project root. You should see a directory structure similar to this with the following files.

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

Set Poetry to use your Python that is at least 3.9.

```
$ poetry env use $(which python3)
```

Check that your `pyproject.toml` is using at least Python 3.9 by looking for the following line.

```toml title="pyproject.toml"
[tool.poetry.dependencies]
python = "^3.9"
```

Add the [arcaflow plugin sdk for python](https://github.com/arcalot/arcaflow-plugin-sdk-python) as a software dependency for your Python project.

```
$ poetry add arcaflow-plugin-sdk-python
```

You should now have a `poetry.lock` file in your project root. Poetry maintains the state of your `pyproject.toml`, and its exact software dependencies as hashes in the `poetry.lock` file.

## Building a container image

To build an official plugin container image we use the [carpenter workflow](https://github.com/arcalot/arcaflow-reusable-workflows/blob/main/.github/workflows/carpenter.yaml) on GitHub Actions. This workflow calls the [Arcaflow image builder](https://github.com/arcalot/arcaflow-plugin-image-builder) to build the image and perform all validations necessary.

In order to successfully run the build, you should add the following files from the [template repository](https://github.com/arcalot/arcaflow-plugin-template-python):

- `Dockerfile`
- `LICENSE`
- `.flake8`

Additionally, you need to add tests to your project, write a `README.md`, and make sure that the code directory matches your project name.

## Publishing on PyPI

Some plugins work well as libraries too. You can publish Arcaflow plugins on PyPI.

To push an official package to PyPI, please contact an Arcalot chair to create an [API token on PyPI](https://pypi.org/help/#apitoken) and set up a CI environment. For testing purposes you can use [TestPyPI](https://test.pypi.org/).

You can configure Poetry to use this API token by calling:

```
$ poetry config pypi-token.<any name> <PYPI API TOKEN>
```

Alternatively, you can also use environment variables:

```
$ export POETRY_PYPI_TOKEN_PYPI=my-token
$ export POETRY_HTTP_BASIC_PYPI_USERNAME=<username>
$ export POETRY_HTTP_BASIC_PYPI_PASSWORD=<password>
```

You can generate distribution archives by typing:

```
$ poetry build
```

You can then test publishing:

```
$ poetry publish --dry-run

Publishing arcaflow-plugin-template-python (0.1.0) to PyPI
- Uploading arcaflow_plugin_template_python-0.1.0-py3-none-any.whl 100%
- Uploading arcaflow_plugin_template_python-0.1.0.tar.gz 100%
```

Remove the `--dry-run` to actually publish or call `poetry publish --build` to run it in one go.