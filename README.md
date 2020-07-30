# Introduction

PID stands for *Packages Integrated Development*. It is a development methodology used to standardize and automate the development process of C/C++ projects. The present repository contains the base implementation of PID, based on CMake APIs and commands.

This project defines a **workspace** where users put their C/C++ projects but also contains implemntation of commands and CMake APIs used to define projects. For a deeper understanding and start learning PID, you can refer to [this website](http://pid.lirmm.net/pid-framework).

# What is it useful for ?

The term "methodoloy" is supposed to cover all phases of code development process. The goal is to provide a packaging system where people can easily share and reuse the projects they work(ed) on, either under source or binary format. Indeed, in the context of my laboratory (LIRMM, Montpellier, France), and more precisely for robotic teams, we had no frame to develop and share our projects which lead to tremendously complex reuse of code.

The basic idea is to use a CMake API to describe all aspects of the project in the most precise and formal way: software they generate ; projects then depends on ; git branches they define; available versions released ; prebuild binaries already available online ; documentation or licensing aspects and so on. This way PID automates everything related to software project development in a kind of standard "way of doing".

PID is designed for solving most common (and sometimes difficult) problems we can face during C/C++ project development.

# Key Features

+ **Standardization of C/C++ projects**
   - same basic structure, concepts, commands and options to manage the life cycle of projects.  
   - `CMake` APIs for a clean description of projects.
   - based on `git` and `Gitlab` tools for lifecycle management and continuous integration.
+ **Languages supported**
   - C/C++, CUDA, Fortran and ASSEMBLER
   - Python (support of python bindings and python scripts).
+ **Automation of package life cycle management**: CMake generated commands to configure, build/test, release versions, publish online documentation, upload binary archives in repositories, deliver and deploy package on a computer.
+ **Automatic resolution of dependencies and constraints**
  - resolution of eligible versions of dependencies
  - check for target platform binary compatiblity
  - automatic deployment of required dependencies versions (from source repositories or binary archives).
+ **Automation of Continuous Integration / Delivery process**
  - generation of online documentation (static site, API, check tools reports)
  - management of online repositories for generated binary archives of package versions.
  - CI/CD process managed for concurrent platforms (only gitlab-CI for now).
+ **Support for customization**
   - change build environements and target binary platforms in use, manage cross-compilation (based on CMake features).
   - add new support for new development tools : specific support of an IDE ; dependencies management tools like `pkg-config` ; code generators like `f2c`, etc.
+ **Cross platform implementation**
  - PID should work on most of UNIX platforms. It has been tested on Ubuntu, Debian, Fedora, Arch Linux, FreeBSD, MACOS and Raspbian. Many UNIX systems have never or rarely been tested like SolarisOS, iOS  as well as many Linux distributions (RedHat, Gentoo) and derivatives (Android). But these OS can be supported with little effort (PID being mostly cross-platform).
  - Support for Windows is still experimental.

# Install

Please refer to [PID framework website](http://pid.lirmm.net/pid-framework) to get the complete install procedure.

## Essential Dependencies  

Installing the PID framework is a simple task, as soon as adequate dependencies are installed on your workstation:

- CMake, version 3.8.2 or greater
- git, version 1.7.6 or greater
- git-lfs, version 2.6 or greater

Other dependencies may be required, but their need is not mandatory by default.

## Basic install procedure  

This procedure is the standard one and should be the preferred one for most of the users.

+ clone this repository somewhiere in your filesystem

```bash
cd /path/to/somewhere
git clone <pid-workspace repository>
```
Change `<pid-workspace repository>` by the address of this project in the hosting service (github, gitlab) you are currenlty using.

+ configure **your local repository**

```bash
cd pid-workspace
./pid configure
```

This step initializes the PID system, more precisely:
+ the current host platform you are using is automatically identified
+ official contributions are automatically configured so that you can use some default material already provided by pid.
+ configure the workspace repository to make it capable of upgrading CMake APIs.

Furthermore the `pid` script alert you to source a script so that you can easily use the `pid` command. You can now start using PID methdology. To test if everything works you can do:

```bash
pid deploy package=pid-rpath
```

This should end in the deployment of the last released version of a package named `pid-rpath`.

To get a manual of available commands:

```bash
pid man
```

## Final steps

Now read the [documentation of PID](http://pid.lirmm.net/pid-framework). You will find many resources explaining how to start using PID.

# About the license

pid-workspace and PID base packages are licensed with the CeCILL-C open source license. A copy of the license is available in the file license.txt.

CeCILL-C is an open source software license equivalent to and compatible with GNU LGPL. The difference is that it is governed by French law and disagreements or disputes shall be referred to the Paris Courts having jurisdiction.

# Contact

For any question, remark, proposal about PID, please **contact authors using the issues** of the project.
