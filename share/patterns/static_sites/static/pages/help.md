---
layout: page
title: Help
---

## What is this site ?

This is the documentation site of the {{ site.data.package.package_name}} package. A **package** is a git project defining a set of libraries, executables and other software artifacts. 

The site has been automatically generated using jenkins, configured using CMake and updated/published using gitlab, based on a dedicated development environment called **PID**. Technically, this site has been generated from [this source repository]({{site.data.package.package_git_project}}) (you may have no access to the repository project).

In **PID** environment each **package** contains any kind of software artifacts (libraries, executables, configuration files and more generally any kind of filesystem resources). They allow to put into a common place any information about a given project.


## How to use this site ?

This site has the same general "look and feel" as any other [package site in PID](#what-is-this-site-?):

- The header bar provides menus that help you navigate between different global pages of the packages.
  - **Documentation** provides submenus to access all kind of documentation of the framework:
    + *Introduction* : quick introduction to the package purpose.
    + *Install* : to get installation instructions.
    + *Use* : to know of to use libraries in your own programs
    {% if site.data.package.tutorial != "" %}
    + *Tutorial* : to get information about how to usie the package.
    {% endif %}
    {% if site.data.package.details != "" %}
    + *More* : to get more information on advanced topics.
    {% endif %}
{% if site.data.package.has_developper_info %}
  - **Developers** provides submenus to get info about the development of the package
    {% if site.data.package.has_apidoc %}
    + *API documentation* lets you consult the **doxygen** generated documentation of the package (last release version only).
    {% endif %}
    {% if site.data.package.has_checks %}
    + *Static Cheks* lets you consult the **cppcheck** generated report of static checks on the package (last release version only).
    {% endif %}
    {% if site.data.package.has_coverage %}
    + *Coverage* lets you consult the **lcov** generated report of tests coverage on the package (last release version only).
    {% endif %}
    {% if site.data.package.has_binaries %}
    + *Binaries* lets you navigate between all available binaries (different versions for different platforms).
    {% endif %}
{% endif %}
  - **Activity** provides the history of last activities in the package, anytime the package content has significantly evolved.
  - **About** provides this help page and a contact page.

