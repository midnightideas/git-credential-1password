# 1Password Git Credential Helper

This is a bash-only implementation of 1Password Git Credential Helper

## Prerequisite

You need to have [1Password CLI](https://1password.com/downloads/command-line/) installed. This should be the only prerequisite.

## Installation

### Homebrew

Run

```bash
brew tap git-credential-1password/git-credential-1password
brew install git-credential-1password
```

Or, run the followings if you would like to pull from Github master directly

```bash
brew install --HEAD git-credential-1password
```



### Ad-hoc

Download `git-credential-1password` from [Releases](https://github.com/git-credential-1password/git-credential-1password/releases) and put the file in a location within your `$PATH` environment variable, Git will recognise it's a credential helper.

To verify, run the following commands, and you should see `credential-1password` being returned.

```bash
git help -a | grep credential-
```

## Configuration

### User global configuration

Run 

```bash
git config --global credential.helper "1password {1Password Sign-in URL} {1Password Item Name}"
```

If you are using your own 1Password account, i.e., not managed by your company, your sign-in URL should be `my.1password.com` or the shorthand version `my` also works.

If you are using an enterprise managed 1Password account, your sign-in URL may look like `company-name.1password.com`. The shorthand version also works.

This sign-in URL parameter will be passed to 1Password CLI as the `--account` option as-is.

The item name can be either the name or the UUID of the item, as supported by 1Password CLI. Don't forget that you may want to wrap the item name with quotes if the name contains space. For example:

```bash
git config --global credential.helper "1password my 'My Github Personal Access Token'"
```

Your global Git config file `$HOME/.gitconfig` should result in the following section.

```ini
[credential]
	helper = 1password my 'My Github Personal Access Token'
```

### Site-specific or account-specific configuration

Sometimes, you may have multiple Github accounts for different purposes or multiple accounts across different Git hosting providers (Github, Bitbucket or Azure DevOps). To select the 1Password item correctly, you may choose to set up the credential helper using:

```bash
git config --global credential.https://github.com/personalAccountName.helper "1password my 'My Github Personal Access Token'"
git config --global credential.https://github.com/workAccountName.helper "1password my 'My Work Github Personal Access Token'"
```

These would result in the following two entries in your global Git config.

```ini
[credential "https://github.com/personalAccountName"]
	helper = 1password my 'My Github Personal Access Token'
[credential "https://github.com/workAccountName"]
	helper = 1password my 'My Work Github Personal Access Token'
```

The Personal Access Token will be pulled from 1Password accordingly, based on the URL matching. You can find out more detail on how Git handles URL specific configuration at https://git-scm.com/docs/git-config#Documentation/git-config.txt-httplturlgt (search ` http.<url>.*` in this page if the archor does not work).

## Session management

The 1Password CLI does not provide any session management, other than keeping the session token in an environment variable.

However, this method creates a challenge that we cannot access two different 1Password accounts within one terminal session, e.g., one personal 1Password account and one work 1Password account (which is one of the motivations of creating this helper).

At the same time, I would like to avoid writing the session token into a static file within the file system, even though the session token will expire after 30 minutes of inactivity - see https://support.1password.com/command-line-getting-started/.

In this solution, the 1Password session token is kept in the [Git Cache credential helper](https://git-scm.com/docs/git-credential-cache), which Git describes as the following:

> This command caches credentials in memory for use by future Git programs. The stored credentials never touch the disk, and are forgotten after a configurable timeout. The cache is accessible over a Unix domain socket, restricted to the current user by filesystem permissions.

This method seems to be the best compromise I have found so far. But if anybody has a better idea. I am happy to consider changing the behavior.