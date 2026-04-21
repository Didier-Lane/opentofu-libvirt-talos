## Host

The `host` [dependency] is responsible for providing host system informations such as the OS name, the processor architecture and the `BIN_DIR` [environment variable], it is controlled by the [make/deps/host.mk] Makefile.

Because it is a [special dependency], you don't necessary have to enable it manually unless it is the only [dependency] you require.

### Environment variables

| Name                  | Description                       | Default value
|:--                    |:--                                |:--
| `BIN_DIR`             | The directory where dependencies binairies will be downloaded | `~/.local/bin`

>[!IMPORTANT]
>The `BIN_DIR` environment variable will be resolved to the absolute path.

[dependency]: ../deps.md
[special dependency]: ../deps.md#special-dependencies
[make/deps/host.mk]: ../../make/deps/host.mk
[`.env`]: ../env.md#the-env-file
[environment variable]: #environment-variables
