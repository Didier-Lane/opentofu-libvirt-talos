# Makefile Base

Provides the basic structure and utilities for operations abstracted by Make recipes

Requires

- [GNU Make](https://www.gnu.org/software/make/)

Features

- Manages the automatic creation of an [`.env`](./docs/env.md) file for storing environment variables
- Provides an [helper](./docs/help.md) to present the available commands to the user
- Optionnal [dependencies](./docs/deps.md) such as checking for newer [Github](./docs/deps/github.md) projects releases or newer [DockerHub](./docs/deps/dockerhub.md) immutable tags.

Documentation

- [Clean](./docs/clean.md)
- [Dependencies](./docs/deps.md)
    - [Host](./docs/deps/host.md)
    - [JQ](./docs/deps/jq.md)
    - [YQ](./docs/deps/yq.md)
    - [DockerHub](./docs/deps/dockerhub.md)
    - [Github](./docs/deps/github.md)
- [Development](./docs/dev.md)
- [Display](./docs/display.md)
- [Environment](./docs/env.md)
- [Help](./docs/help.md)
- [Git Subtree](./docs/subtree.md)

## Directory structure

```shell
.
├── make
│   ├── clean.mk
│   ├── deps
│   └── utils
└── Makefile
```

- [Makefile](./Makefile) is the main file invoked by make, it controls the inclusion of files ending by `.mk` from the [make](./make) directory as sub makefiles.
- [deps](./make/deps) directory stores the [dependencies](./docs/deps.md) makefiles.
- [utils](./make/utils) directory holds the makefiles utilities such as an [helper](./docs/help.md), messages [display](./docs/display.md) management, and so on.

## Usage

You can either clone this repository as a base of your project or use it as a [git subtree](./docs/subtree.md).

The basic usage is to invoke `make` which will display the [helper](./docs/help.md).

```shell
$ make
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans the working copy
help            💡 Shows this help menu
```
