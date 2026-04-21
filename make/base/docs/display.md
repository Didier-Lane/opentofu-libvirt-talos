## Display

### Messages

The [display] utility Makefile provides a function called `message` to output Makefiles recipes messages.

This can be invoked with the [call function] from a Makefile as the bellow example.

```shell
.PHONY: test
test:
	$(call message,👋,Hello from Make)
```

>[!TIP]
>The above example declares a [phony target] called `test` which only purpose is to display a message.

Then when invoking `make test` this will output.

```shell
👋 Hello from Make
```

### Colors

The [display] utility also declares colors and text styling variables which can be used within [messages] as demonstrated bellow.

```shell
.PHONY: test
test:
	$(call message,👋,$(bold)Hello$(reset) $(underline)from$(reset) $(bold)$(cyan)Make$(reset))
```

### Disabling colors

Colored output of Makefile messages can be disabled with the variable `NOCOLORS`, which can have any value once it is declared.

```shell
$ make test NOCOLORS=1
Hello from Make
```

This also controls the output of the [helper]

```shell
$ make NOCOLORS=1
Usage

# To run and execute a target
make <target>

Available Targets

clean            Cleans the working copy
help             Shows this help menu
```

[display]: ../make/utils/display.mk
[call function]: https://www.gnu.org/software/make/manual/make.html#The-call-Function
[phony target]: https://www.gnu.org/software/make/manual/make.html#Phony-Targets
[messages]: #messages
[helper]: ./help.md
