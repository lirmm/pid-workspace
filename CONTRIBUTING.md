# Contribution Guide

Any contribution is welcome:

- new functionalities, new OS support
- patches for BUGS
- better comments and documentation

To provide a contribution to pid-workspace:

+ use the pull/merge request mechanism of the git hosting service this project is published on (github, gitlab.com, gitlab private instance).
+ follow guidelines explained in next section.

## Getting Started

+ Create an account in the current git hosting service if you have none already.
+ Fork the current project in a personnal or group/team/organization namepace.
+ Take a look at the [Git Best Practices](http://sethrobertson.github.com/GitBestPractices/) document.


## Identifying the type of contribution

You should let the developper team know what is the problem, what needs to be done and/or what you're planning to do by using issues of this project. This way you can also get advices from developper team to help you to define what kind of contribution you want to provide:

+ **APIs changes**: new functionalities, patches for BUG, better comments, etc.
+ **Documentation changes**: new tutorials, better install procedure, etc.
+ **Core runtime mechanism**: new C/C++ API to do things at runtime
+ **Updating official references to projects**: adding references to new projects into the PID official contribution space.

Depending on what you want to do you will have to perform different actions on different projects. Only API changes are applied to current repository, other apply to other projects. Nevertheless you should always follow the typical procedure explained below.

## Typical procedure

+ Fork the project
+ Create a local clone of your fork in your workstation.
+ Create a topic branch for your work off the master branch. Name your branch by the type and nature of your contribution, e.g.  `fix_bug/my_contribution`, `api_change/my_contribution`, `api_doc/my_contribution`, `ref/my_contribution`, etc. For instance:

```
git checkout master && git pull && git checkout -b fix_bug/my_contribution
```
+ Don't work directly on the master branch. Your pull request will be rejected unless it is on a topic branch.
+ Create distinct commits for distinct modifications. A commit should do one thing, and only one thing. Please follow the following format:
  - Related issue number (`#12`)
  - Summary of commit utility.
+ Push your changes to the same topic branch in your fork of the repository.
+ Submit a pull/merge request to this repository. You should always ask to PID developpers on which branch to merge your contribution. By default use the `integration` branch.

## Proposing modifications

### API Changes

Anytime you want to modify APIs and commands provided by PID you have to directly modify the current project.
So you need to modify this repository which is not allowed is your are not part of the developper team. You need to use the fork / merge request mechanism to propose new content. If you need a team to test your API changes, please follow the install procedure explained in this project README.  

### Documentation Changes

Documentation is achieved in a specific way in PID, through projects called frameworks. These projects are used to generate static web sites with a predefined pattern.
To contribute to [PID static site documentation](http://pid.lirmm.net/pid-framework/index.html) you need to contribute to the project called `pid-framework`, that contains markdown/html/jekyll description of the documentation. As each `framework` has a git repository you simply need to fork and propose merge request to the `pid-framework` repository. If this later is not already available on the current hosting service, **open an issue to get `pid-framework`**.

### Updating official references to projects

This consists in publishing files that are used to reference content generated with PID methodology. This is achieved in a specific way in PID, through projects called `contribution spaces` (in some ways it can be seen as an equivalent of a CONAN remote). To publish or update references to official PID content you need to modify the `pid-contributions` project. As each `contribution space` has a git repository you simply need to fork and propose merge request to the `pid-contributions` repository.  If this later is not already available on the current hosting service, **open an issue to get `pid-contributions`**.

Note: you can provide your own `contribution space` so updating PID official one is only meaningfull if you intend to publish your packages to the largest possible audience.

### Updating core runtime mechanisms

Contributing to runtime mechanisms of PID basically consists in providing new package(s) or modifying existing packages. In both case **use an issue to get the given package(s)** in the current hosting service. Then fork these packages and finally propose your modifications through merge requests.

Notes:

+ this kind of contributions should be **reserved to experienced users**.
+ for new packages, they should should also be [referenced into official contribution space](#updating-official-references-to-projects) and may most of time lead to [changes in documentation](#documentation-changes).
+ this may also lead to some [changes in the API](#api-changes).
