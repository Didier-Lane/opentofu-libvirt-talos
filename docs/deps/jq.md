## JQ

The `jq` [dependency] is responsible for downloading and installing [JQ command-line JSON processor][JQ], it is controlled by the [make/deps/jq.mk] Makefile.

To Enable it, add `jq` to the `DEPENDENCIES` [environment variable] when invoking make to create the [`.env`] file.

```shell
make DEPENDENCIES=jq
```

Then once the `jq` dependency is enabled, you can use it as a [prerequisite] of a recipe.

```shell
test.json: jq
    jq -n '.foo = "bar"' > test.json
```
>[!TIP]
>The above example declares a [target] `test.json`, it will automatically install [JQ] when invoking `make test.json` because it has `jq` as [prerequisite].

### Environment variables

| Name                  | Description                       | Default value
|:--                    |:--                                |:--
| `JQ_VERSION`          | The version of [JQ] | `jq-1.8.1`
| `JQ_DIGEST`           | The digest of the downloaded [JQ] release asset | `sha256:020468de7539ce70ef1bceaf7cde2e8c4f2ca6c3afb84642aabc5c97d9fc2a0d`

[dependency]: ../deps.md
[JQ]: https://github.com/jqlang/jq
[make/deps/jq.mk]: ../../make/deps/jq.mk
[`.env`]: ../env.md#the-env-file
[environment variable]: ../env.md
[target]: https://www.gnu.org/software/make/manual/make.html#What-a-Rule-Looks-Like
[prerequisite]: https://www.gnu.org/software/make/manual/make.html#Rule-Syntax
