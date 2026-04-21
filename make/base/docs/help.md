## Helper

The [help] utility Makefile provides an helper to present the available commands to the user.

It parses the [targets] having a comment in the [prerequisites] line of the included Makefiles.

For example, the `clean` and `help` [targets] contains the following comments in their [prerequisites].

```shell
clean: # ✨ Cleans the working copy
help: # 💡 Shows this help menu
```

Which results of the following content displayed by the helper in the `Available Targets`.

```shell
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans the working copy
help            💡 Shows this help menu
```

### Variables substitution

The helper also manages variable substitution as demonstrated in the bellow example.

Assuming there is a file `make/test.mk` with the following content.

```shell
SOME_FILE := test.txt

$(SOME_FILE): # 📝 Creates the file $(SOME_FILE)
	echo "test" > "$(SOME_FILE)"
```

Then invoking the helper will result with the following content.

```shell
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans the working copy
help            💡 Shows this help menu
test.txt        📝 Creates the file test.txt
```

### Invoking

Invoking the `help` target is available in the following ways

- invoking `make help`
- invoking `make` without any target as it is the [default goal]
- invoking `make` with an undefined target

For example, invoking the undefined `foo` target will show the helper.

```shell
$ make foo
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans the working copy
help            💡 Shows this help menu
```

### Custom header

Customizing the helper header is available with the `HELP_HEADER` variable from a Makefile.

```shell
define HELP_HEADER
$(underline)Usage$(reset)

	# To run and execute a target
	$(bold)make $(cyan)<target>$(reset)
$(HELP_HEADER_EXTRAS)
$(underline)Available Targets$(reset)

endef
```

The `HELP_HEADER_EXTRAS` variable can be also used to customize the part of the helper header between the `Usage` and `Available Targets` sections.

```shell
define HELP_HEADER_EXTRAS
$(bold)Some extra lines$(reset)

endef
```

### Custom Line padding

Customizing the space between targets and description in the helper is available with the `HELP_LINE_PADDING` variable from a Makefile.

```shell
HELP_LINE_PADDING := 24
```

[help]: ../make/utils/help.mk
[prerequisites]: https://www.gnu.org/software/make/manual/make.html#Rule-Syntax
[targets]: https://www.gnu.org/software/make/manual/make.html#What-a-Rule-Looks-Like
[default goal]: https://www.gnu.org/software/make/manual/make.html#Other-Special-Variables
