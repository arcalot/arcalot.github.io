# Packaging Arcaflow plugins

Arcaflow plugins are distributed using container images. Whatever programming language you are using, you will need to package it up into a container image and distribute it via a container registry.

## The manual method

Currently, we only support the manual method for non-Arcalot plugins. However, it's very simple. First, create a Dockerfile for your programming language:

=== "Python"

    With Python, the Dockerfile heavily depends on which build tool you are using. Here we are demonstrating the usage using pip.
    
    ```Dockerfile
    FROM python:alpine

    # Add the plugin contents
    ADD . /plugin
    # Set the working directory
    WORKDIR /plugin

    # Install the dependencies. Customize this
    # to your Python package manager.
    RUN pip install -r requirements.txt

    # Set this to your .py file
    ENTRYPOINT ["/usr/local/bin/python3", /plugin/plugin.py"]
    # Make sure this stays empty!
    CMD []
    ```

=== "Go"

    For Go plugins we recommend a multi-stage build so the source code doesn't unnecessarily bloat the image. (Keep in mind, for some libraries you will need to include at least a LICENSE and possibly a NOTICE file in the image.)

    ```Dockerfile
    FROM golang AS build
    # Add the plugin contents
    ADD . /plugin
    # Set the working directory
    WORKDIR /plugin
    # Build your image
    ENV CGO_ENABLED=0
    RUN go build -o plugin

    # Start from an empty image
    FROM scratch
    # Copy the built binary
    COPY --from=build /plugin/plugin /plugin
    # Set the entry point
    ENTRYPOINT ["/plugin"]
    # Make sure this stays empty!
    CMD []
    ```

That's it! Now you can run your build:

```
docker build -t example.com/your-namespace/your-plugin:latest .
docker push example.com/your-namespace/your-plugin:latest
```
