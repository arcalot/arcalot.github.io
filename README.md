# Arcalot website

This is the source code for the [Arcalot website](https://arcalot.github.io).

## Adding content

You can add content to the website by simply editing the markdown files in the [docs folder](docs). If you would like to build the website locally, you will need Python. You can run the following steps to launch the site in development mode:

```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m mkdocs serve
```

## Generating docs

Some parts of the documentation are generated from Engine data structures using `.tpl` files. To re-generate the `.md` files, please run:

```
cd docs
go run ../docsgen/
```