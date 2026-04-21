## Clean

The `clean` [target] is responsible for removing the project generated files that are not meant to be staged by git.

By default it removes only the [`.env`] file from the project.

### Custom command

The clean command can be customized with the Make variable `CLEAN_COMMAND` from a Makefile.

For example, if you need to remove a generated `config.json` file on cleanup customize the `CLEAN_COMMAND` variable as bellow.

```shell
define CLEAN_COMMAND
rm -f .env config.json
endef
```

[`.env`]: ./env.md#the-env-file
[target]: https://www.gnu.org/software/make/manual/make.html#What-a-Rule-Looks-Like
