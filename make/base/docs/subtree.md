## Git Subtree

The best suitable way to use this project is to embed it as a git subtree of your project.

### Starting a new project

Here is an example of starting a new git repository for holding this project as a subtree.

Init the repository `test`.

```shell
git init test
cd test
```

Add an empty commit.

```shell
git commit --allow-empty --message 'init'
```

>[!NOTE]
>This empty commit is required to avoid the git error `fatal: ambiguous argument 'HEAD': unknown revision or path not in the working tree` when adding the subtree.

### Add this project as a Git Subtree

The bellow instructions are for adding this project as a Git Subtree to a new or existing project.

Add this project as git remote.

```shell
git remote add -f makefile-base git@github.com:Didier-Lane/makefile-base.git
```

>[!NOTE]
>Use `https://github.com/Didier-Lane/makefile-base.git` if you prefer to clone it through the web.


Add this project as a git subtree.

```shell
git subtree add --prefix=make/base makefile-base main --squash
```

>[!IMPORTANT]
>The `--prefix=make/base` argument is mandatory because of the [directory structure] of this project.

At this point the directory structure should look like.

```shell
.
└── make
    └── base
        ├── COPYING
        ├── .editorconfig
        ├── .gitignore
        ├── make
        ├── Makefile
        └── README.md
```

From here you just have to create a `Makefile` at the root of the project which includes the `make/base/Makefile`.

```shell
cat <<EOF > Makefile
include make/base/Makefile
EOF
```

#### The `.gitignore` file

Copy the `make/base/.gitignore` file to the root directory of the project or add the `.env` line to your existing `.gitignore` file in order to avoid the `.env` file to be staged by git

#### The `.editorconfig` file

Copy the `make/base/.editorconfig` file to the root directory of your project or add the bellow content to your existing `.editorconfig` file

```shell
[{Makefile,*.mk}]
indent_style = tab
```

You can now start to [develop] your own recipes.

### Updating the Git Subtree

Use the following command to pull changes from this repository to your project Git Subtree.

```shell
git subtree pull --prefix=make/base makefile-base main --squash
```

[directory structure]: ../README.md#directory-structure
[develop]: ./dev.md
