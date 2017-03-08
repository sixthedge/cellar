# Contributing Guide

## Before you get started

### Code Of Conduct
This project follows the Contributor Covenant's [Code of Conduct](http://contributor-covenant.org/version/1/4/). 

### Setup
Setting up your development environment is covered in-depth on [Totem Docs](http://totem-docs.herokuapp.com/1.0.0/setup/environment).

### Best Practices
Keep up to date with the coding styles we employ across our repositories as well as work flow structures within the **Guides** section of [Totem Docs](http://totem-docs.herokuapp.com/).

## How can I contribute to the code?

### Reporting Issues
**Please contact us directly for any issues involving security vulnerabilities.**

**Before you submit** an issue, browse existing issues to see if it has already been posted and add new or relevant discussion. 

Any **Non-Security** related issues are tracked via their projects corresponding **Github Issues** list.

- [OpenTBL Issues](https://github.com/sixthedge/opentbl-com/issues)

### Submitting a new issue
- Include a clear **title** and **description** are required
  - The description should outlay the use case of the bug and steps for reproducing it if possible
- Add the most relevant labels
- If possible have a code sample, error log or unit test demonstrating the issue

### Commiting Changes
**Before** you start cloning repositories make sure you have read the [Setup](http://totem-docs.herokuapp.com/1.0.0/setup/environment) process. When you get to the part of [cloning](http://totem-docs.herokuapp.com/1.0.0/setup/environment#clone-repos) replace the url with the your own cloned versions from the steps below.

#### Commit Messages
*See [Commit Guide](http://totem-docs.herokuapp.com/1.0.0/git/commiting) for a more in-depth overview*

- **Prefix** your commit with most prevalent tag
  - [FIX] If a commit is fixing a bug/functionality
  - [MOD] If a commit is updating functionality
  - [ADD] If a commit is adding functionality
  - [RM] If a commit is removing functionality
  - [WIP] If a commit is in progress for new functionality
- **Subject**
  - **~50** characters for the subject to keep the commit subject concise. Use the body if further explanation is required.
  - **Imperative** not _indicative_
  -**Capitalize** the first letter in the subject
  -**No period** at the end of the subject
  - **Newline** between subject and body
- **Body**
  - **Wrap** at 72 characters
  - **What & Why** not _How_
  - **Bullet points** are also allowed in place of or with paragraphs
  - **Tag** any closing or references to issues on github

```
  # Example Commit
  [ADD] Foo to the test function

  This function was not correctly calculating due to the missing foo. Adding this back allows for the system to properly function with some added benefits.

  - Foo added to method
  - No longer requires Bar as internal variable

  Closes #42
```

#### Forking
To best contribute changes to the source fork the main repo by going to github a click `Fork` in the upper right. By doing this you are essentially creating the current state of the repository into your own personal copy.

Once you have forked the repository you can clone it to your local environment in the corresponding directories

```
  git clone git@github.com:USERNAME/FORKED-PROJECT.git ~/Desktop/ember20/repos
```

Keeping your fork up to date isn't required if its a quick change, but to make sure you have all up to date changes add a remote upstream

```
  # Add 'upstream' repo to list of remotes
  git remote add upstream https://github.com/UPSTREAM-USER/ORIGINAL-PROJECT.git

  # Verify the new remote named 'upstream'
  git remote -v
```

Now when you want to make sure you have the latest changes with the upstream repository just fetch and merge the upstream

```
  # Fetch from upstream remote
  git fetch upstream

  # View all branches, including those from upstream
  git branch -va

  # Checkout your master branch and merge upstream
  git checkout master
  git merge upstream/master
```

#### Branching

Now with your up to date upstream and local master branches make your own local branch and code away!

```
  # Checkout the master branch - you want your new branch to come from master
  git checkout master

  # Switch to your new branch
  git checkout -b new-feature
```

#### Pull Requests
Before submitting your pull request make sure you rebase your branch so that it becomes a simple fast-forward merge

```
  # Fetch upstream master and merge with your repo's master branch
  git fetch upstream
  git checkout master
  git merge upstream/master

  # If there were any new commits, rebase your development branch
  git checkout newfeature
  git rebase -i master
```

For more information about how to rebase see Atlassian's guide [here](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase/).

Now that you have rebased your changes to a single commit go to the original upstream repository and create a pull request. For a step by step see Github's [Creating a pull request from a fork](https://help.github.com/articles/creating-a-pull-request-from-a-fork/).

## Licenses 
We currently use the MIT Licencse explicit [here](https://github.com/sixthedge/cellar/blob/master/LICENSE.md)
