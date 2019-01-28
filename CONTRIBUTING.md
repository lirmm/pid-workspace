# Contribution Guide

Any contribution is welcome:

- new functionalities, new OS support
- patches for BUGS
- better comments and documentation
- references of packages

To provide a contribution to pid-workspace:

+ use the pull/merge request mechanism of the git hosting service this project is published on (github, gitlab.com, gitlab private instance).
+ follow guidelines explained in next section.

## Getting Started

+ Create an account in the current git hosting service if you have none already.
+ Fork the current project in a personnal or group/team/organization namepace.
+ Take a look at the [Git Best Practices](http://sethrobertson.github.com/GitBestPractices/) document.


## Identifying the type of contribution

You should let the community know what is the problem, what needs to be done and/or what you're planning to do by using issues of this project. This way you can also get advices from PID developper team to help you to define what kind of contribution you want to provide:

+ **APIs changes**: new functionalities, patches for BUG, better comments, etc.
+ **Referencing**: adding new projects to the PID registry.
+ **Documentation changes**: new tutorials, better install procedure, etc.
+ **Core runtime mechanism**: new C/C++ API to do things at runtime

Depending on what you want to do you will have to perform different actions:

+ Most frequent operations are **APIs changes** and  **Referencing**, they consist in modifying this project.
+ To contribute to [static site documentation](http://pid.lirmm.net/pid-framework/index.html) you need to contribute to another project called `pid-framework`, that contains markdown/html/jekyll description of the documentation. If `pid-framework` is not already on the current hosting service, **open an issue here to ask opening access to `pid-framework`**.
+ Contributing to runtime mechanisms of PID basically consists in providing new package(s) or modifying existing packages. In both case **use an issue to ask PID developpers to give you access to the given package(s)** in the current hosting service. Anyway this kind of contribution should be **reserved to experiened users**.

In the following section we focus only on how to contribute to the pid-workspace project.

### Contributing to the pid-workspace project

Whether you want to modify API or referencing new projects you have to use the pull/merge request mechanism with with this project.

Here is the typical procedure:

+ Create a local clone of your fork in your workstation.
+ Create a topic branch for your work off the master branch. Name your branch by the type and nature of your contribution, e.g.  `fix_bug/my_contribution`, `api_change/my_contribution`, `api_doc/my_contribution`, `ref/my_contribution`, etc.

```
git checkout master && git pull && git checkout -b fix_bug/my_contribution
```
+ Don't work directly on the master branch, or any other core branch. Your pull request will be rejected unless it is on a topic branch.
+ Create distinct commits with messages [in the proper format](#commit-message-format). A commit should do one thing, and only one thing. For instance if you reference new packages, create one commit per package.
+ Push your changes to the same topic branch in your fork of the repository.
+ Submit a pull/merge request to this repository. You should always ask to PID developpers on which branch to merge your contribution. By default use the `development` branch.

## Commit Message Format

Whenever you create a commit you should follow this pattern for the commit message:

+ Summary of commit utility.
+ Related issue number (`#12`)
