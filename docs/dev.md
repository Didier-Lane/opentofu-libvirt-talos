## Development

### Adding recipes

Here is an example of adding a simple recipe which demonstrates how you can develop your own commands.

Create the file `make/test.mk` with the following content

```shell
.PHONY: test
test: # 🎯 A simple test for demo purpose
    echo test
```

>[!IMPORTANT]
>Make sure to replace the spaces before `echo test` with a tabulation, otherwise make will produce the error `make/test.mk:3: *** missing separator. Exited.`

Invoke the recipe with `make test` which will just echo `test`.

```shell
$ make test
test
```

Now if you invoke `make` to show the [helper], the `test` command will be visible in the list of available targets.

```shell
$ make
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans The Working Copy
help            💡 Shows This Help Menu
test            🎯 A simple test for demo purpose
```

[helper]: ./help.md
