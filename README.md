
# Introduction

PID is a development methodology used to standardize and automate the development process of C/C++ projects. The present repository contains the base implementation of PID, based on CMake scripts.

This project defines a **workspace** where users put their C/C++ projects and the workspace repository is used to share references on existing projects, in order to deploy them on users workstations.

PID is also a framwork, made of various C/C++ packages, that are helpful for developping C/C++ code. For deeper understanding and learning of PID readers can refer to [this website](http://pid.gite.lirmm.io/pid-framework)

# Install

Installing the PID framework is a simple task, as soon as you have adequate dependencies:

- cmake, version 3.0.2 or greater
- git, version 1.7.6 or greater

Then to install PID you have to clone this repository or (preferably) to clone a fork of this repository:

```bash
> git clone git@gite.lirmm.fr:pid/pid-workspace.git
> cd pid-workspace/pid
> cmake ..
```
Please refer to [PID framework website](http://pid.gite.lirmm.io/pid-framework) to get the complete install procedure.

# Contact

If you have any question about PID, please contact Robin Passama (passama@lirmm.fr).

