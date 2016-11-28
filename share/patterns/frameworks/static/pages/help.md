---
layout: page
title: Help
---

# What is this site ?

This is the documentation site of the {{ site.data.framework.framework_name}} framework. A **framework** is a collection of libraries, executables and other software artifacts. 

The site has been automatically generated using jenkins, configured using CMake and updated/published using gitlab, based on a dedicated development environment called **PID**. Technically, this site has been generated from [this source repository]({{site.data.framework.framework_git_project}}) (you may have no access to the repository project).

In **PID** environment **frameworks** are agregates of **packages**, each **package** containing any kind of software artifacts (libraries, executables, configuration files and more generally any kind of filesystem resources). They allow to put into a common place any information about these packages (either for developpers or end-users).

 
# How to use this site ?

This site has the same general "look and feel" as any other [framework in PID](# What is this site ?):

- The header bar provides menus that help you navigate between different global pages of the framework.
  - **Documentation** provides submenus to access all kind of documentation of the framework:
    + *Introduction* : quick introduction to the framework purpose.
    + *Install* : to get installation instructions.
    + *Tutorial* : to get information about how using the framework.
    + *More* : to get more information on advanced topics.
 
  - **Activity** provides the history of last activities in the framework. These activities consist in:
    + Information about packages update. Any time a new version is released, the activity get a new post.
    + Information about global modification of the framework site global content.

  - **About** provides this help page and a contact page.

- The left sidebar provides an entry for each **package** belonging to the framework. By cliking on it you can simply go to the package page. The package page has a header that allows to navigate between package elements.
  - **Documentation** provides submenus to access all kind of documentation of the framework:
    + *Introduction* : quick introduction to the package purpose.
    + *Install* : to get installation instructions.
    + *Use* : to know of to use libraries in your own programs
    + *Tutorial* : to get information about how to use the package.
    + *More* : to get more information on advanced topics.

  - **Developers**  provides submenus to get info about the development of the package (some of these section may be unavailable depending on the package)
    + *API documentation* lets you consult the **doxygen** generated documentation of the package (last release version only).
    + *Static Cheks* lets you consult the **cppcheck** generated report of static checks on the package (last release version only).
    + *Coverage* lets you consult the **lcov** generated report of tests coverage on the package (last release version only).
    + *Binaries* lets you navigate between all available binaries (different versions for different platforms).

  - **Contact** tells you who to contact to get help.


