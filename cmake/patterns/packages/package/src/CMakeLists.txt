# Use PID_Component below to declare library or script components and PID_Documentation to document them
# The full documentation is available here https://pid.lirmm.net/pid-framework/assets/apidoc/html/pages/Package_API.html
#
# Common usages for a C or C++ library and a Python script, but tweek them to your needs
#
# PID_Component(
#   my-lib
#   DESCRIPTION ...
#   USAGE <list of headers to include to use the component>
#   DEPEND <list of internal dependencies>
#   EXPORT <list of public dependencies>
#   C_STANDARD 11
#   CXX_STANDARD 17
#   WARNING_LEVEL MORE
# )
#
# PID_Component(
#   my-script
#   DESCRIPTION ...
# )
#
# PID_Documentation(
#   COMPONENT my-lib 
#   FILE mylib_usage.md
# )
