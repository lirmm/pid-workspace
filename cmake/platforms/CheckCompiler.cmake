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

#check simply ised to have a clean and standardized way to get compiler identification in PID

# adapted from https://github.com/lefticus/cpp_starter_project/blob/master/cmake/CompilerWarnings.cmake
set(MSVC_MORE_WARNINGS
  /W4 # Baseline reasonable warnings
)
set(MSVC_ALL_WARNINGS
  ${MSVC_MORE_WARNINGS}
  /w14242 # 'identifier': conversion from 'type1' to 'type1', possible loss of data
  /w14254 # 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
  /w14263 # 'function': member function does not override any base class virtual member function
  /w14265 # 'classname': class has virtual functions, but destructor is not virtual instances of this class may not
          # be destructed correctly
  /w14287 # 'operator': unsigned/negative constant mismatch
  /we4289 # nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside
          # the for-loop scope
  /w14296 # 'operator': expression is always 'boolean_value'
  /w14311 # 'variable': pointer truncation from 'type1' to 'type2'
  /w14545 # expression before comma evaluates to a function which is missing an argument list
  /w14546 # function call before comma missing argument list
  /w14547 # 'operator': operator before comma has no effect; expected operator with side-effect
  /w14549 # 'operator': operator before comma has no effect; did you intend 'operator'?
  /w14555 # expression has no effect; expected expression with side- effect
  /w14619 # pragma warning: there is no warning number 'number'
  /w14640 # Enable warning on thread un-safe static member initialization
  /w14826 # Conversion from 'type1' to 'type_2' is sign-extended. This may cause unexpected runtime behavior.
  /w14905 # wide string literal cast to 'LPSTR'
  /w14906 # string literal cast to 'LPWSTR'
  /w14928 # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
  /permissive- # standards conformance mode for MSVC compiler.
)
set(MSVC_WARNINGS_AS_ERRORS
  /WX
)

set(CLANG_MORE_WARNINGS
  -Wall
  -Wextra # reasonable and standard
)
set(CLANG_ALL_WARNINGS
  ${CLANG_MORE_WARNINGS}
  -Wshadow # warn the user if a variable declaration shadows one from a parent context
  -Wnon-virtual-dtor # warn the user if a class with virtual functions has a non-virtual destructor. This helps
                    # catch hard to track down memory errors
  -Wold-style-cast # warn for c-style casts
  -Wcast-align # warn for potential performance problem casts
  -Wunused # warn on anything being unused
  -Woverloaded-virtual # warn if you overload (not override) a virtual function
  -Wpedantic # warn if non-standard C++ is used
  -Wconversion # warn on type conversions that may lose data
  -Wsign-conversion # warn on sign conversions
  -Wnull-dereference # warn if a null dereference is detected
  -Wdouble-promotion # warn if float is implicit promoted to double
  -Wformat=2 # warn on security issues around functions that format output (ie printf)
)
set(CLANG_WARNINGS_AS_ERRORS
  -Werror
)

set(GCC_MORE_WARNINGS
  ${CLANG_MORE_WARNINGS}
)
set(GCC_ALL_WARNINGS
  ${CLANG_ALL_WARNINGS}
  -Wmisleading-indentation # warn if indentation implies blocks where blocks do not exist
  -Wduplicated-cond # warn if if / else chain has duplicated conditions
  -Wduplicated-branches # warn if if / else branches have duplicated code
  -Wlogical-op # warn about logical operations being used where bitwise were probably wanted
  -Wuseless-cast # warn if you perform a cast to the same type
)
set(GCC_WARNINGS_AS_ERRORS
  ${CLANG_WARNINGS_AS_ERRORS}
)

if (CMAKE_ASM_COMPILER_ID MATCHES "GNU" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CURRENT_ASM_COMPILER "gcc")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "Clang|clang")
  set(CURRENT_ASM_COMPILER "clang")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "AppleClang")
  set(CURRENT_ASM_COMPILER "appleclang")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "MSVC")
  set(CURRENT_ASM_COMPILER "msvc")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "icc|icl|Intel|intel")
  set(CURRENT_ASM_COMPILER "icc")
else()
  set(CURRENT_ASM_COMPILER ${CMAKE_ASM_COMPILER_ID})
  message("[PID] WARNING: current profile use an unsupported ASM compiler: ${CURRENT_ASM_COMPILER}.")
endif()

macro(set_Compiler_Warnings_Options compiler)
  set(CURRENT_CXX_COMPILER_WARN_MORE_OPTIONS ${${compiler}_MORE_WARNINGS})
  set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS ${${compiler}_ALL_WARNINGS})
  set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS ${${compiler}_WARNINGS_AS_ERRORS})
endmacro(set_Compiler_Warnings_Options)


if (CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CURRENT_CXX_COMPILER "gcc")
  set_Compiler_Warnings_Options(GCC)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|clang")
  set(CURRENT_CXX_COMPILER "clang")
  set_Compiler_Warnings_Options(CLANG)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
  set(CURRENT_CXX_COMPILER "appleclang")
  set_Compiler_Warnings_Options(CLANG)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  set(CURRENT_CXX_COMPILER "msvc")
  set_Compiler_Warnings_Options(MSVC)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "icc|icl|Intel|intel")
  set(CURRENT_CXX_COMPILER "icc")
  set_Compiler_Warnings_Options(CLANG) # doesn't seem to handle GCC warnings according to this https://rubyci.org/logs/rubyci.s3.amazonaws.com/icc-x64/ruby-trunk/log/20171028T000002Z.fail.html.gz
else()
  set(CURRENT_CXX_COMPILER ${CMAKE_CXX_COMPILER_ID})
  message("[PID] WARNING: current profile use an unsupported C++ compiler: ${CURRENT_CXX_COMPILER}. You should face troubles with most of packages.")
endif()

if (CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CURRENT_C_COMPILER "gcc")
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang|clang")
  set(CURRENT_C_COMPILER "clang")
elseif(CMAKE_C_COMPILER_ID MATCHES "AppleClang")
  set(CURRENT_C_COMPILER "appleclang")
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
  set(CURRENT_C_COMPILER "msvc")
elseif(CMAKE_C_COMPILER_ID MATCHES "icc|icl|Intel|intel")
  set(CURRENT_C_COMPILER "icc")
else()
  set(CURRENT_C_COMPILER ${CMAKE_C_COMPILER_ID})
  message("[PID] WARNING: current profile use an unsupported C compiler: ${CURRENT_C_COMPILER}. You should face troubles with most of packages.")
endif()
#all those languages are available by default
set(ASM_Language_AVAILABLE TRUE CACHE INTERNAL "")
set(C_Language_AVAILABLE TRUE CACHE INTERNAL "")
set(CXX_Language_AVAILABLE TRUE CACHE INTERNAL "")

#registering global knowledge on compiler toolchains
#MOST of information comes from https://en.cppreference.com/w/cpp/compiler_support
set(KNOWN_CXX_COMPILERS gcc clang appleclang msvc icc CACHE INTERNAL "")
set(KNOWN_CXX_STANDARDS 11 14 17 20 CACHE INTERNAL "")
set(KNOWN_CXX_STDLIBS stdc++ c++ msvc CACHE INTERNAL "")
#gcc
set(gcc_std11_BEGIN_SUPPORT 4.8.1 CACHE INTERNAL "")#before version 4.8.1 of gcc the c++ 11 standard is not fully supported
set(gcc_std14_BEGIN_SUPPORT 5.0 CACHE INTERNAL "")#before version 5.0 of gcc the c++ 14 standard is not fully supported
set(gcc_std17_BEGIN_SUPPORT 9.1 CACHE INTERNAL "")#before version 9.1 of gcc the c++ 17 standard is not fully supported
set(gcc_std20_BEGIN_SUPPORT 12.0 CACHE INTERNAL "")#approximation: before version 12.0 of gcc the c++ 17 standard is not fully supported
set(gcc_PREFERRED_ENVIRONMENT gcc_toolchain CACHE INTERNAL "")
#clang
set(clang_std11_BEGIN_SUPPORT 3.3 CACHE INTERNAL "")
set(clang_std14_BEGIN_SUPPORT 3.4 CACHE INTERNAL "")
set(clang_std17_BEGIN_SUPPORT 6 CACHE INTERNAL "")
set(clang_std20_BEGIN_SUPPORT CACHE INTERNAL "")
set(clang_PREFERRED_ENVIRONMENT clang_toolchain CACHE INTERNAL "")
#appleclang
set(appleclang_std11_BEGIN_SUPPORT 10.0 CACHE INTERNAL "")
set(appleclang_std14_BEGIN_SUPPORT 10.0 CACHE INTERNAL "")
set(appleclang_std17_BEGIN_SUPPORT 10.0 CACHE INTERNAL "")
set(appleclang_std20_BEGIN_SUPPORT CACHE INTERNAL "")
set(appleclang_PREFERRED_ENVIRONMENT CACHE INTERNAL "")
#msvc
set(msvc_std11_BEGIN_SUPPORT 19.14 CACHE INTERNAL "")
set(msvc_std14_BEGIN_SUPPORT 19.14 CACHE INTERNAL "")
set(msvc_std17_BEGIN_SUPPORT 19.24 CACHE INTERNAL "")
set(msvc_std20_BEGIN_SUPPORT 19.29 CACHE INTERNAL "")
set(msvc_PREFERRED_ENVIRONMENT CACHE INTERNAL "")
#icc
set(icc_std11_BEGIN_SUPPORT 15.0 CACHE INTERNAL "")
set(icc_std14_BEGIN_SUPPORT 17.0 CACHE INTERNAL "")
set(icc_std17_BEGIN_SUPPORT 19.0.1 CACHE INTERNAL "")#approximation
set(icc_std20_BEGIN_SUPPORT CACHE INTERNAL "")
set(icc_PREFERRED_ENVIRONMENT CACHE INTERNAL "")
#stdc++
set(stdc++_std11_BEGIN_SUPPORT 6 CACHE INTERNAL "")#before version 6 of libstdc++ the c++ 11 standard is not fully supported
set(stdc++_std14_BEGIN_SUPPORT 6 CACHE INTERNAL "")#before version 6 of libstdc++ the c++ 14 standard is not fully supported
set(stdc++_std17_BEGIN_SUPPORT 9 CACHE INTERNAL "")#before version 9 of libstdc++ the c++ 17 standard is not fully supported
set(stdc++_std20_BEGIN_SUPPORT 12 CACHE INTERNAL "")#before version 12 of libstdc++ the c++ 20 standard is not fully supported
#c++
set(c++_std11_BEGIN_SUPPORT 3.8 CACHE INTERNAL "")#before version 3.8 of libc++ the c++ 11 standard is not fully supported
set(c++_std14_BEGIN_SUPPORT 3.8 CACHE INTERNAL "")#before version 3.8 of libc++ the c++ 14 standard is not fully supported
set(c++_std17_BEGIN_SUPPORT 15 CACHE INTERNAL "")#There are still a few missing C++17 features but if we want to build some C++17 code in CI with macOS Catalina we don't have a choice
set(c++_std20_BEGIN_SUPPORT CACHE INTERNAL "")#not supported yet

