## Github

The `github` [dependency] provides the following functions

- `github_check_release_version` for checking for newer github release version
- `github_check_package_version` for checking for newer github package version

It is controlled by the [make/deps/github.mk] Makefile.

To Enable it, add `github` to the `DEPENDENCIES` [environment variable] when invoking make to create the [`.env`] file.

```shell
make DEPENDENCIES=github
```

>[!TIP]
>The above example will also enable the `jq` and `host` [special dependencies] as it relies on it.

### Check release version

The `github_check_release_version` method accepts the following arguments

| Description                                                   | Examples
|:--                                                            |:--
| gihub repository                                              | `jqlang/jq`, `mikefarah/yq`
| current version to check against                              | `jq-1.8.1`, `v4.52.5`
| filename of the release asset                                 | `jq-linux-amd64`, `yq_linux_amd64`

#### Example

This can be invoked with the [call function] from a Makefile as the bellow example.

```shell
.PHONY: test
test: jq
	$(call github_check_release_version,jqlang/jq,jq-1.8.0,jq-linux-amd64)
```

>[!TIP]
>The above example declares a [phony target] called `test` which checks if there is a newer release version than `jq-1.8.0` for the `jqlang/jq` repository.

>[!NOTE]
>It will also automatically install [JQ] when invoking `make test` because it has `jq` as [prerequisite].

Then when invoking `make test` this will output.

```shell
$ make test
💡 Repository jqlang/jq new version is jq-1.8.1
📦 Asset jq-linux-amd64 digest is sha256:020468de7539ce70ef1bceaf7cde2e8c4f2ca6c3afb84642aabc5c97d9fc2a0d
```

### Check package version

The `github_check_package_version` method accepts the following arguments

| Description                                                   | Examples
|:--                                                            |:--
| gihub organization name                                       | `loft-sh`
| container package name                                        | `vm-container`
| current package version to check against                      | `0.0.1`

>[!IMPORTANT]
>The `github_check_package_version` requires an [Github personal access token] with the `public_repo, read:packages` permissions which is expected to be defined as an environment variable named `GITHUB_TOKEN`, otherwise the function will fail with the following message.

```shell
⚠️ Github check package version requires the environment variable GITHUB_TOKEN to be defined
```

#### Example

This can be invoked with the [call function] from a Makefile as the bellow example.

```shell
.PHONY: test
test: jq
	$(call github_check_package_version,loft-sh,vm-container,0.0.1)
```

>[!TIP]
>The above example declares a [phony target] called `test` which checks if there is a newer package version than `0.0.1` for the container package `vm-container` of the `loft-sh` organization.

>[!NOTE]
>It will also automatically install [JQ] when invoking `make test` because it has `jq` as [prerequisite].

Then when invoking `make test` this will output.

```shell
$ make test
💡 New tag is 0.0.2 with digest sha256:7b1bdea2a468b4727244606d1306bf172b5f1400b49def1839ef3ae45ec0b081
```

[dependency]: ../deps.md
[make/deps/github.mk]: ../../make/deps/github.mk
[`.env`]: ../env.md#the-env-file
[environment variable]: ../env.md
[special dependencies]: ../deps.md#special-dependencies
[call function]: https://www.gnu.org/software/make/manual/make.html#The-call-Function
[phony target]: https://www.gnu.org/software/make/manual/make.html#Phony-Targets
[JQ]: https://github.com/jqlang/jq
[prerequisite]: https://www.gnu.org/software/make/manual/make.html#Rule-Syntax
[Github personal access token]: https://docs.github.com/en/rest/authentication/authenticating-to-the-rest-api?apiVersion=2026-03-10#authenticating-with-a-personal-access-token
