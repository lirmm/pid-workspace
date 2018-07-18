#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

set(pkg_config_PLUGIN_DESCRIPTION "use this plugin to generate configuration files for the pkg-config tool" CACHE INTERNAL "")

set(pkg_config_PLUGIN_ACTIVATION_MESSAGE "generating pkg-config modules..." CACHE INTERNAL "")

set(pkg_config_PLUGIN_ACTIVATED_MESSAGE "automatically generating pkg-config modules from packages description. To use pkg-config for retrieving generated libraries please set your environment variable PKG_CONFIG_PATH to ${WORKSPACE_DIR}/pid/share/pkgconfig (e.g. export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${WORKSPACE_DIR}/pid/share/pkgconfig). Typical usage: for building an executable use `pkg-config --static --cflags <name of the library>` ; for linking use `pkg-config --static --libs <name of the library>`" CACHE INTERNAL "")

set(pkg_config_PLUGIN_RESIDUAL_FILES "" CACHE INTERNAL "")#no residual file live in the source tree
