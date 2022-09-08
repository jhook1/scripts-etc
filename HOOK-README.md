# Git Hooks

## What are hooks?
Git hooks are scripts that are automatically invoked when executing certain git commands, enabling the git client to execute additional actions and validations.
Installed hooks are located in the `/.git/hooks/` directory.

## Goals
1. Enable developers to avoid pushing changes to critical configuration files.
2. Ensure that those files are still available and tracked in the repository.
3. Minimize overhead and maximize automation for developers in achieving these goals.

## Installation
The hook scripts require an initial installation step before they take effect.
In order to install, copy all script files from the tracked `/git-hooks/` directory to the installation directory `/.git/hooks/`.
A batch script, [`install-hooks.bat`](../install-hooks.bat), has been provided in the repository root to automate the initial installation process.
Once installed, the pre-commit, post-merge, and post-checkout hooks should be able to automatically apply and track updates to hook scripts.

## Limitation
**WARNING**: Visual Studio 2015 does **NOT** support git-hooks. As such, hook scripts will **NOT** be executed when committing/merging/switching/pulling etc. This means "ignored" files (tracked in repo but added to `.gitignore`) will not be unstaged before commits and hooks will not be auto-updated when using Visual Studio 2015's interface. Support for git hooks was added in Visual Studio 2017 and up. Hook scripts will still be executed when the command line is utilized.

## pre-commit

### Why?

#### Ignored files
By default, files that are present in a git repository ("tracked") do not respect `.gitignore` exclude patterns.
As such, changes to these files are still tracked, even if that file would otherwise be ignored.
This could potentially result in breaking changes to critical configuartion files or access credentials being pushed to remote or production environments.

#### Tracking hooks
The `/.git/hooks/` directory is not tracked by git and, as such, changes to these files would not be tracked and saved by git.

### What it does

#### Ignored files
The pre-commit git hook iterates over staged filenames, checking against the patterns specified in any `.gitignore` files.
If a filename matches an excluded pattern, that file is unstaged from the commit.
If no files remain in staging, the commit is aborted.

#### Tracking hooks
The pre-commit hook checks for differences between scripts installed in the active `/.git/hooks/` directory and the corresponding scripts in the tracked `/git-hooks/` directory.
If differences are found, the changes are merged to the tracked script and the commit is aborted with a message to the user to review those changes before committing again.

### Using the hook

#### Execution
The pre-commit hook script is automatically fired before any `git commit` operation, including but not limited to `git commit` and `git merge --no-ff`, so long as the [`pre-commit`](./pre-commit) file (exact name) is present in the `/.git/hooks/` directory.
The hook can be overriden, enabling commits to ignored files and bypassing updates to hook scripts, by passing the `-n` or `--no-verify` options to the `git commit` command.

> **DANGER**: Overriding the hook should only be done if you are **absolutely** certain that breakages will not occur upstream.

#### Tracking hooks
Changes to hook scripts may be tracked by making changes to installed hook files (in `/.git/hooks/`) and creating a commit.
The pre-commit hook will then merge those changes to the scripts in the tracked hooks directory `/git-hooks/`.
If no other changes are being committed at that time, the `--allow-empty` option can be provided to the `git commit` command to bypass the initial restrictions on empty commits.

> Note: Deleting a hook file from the installed directory (`/.git/hooks/`) will **NOT** remove it from the tracked directory (`/git-hooks/`).

### Configuration
The [`pre-commit`](./pre-commit) file contains two configuration variables that can be changed for testing and debugging:
- `verbose`: Enable/disable additional status messages during hook script execution.
- `do_abort`: Setting this value to `1` will force the commit to abort at the end of the hook script execution.
Useful to avoid stray commits while debugging.

## post-merge

### Why?
The `/.git/hooks/` directory is not tracked by git and, as such, when merging changes, the installed hooks in the `/.git/hooks/` directory would not be updated.

### What it does?
The post-merge hook script iterates over the diff tree between the original head and the new head (following the merge changes), checking whether the changed files are from the tracked `/git-hooks/` directory.
If so, those changes are merged into the corresponding installed hook in `/.git/hooks/`.

### Using the hook
The post-merge hook is automatically executed after any merge opertation (such as `git merge` or `git pull`), so long as the [`post-merge`](./post-merge) (exact name) file is present in the `/.git/hooks/` directory.

> Note: If a hook file is deleted from tracking, it will **NOT** be uninstalled automatically.

### Configuration
The [`post-merge`](./post-merge) file contains two configuration variables that can be changed for testing and debugging:
- `verbose`: Enable/disable additional status messages during hook script execution.
- `do_abort`: Setting this value to `1` will cause execution of the script to be aborted.
This does not affect the merge itself, but can be used to effectively disable the hook.

## post-checkout

### Why?
The `/.git/hooks/` directory is not tracked by git and, as such, when switching branches or checking out files, the installed hooks in the `/.git/hooks/` directory would not be updated.

### What it does?
The post-checkout hook script iterates over files in the tracked `/git-hooks/` directory, checking for differences between those files and the corresponding installed hook scripts (in `/.git/hooks/`).
If differences are found, the changes from the tracked files are merged into the installed scripts.

### Using the hook
The post-checkout hook is automatically fired for any checkout operation, including `git switch` and `git checkout` (of both branches and files), provided that [`post-checkout`](./post-checkout) (exact name) file is present in the installed `/.git/hooks/` directory.

> Note: If a hook file is deleted from or not found in the tracked hooks directory (`/git-hooks/`) in the new index, it will **NOT** be uninstalled automatically.

### Configuration
The [`post-checkout`](./post-checkout) file contains two configuration variables that can be changed for testing and debugging:
- `verbose`: Enable/disable additional status messages during hook script execution.
- `do_abort`: Setting this value to `1` will cause execution of the script to be aborted.
This does not affect the checkout itself, but can be used to effectively disable the hook.
