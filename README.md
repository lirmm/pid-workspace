
# Introduction

PID is a development methodology used to standardize and automate the development process of C/C++ projects. The present repository contains the base implementation of PID, based on CMake scripts.

This project defines a **workspace** where users put their C/C++ projects and the workspace repository is used to share references on existing projects, in order to deploy them on users workstations. For deeper understanding and learning of PID, you can refer to [this website](http://pid.lirmm.net/pid-framework)

# What is it useful for ?

The term "methodoloy" is supposed to cover all phases of the development process. My intent when I first write this framework is to provide a packaging system where people can easily share and reuse the projects they work(ed) on, either under source of binary format. Indeed, in the context of my laboratory (LIRMM, Montpellier, France), and more precisely for robotic teams, we had no real frame to develop and share our projects which lead to tremendously complex reuse of code.

The basic idea is to formalize as far as possible (using a CMake API) all aspects of the project (being it software they generate, projects then depends on, way to deal with git branches, available version released, prebuild binaries already available online, documentation or licensing aspects, and so on). This way PID automates everything related to project development in a kind of standard "way of doing".

People that can be interested in using PID are project managers that want to enforce a way to ease sharing and integration of code in their team or institution, but it may be also useful for lone programmers that simply want a clean method for developping their code.

# Key Features

+ Fully based on CMake and git.
+ Management of C/C++ projects in a common an standardized way (same basic commands and options to manage the build process for all projects).
+ Languages supported are: basically C/C++ are fully managed. Fortran and ASSEMBLER languages are also supported as well as CMake does, and their code can be merged with C/C++ code in a transparent way. Python is also supported, notably for the creation of python wrappers for C/C++ code.
+ Management of source and binary packages in a common way.
+ Management of external binary packages and OS dependencies.
+ Formalization of packages dependencies and versions, automating deployment of dependencies (either binary or source).
+ Installation of packages is local (no modification of OS configuration, as far as possible).
+ Standardizing and Automating the release, publishing and deployment process of packages.
+ Standardizing the continuous integration process (based on gitlab ci)
+ Standardizing and Automating online documentation generation (based on gitlab pages, jekyll, doxygen, cppchecks and lcov).
+ Management of repositories for binaries (based on gitlab pages).
+ Standardizing and Automating license management (applying liecnse information everywhere needed), as well as other meta information about the package (authors, contact, etc.).
+ Plugin mechanism to provide additionnal functionalities to manage external tools (typically IDE). For instance a plugin used to configure `atom-clang-complete` plugin in Atom IDE.
+ Standardization and management of build environments and target platforms, to allow the management of many execution targets for the same code and easily change the build environment to use (for instance changing the compiler in use for all packages). These features can be used to manage crosscompilation.

# Known Limitations

 + **Operating systems**: PID should work on most of UNIX platforms. It has been tested on Ubuntu, Arch Linux and Raspbian. Many UNIX systems have never or rarely been tested like SolarisOS, FreeBSD, iOS or MACOS as well as many Linux distributions (RedHat, Gentoo) and derivatives (Android). But these OS can be supported with little effort (PID being mostly cross-platform). For now **Windows is not supported**.
 + **Gilab**: the CI is **limited to only one target platform**, in consequence only one binary archive per released version of packages can be automatically released and not many (for many platforms).

# Install

Please refer to [PID framework website](http://pid.lirmm.net/pid-framework) to get the complete install procedure.

Installing the PID framework is a simple task, as soon as you have adequate dependencies:

- cmake, version 3.0.2 or greater
- git, version 1.7.6 or greater

## if you are a project manager and want to put in place a common isolated environment for your team(s)

+ fork this repository and/or clone it into your own repository server. For instance we use a private instance of gitlab in my laboratory and our official pid-workspace is a specific project in this server. The fork is usefull if you want to provide your modifications (contributions to PID or referencing of your packages) to other teams and people around the world. Indeed the current repository may be used as the global "marketplace" for everyone (this is mainly interesting for open source projects) .

For now let's call the the pid-workspace you just fork "**your team official repository**".

+ clone **your team official repository** in your workstation

```bash
> git clone **your team official repository**
```

+ configure your local repository:

```bash
> cd pid-workspace/pid
> cmake -DPID_OFFICIAL_REMOTE_ADDRESS=**your team official repository** .. #or use cmake gui to set this variable
```

That's it your team can start working in an isolated environment. This action ensures that you will not be affected by modifications of this current repository unless you specifically decide it (using a dedicated git remote pointing to the current repository).


## if you are member of a team with a specific team official repository

+ fork **your team official repository** (the address should be given by your team leader). The forked repository is your **private repository**, it will be usefull to share your contributions with other members of the team.

+ clone your **private repository** on your workstation(s):

```bash
> git clone **private repository**
```

+ configure your local repository:

```bash
> cd pid-workspace/pid
> cmake -DPID_OFFICIAL_REMOTE_ADDRESS=**your team official repository** ..
```

## if you are a lone developper and want to contribute (for instance you want to publish open source packages)

+ fork this repository so that you can use merge requests to provide your contributions. The forked repository becomes **your official repository**.

+ clone**your official repository** in your workstation:

```bash
> git clone **your official repository**
```

+ configure your local repository:

```bash
> cd pid-workspace/pid
> cmake -DPID_OFFICIAL_REMOTE_ADDRESS=**your official repository** ..
```

That's it you can start working in an isolated environment. This action ensures that you will not be affected by modifications of this repository unless you specifically decide it (using a dedicated git remote pointing to the current repository).


## if you just want to use PID to install some packages provided by third-parties

+ simply clone the current repository into your workstation.

```bash
> git clone **this repository**
```
+ Then configure your workspace:

```bash
> cd pid-workspace/pid
> cmake -DPID_OFFICIAL_REMOTE_ADDRESS=**this repository** ..
# or use the LIRMM official repository (recommended for LIRMM members)
> cmake ..
```

## Final steps

I recommend to read the documentation in this [website](http://pid.lirmm.net/pid-framework). You will find many resources explaining how to start using PID.

# About the license

pid-workspace and PID base packages are licensed with the CeCILL-C open source license. A copy of the license is available in the file license.txt.

CeCILL-C is an open source software license equivalent to and compatible with GNU LGPL. The difference is that it is governed by French law and disagreements or disputes shall be referred to the Paris Courts having jurisdiction.

# Contribution

Any contribution is welcome:

- new functionalities, new OS support
- patches for BUGS
- better comments and documentation

To provide a contribution to the pid-workspace simply use the pull/merge request mechanism.

If you want to contribute to packages consituting the pid framework that cannot be forked from online repository, simply ask me I will provide them on your favorite online repository hosting service.

If you want to contribute to the documentation of overall pid framework, or to contribute to binary package referencing, I can do the same for the repository describing this framework.

# Contact

For any question, remark, proposal about PID, please **contact me using the issues** of the project.
