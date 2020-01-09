

set(Fortran_Language_AVAILABLE FALSE CACHE INTERNAL "")

if(NOT PID_CROSSCOMPILATION)
  include(${CMAKE_ROOT}/Modules/CheckLanguage.cmake)
  check_language(Fortran)
endif()

if(CMAKE_Fortran_COMPILER) #ONLY ENABLE FORTRAN if a Fortran toolchain is available
  enable_language(Fortran) #enable FORTRAN language will generate appropriate variables
  set(Fortran_Language_AVAILABLE TRUE CACHE INTERNAL "")
else()
  message("[PID] WARNING : Fortran language is not supported because no Fortran compiler has been found.")
endif()
