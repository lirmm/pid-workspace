
include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)
_cmake_find_compiler_path(Fortran)
#ONLY ENABLE FORTRAN if a Fortran toolchain is available
set(Fortran_Language_AVAILABLE FALSE CACHE INTERNAL "")
if(CMAKE_Fortran_COMPILER) #the Fortran compiler has been found on the host
  enable_language(Fortran) #enable FORTRAN language will generate appropriate variables
  set(Fortran_Language_AVAILABLE TRUE CACHE INTERNAL "")
endif()
