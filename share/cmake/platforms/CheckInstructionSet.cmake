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

#this code is mostly a rewritting of opencv compiler optimization detection

#define set of possible optimizations manages in PID
set(CPU_ALL_POSSIBLE_OPTIMIZATIONS SSE SSE2 SSE3 SSSE3 SSE4_1 SSE4_2 POPCNT AVX FP16 AVX2 FMA3 AVX_512F AVX512_SKX NEON VFPV3 VSX VSX3)
set(CPU_ALL_AVAILABLE_OPTIMIZATIONS) #empty by default, will be filled with trully available instructionset
#define corresponding source files used to check if correcponding instructions are available
set(CPU_SSE_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_sse.cpp")
set(CPU_SSE2_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_sse2.cpp")
set(CPU_SSE3_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_sse3.cpp")
set(CPU_SSSE3_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_ssse3.cpp")
set(CPU_SSE4_1_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_sse41.cpp")
set(CPU_SSE4_2_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_sse42.cpp")
set(CPU_POPCNT_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_popcnt.cpp")
set(CPU_AVX_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_avx.cpp")
set(CPU_AVX2_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_avx2.cpp")
set(CPU_FP16_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_fp16.cpp")
set(CPU_AVX_512F_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_avx512.cpp")
set(CPU_AVX512_SKX_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_avx512skx.cpp")
set(CPU_NEON_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_neon.cpp")
set(CPU_VSX_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_vsx.cpp")
set(CPU_VSX3_TEST_FILE "${WORKSPACE_DIR}/share/cmake/platforms/checks/cpu_vsx3.cpp")
#Note : FMA3 and VFPV3 will be checked only with options

#now detecting available processors specific instruction set, depending on processor type
if(CURRENT_TYPE STREQUAL x86)
  set(CPU_KNOWN_OPTIMIZATIONS SSE SSE2 SSE3 SSSE3 SSE4_1 POPCNT SSE4_2 FP16 FMA3 AVX AVX2 AVX_512F AVX512_SKX)
elseif(CURRENT_TYPE STREQUAL arm)
  if(CURRENT_ARCH EQUAL 32)
    set(CPU_KNOWN_OPTIMIZATIONS VFPV3 NEON FP16)
  elseif(CURRENT_ARCH EQUAL 64)
    set(CPU_KNOWN_OPTIMIZATIONS NEON FP16)
  endif()
elseif(CURRENT_TYPE STREQUAL ppc)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)64le")
    set(CPU_KNOWN_OPTIMIZATIONS VSX VSX3)
  endif()
endif()

#now defining which compiler options are used to enable the corresponding instruction set, depending on the compiler

if(CURRENT_TYPE STREQUAL "x86")
  if(CURRENT_C_COMPILER STREQUAL "icc")#C compiler is icc (specific case)
    macro(intel_compiler_optimization_option name unix_flags msvc_flags)
      if(CURRENT_CXX_COMPILER STREQUAL "msvc")
        set(enable_flags "${msvc_flags}")
        set(flags_conflict "/arch:[^ ]+")
      else()
        set(enable_flags "${unix_flags}")
        set(flags_conflict "-msse[^ ]*|-mssse3|-mavx[^ ]*|-march[^ ]+")
      endif()
      set(CPU_${name}_FLAGS "${enable_flags}")
      if(flags_conflict)
        set(CPU_${name}_FLAGS_CONFLICT "${flags_conflict}")
      endif()
    endmacro()
    intel_compiler_optimization_option(AVX2 "-march=core-avx2" "/arch:CORE-AVX2")
    intel_compiler_optimization_option(FP16 "-mavx" "/arch:AVX")
    intel_compiler_optimization_option(AVX "-mavx" "/arch:AVX")
    intel_compiler_optimization_option(FMA3 "" "")
    intel_compiler_optimization_option(POPCNT "" "")
    intel_compiler_optimization_option(SSE4_2 "-msse4.2" "/arch:SSE4.2")
    intel_compiler_optimization_option(SSE4_1 "-msse4.1" "/arch:SSE4.1")
    intel_compiler_optimization_option(SSE3 "-msse3" "/arch:SSE3")
    intel_compiler_optimization_option(SSSE3 "-mssse3" "/arch:SSSE3")
    intel_compiler_optimization_option(SSE2 "-msse2" "/arch:SSE2")
    if(NOT CURRENT_ARCH EQUAL 64) # x64 compiler doesn't support /arch:sse
      intel_compiler_optimization_option(SSE "-msse" "/arch:SSE")
    endif()
    intel_compiler_optimization_option(AVX_512F "-march=common-avx512" "/arch:COMMON-AVX512")
    intel_compiler_optimization_option(AVX512_SKX "-march=core-avx512" "/arch:CORE-AVX512")
  elseif(CURRENT_CXX_COMPILER STREQUAL "gcc" OR CURRENT_CXX_COMPILER STREQUAL "clang" )
    set(CPU_AVX2_FLAGS "-mavx2")
    set(CPU_FP16_FLAGS "-mf16c")
    set(CPU_AVX_FLAGS "-mavx")
    set(CPU_FMA3_FLAGS "-mfma")
    set(CPU_POPCNT_FLAGS "-mpopcnt")
    set(CPU_SSE4_2_FLAGS "-msse4.2")
    set(CPU_SSE4_1_FLAGS "-msse4.1")
    set(CPU_SSE3_FLAGS "-msse3")
    set(CPU_SSSE3_FLAGS "-mssse3")
    set(CPU_SSE2_FLAGS "-msse2")
    set(CPU_SSE_FLAGS "-msse")
    if(NOT (CURRENT_CXX_COMPILER STREQUAL "gcc" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0"))  # GCC >= 5.0
      # -mavx512f -mavx512pf -mavx512er -mavx512cd -mavx512vl -mavx512bw -mavx512dq -mavx512ifma -mavx512vbmi
      set(CPU_AVX_512F_FLAGS "-mavx512f")
      set(CPU_AVX512_SKX_FLAGS "-mavx512f -mavx512cd -mavx512vl -mavx512bw -mavx512dq")
    else()#for clang or gcc < 5.0 AVX is not supported
      list(REMOVE_ITEM CPU_ALL_POSSIBLE_OPTIMIZATIONS AVX_512F AVX512_SKX)
    endif()
  elseif(CURRENT_CXX_COMPILER STREQUAL "msvc")
    set(CPU_AVX2_FLAGS "/arch:AVX2")
    set(CPU_AVX_FLAGS "/arch:AVX")
    set(CPU_FP16_FLAGS "/arch:AVX")
    if(NOT CURRENT_ARCH EQUAL 64)
      set(CPU_SSE_FLAGS "/arch:SSE")
      set(CPU_SSE2_FLAGS "/arch:SSE2")
    else()  # 64-bit MSVC compiler uses SSE/SSE2 by default
      list(APPEND CPU_ALL_AVAILABLE_OPTIMIZATIONS SSE SSE2)
      list(REMOVE_ITEM CPU_ALL_POSSIBLE_OPTIMIZATIONS SSE SSE2)
    endif()
    # Other instruction sets are supported by default since MSVC 2008 at least
  else()
    message(WARNING "[PID] WARNING: Unsupported compiler when trying to detect processor optimizations")
  endif()
elseif(CURRENT_TYPE STREQUAL "arm")
  if(NOT CURRENT_ARCH EQUAL 64)
    if(NOT CURRENT_CXX_COMPILER STREQUAL "msvc")
      set(CPU_VFPV3_FLAGS "-mfpu=vfpv3")
      set(CPU_NEON_FLAGS "-mfpu=neon")
      set(CPU_FP16_FLAGS "-mfpu=neon-fp16")
    endif()
  else()
    set(CPU_NEON_FLAGS "")
  endif()
elseif(CURRENT_TYPE STREQUAL "ppc")
  if(CURRENT_CXX_COMPILER STREQUAL "clang")
    set(CPU_VSX_FLAGS "-mvsx -maltivec")
    set(CPU_VSX3_FLAGS "-mpower9-vector")
  else()
    set(CPU_VSX_FLAGS "-mcpu=power8")
    set(CPU_VSX3_FLAGS "-mcpu=power9 -mtune=power9")
  endif()

endif()

function(check_compiler_flag RESULT flag path_to_file)
  set(${RESULT} FALSE PARENT_SCOPE)
  if(path_to_file)
    set(file_to_compile ${path_to_file})
  elseif(NOT EXISTS "${CMAKE_BINARY_DIR}/CMakeTmp/src.cxx")
    set(file_to_compile "${CMAKE_BINARY_DIR}/CMakeTmp/src.cxx")
    if("${CMAKE_CXX_FLAGS} ${flag} " MATCHES "-Werror " OR "${CMAKE_CXX_FLAGS} ${flag} " MATCHES "-Werror=unknown-pragmas ")
      FILE(WRITE "${file_to_compile}" "int main() { return 0; }\n")
    else()
      FILE(WRITE "${file_to_compile}" "#pragma\nint main() { return 0; }\n")
    endif()
  else()
    set(file_to_compile "${CMAKE_BINARY_DIR}/CMakeTmp/src.cxx")
  endif()
  try_compile(COMPIL_RES "${CMAKE_BINARY_DIR}" "${file_to_compile}"
    CMAKE_FLAGS "-DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}"   # CMP0056 do this on new CMake
    COMPILE_DEFINITIONS "${flag}"
    OUTPUT_VARIABLE OUTPUT)
  set(${RESULT} ${COMPIL_RES} PARENT_SCOPE)
endfunction(check_compiler_flag)

function(check_compiler_optimization IS_SUPPORTED instruction_set)
  set(${IS_SUPPORTED} FALSE PARENT_SCOPE)
  if(CPU_${instruction_set}_FLAGS AND CPU_${instruction_set}_TEST_FILE)#if there is either a test file or a known compiler option for that instruction set
    check_compiler_flag(FLAG_OK "${CPU_${instruction_set}_FLAGS}" "${CPU_${instruction_set}_TEST_FILE}")
  elseif(CPU_${instruction_set}_TEST_FILE)#there is only a test file provided
    check_compiler_flag(FLAG_OK "" "${CPU_${instruction_set}_TEST_FILE}")
  elseif(CPU_${instruction_set}_FLAGS)#no test file only use flags
    check_compiler_flag(FLAG_OK "${CPU_${instruction_set}_FLAGS}" "")
  endif()
  if(FLAG_OK)
    set(${IS_SUPPORTED} TRUE PARENT_SCOPE)
  endif()
endfunction(check_compiler_optimization)

#check each possible instruction set for that CPU
foreach(instruction_set IN LISTS CPU_KNOWN_OPTIMIZATIONS)
  check_compiler_optimization(SUPPORTED ${instruction_set})
  if(SUPPORTED)
    list(APPEND CPU_ALL_AVAILABLE_OPTIMIZATIONS ${instruction_set})
    set(CPU_${instruction_set}_FLAGS ${CPU_${instruction_set}_FLAGS} CACHE INTERNAL "")
  endif()
endforeach()
