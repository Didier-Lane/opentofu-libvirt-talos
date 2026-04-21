## Dependencies

Dependencies are Makefiles which can be enabled to provide optionnal features, such as installing required binaries or implementing functions.

Enabling dependencies is controlled by the `DEPENDENCIES` [environment variable] when invoking make to create the [`.env`] file.

For example, enabling [jq] and [yq] dependencies.

```shell
make DEPENDENCIES="jq yq"
```

If you have integrated this project as a [git subtree] you can declare the `DEPENDENCIES` [environment variable] from the root Makefile.

```shell
DEPENDENCIES = jq yq
include make/base/Makefile
```

### Available dependencies

| Dependency                  | Makefile                                    | Description
|:--                          |:--                                          |:--
| [host]                      | [make/deps/host.mk]  | Provides host system informations such as the OS name, the processor architecture and the `BIN_DIR` [environment variable]
| [jq]                      | [make/deps/jq.mk]         | Provides [JQ command-line JSON processor][JQ]
| [yq]                      | [make/deps/yq.mk]         | Provides [YQ command-line YAML processor][YQ]
| [dockerhub]               | [make/deps/dockerhub.mk]  | Provides a function for checking for newer docker immutable tags
| [github]               | [make/deps/github.mk]  | Provides functions for checking for newer github release version and newer github package container tag

### Special dependencies

Some dependencies are automatically added on the `DEPENDENCIES` [environment variable] when invoking make when some conditions are met.

| Dependency                  | Condition
|:--                          |:--
| [host]                      | `DEPENDENCIES` is not empty and doesn't includes `host`
| [jq]                        | `DEPENDENCIES` contains either `github` or `dockerhub` and doesn't includes `jq`

[`.env`]: ./env.md#the-env-file
[environment variable]: ./env.md
[host]: ./deps/host.md
[jq]: ./deps/jq.md
[yq]: ./deps/yq.md
[github]: ./deps/github.md
[dockerhub]: ./deps/dockerhub.md
[make/deps/host.mk]: ../make/deps/host.mk
[make/deps/jq.mk]: ../make/deps/jq.mk
[make/deps/yq.mk]: ../make/deps/yq.mk
[make/deps/dockerhub.mk]: ../make/deps/dockerhub.mk
[make/deps/github.mk]: ../make/deps/github.mk
[JQ]: https://github.com/jqlang/jq
[YQ]: https://github.com/mikefarah/yq
[git subtree]: ./subtree.md
