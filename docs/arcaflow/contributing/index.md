# Contributing to Arcaflow

First of all, welcome to the Arca Lot! Whether you are a beginner or a seasoned veteran, your contributions are most appreciated. Thank you!

Now, let's get you started. There are a number of ways you can contribute on [GitHub](https://github.com/arcalot), please check the [Arcaflow project board](https://github.com/orgs/arcalot/projects/5) for open issues. Additionally, here are *a few* repos you can contribute to:

| Repository                                                                                            | What you can do here                         |
|-------------------------------------------------------------------------------------------------------|----------------------------------------------|
| [arcalot.github.io](https://github.com/arcalot/arcalot.github.io)                                     | Improve the documentation                    |
| [arcaflow-plugin-sdk-go](https://github.com/arcalot/arcaflow-plugin-sdk-go)                           | Improve the Go SDK                           |
| [arcaflow-plugin-sdk-python](https://github.com/arcalot/arcaflow-plugin-sdk-python)                   | Improve the Python SDK                       |
| [arcaflow-engine](https://github.com/arcalot/arcaflow-engine)                                         | Improve the Arcaflow Engine                  |
| [arcaflow-engine-deployer-kubernetes](https://github.com/arcalot/arcaflow-engine-deployer-kubernetes) | Improve the Kubernetes deployment of plugins |
| [arcaflow-engine-deployer-docker](https://github.com/arcalot/arcaflow-engine-deployer-docker)         | Improve the Docker deployment of plugins     |
| [arcaflow-engine-deployer-podman](https://github.com/arcalot/arcaflow-engine-deployer-podman)         | Improve the Podman deployment of plugins     |
| [arcaflow-expressions](https://github.com/arcalot/arcaflow-expressions)                               | Improve the Arcaflow expression language     |
| [arcaflow-plugin-image-builder](https://github.com/arcalot/arcaflow-plugin-image-builder)             | Improve the Arcaflow plugin packaging        |
| [arcaflow-plugin-*](https://github.com/orgs/arcalot/repositories?q=plugin)                            | Improve the officially supported plugins     |

If you want to contribute regularly, why not join the [Arcalot Round Table](https://github.com/arcalot/arcalot-round-table) by [reading our charter](https://github.com/arcalot/arcalot-round-table/blob/main/CHARTER.md) and signing up [as a member](https://github.com/arcalot/arcalot-round-table/blob/main/ART_MEMBERS.md)? That way you get a voice in the decisions we make!

## License

All code in Arcaflow is licensed under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). The documentation is licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). Please make sure you read and understand these licenses before contributing. If you are contributing on behalf of your employer, please make sure you have permission to do so.

## Principles

While we don't deal in absolutes (only a sith would do that) we hold ourselves to a few key principles. There are plenty of things where we could do better in these areas, so if you find something, please open an issue. It's important!

### The principle of the least surprise

Sometimes, things are just hard to make user-friendly. If presented with two choices, we will always pick the one that doesn't break expectations. What would an average user expect to happen without reading the documentation? If something surprised you, **please open a bug**.

### The principle of nice error messages

When using Arcaflow, you should **never** be confronted with a stack trace. Error messages should always explain what went wrong and how to fix it. We know, this is a tall order, but if you see an error message that is not helpful, **please open a bug**.

### The principle of intern-friendliness

There is enough software out in the wild that requires months of training and is really hard to get into. Arcaflow isn't the easiest to learn either, see the whole [typing system](typing.md) thing, but nevertheless, the software should be written in such a way that an intern with minimal training can sit down and do *something* useful with it. If something is unnecessarily hard or undocumented, you guessed it, **please open a bug**.

### The principle of typing

We believe that strong and static typing can save us from bugs. This applies to programming languages just as much as it applies to workflows. We aim to make a system tell us that something is wrong **before** we spent several hours running it.

### The principle of testing

Bugs? Yeah, we have those, and we want fewer of them. Since we are a community effort, we can't afford a large QA team to test through everything manually before a release. Therefore, it's doubly important that we have automated tests that run on every change. Furthermore, we want our tests to run *quickly* and *without additional setup time*. You should be able to run `go test` or `python -m unittest discover` and get a result within a few seconds at most. This makes it more likely that a contributor will run the tests and contribute new tests instead of waiting for CI to sort it out.

### The principle of small piles

Every software is... pardon our French: crap. Ours is no exception. The difference is how big and how stinky the piles are. We aim to make the piles small, well-defined and as stink-less as possible. If we need to replace a pile with another pile, it should be easy to do so.

Translated to software engineering, we create APIs between our ~~piles~~ components. These APIs can be in the form of code, or in the form of a GitHub Actions workflow. A non-leaky API helps us replace one side of the API without touching the other.

### The principle of kindness to our future self

Writing code should be fun, most of us got into this industry because we enjoyed creating something. We want to keep this joy of creation. What kills the enthusiasm fastest is having to slog through endless pieces of obtuse code, spending hours and hours trying to accomplish a one-line change. When we write code, we want to be kind to our future selves. That's why we not only write documentation and tests for our users, we also create these for ourselves and our peers.