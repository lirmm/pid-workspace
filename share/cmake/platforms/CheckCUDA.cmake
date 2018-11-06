set(CUDA_Language_AVAILABLE FALSE CACHE INTERNAL "")

if(CMAKE_MAJOR_VERSION GREATER 3
OR (CMAKE_MAJOR_VERSION EQUAL 3 AND CMAKE_MINOR_VERSION GREATER 7))
  set(OLD_CUDA_SUPPORT FALSE)
else()
  set(OLD_CUDA_SUPPORT TRUE)
endif()

set(CUDA_USE_STATIC_CUDA_RUNTIME OFF CACHE INTERNAL "" FORCE)
set(CUDA_LIBRARIES CACHE INTERNAL "")
set(CUDA_INCLUDE_DIRS CACHE INTERNAL "")
find_package(CUDA)
if(CUDA_FOUND)#simply stop the configuration
  #setting general variables
  set(CUDA_Language_AVAILABLE TRUE CACHE INTERNAL "")
  #memorizing build variables
  set(CUDA_LIBRARIES ${CUDA_LIBRARIES} CACHE INTERNAL "")
  set(CUDA_INCLUDE_DIRS ${CUDA_INCLUDE_DIRS} CACHE INTERNAL "")
  if(OLD_CUDA_SUPPORT)
    set(CUDA_CMAKE_SUPPORT "OLD" CACHE INTERNAL "")
  else()
    set(CUDA_CMAKE_SUPPORT "NEW" CACHE INTERNAL "")
    set(CMAKE_CUDA_COMPILER ${CUDA_NVCC_EXECUTABLE} CACHE FILEPATH "")
    enable_language(CUDA) #enable CUDA language will generate appropriate variables
  endif()
  set(__cuda_arch_bin)
  set(__cuda_arch_ptx)

  #TODO improve this check now only based on CUDA version
  if(CUDA_VERSION VERSION_LESS "9.0")
    set(AVAILABLE_CUDA_ARCHS "2.0" "3.0" "3.5" "3.7" "5.0" "5.2" "6.0" "6.1" CACHE INTERNAL "")
  else()
    set(AVAILABLE_CUDA_ARCHS "3.0" "3.5" "3.7" "5.0" "5.2" "6.0" "6.1" "7.0" CACHE INTERNAL "")
  endif()

  #detecting current CUDA architecture
  execute_process( COMMAND "${CUDA_NVCC_EXECUTABLE}" ${CUDA_NVCC_FLAGS} "${WORKSPACE_DIR}/share/cmake/platforms/DetectCudaArch.cu" "--run"
                     WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                     RESULT_VARIABLE _nvcc_res OUTPUT_VARIABLE _nvcc_out
                     ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_nvcc_res EQUAL 0)#OK default arch has been found
    string(REPLACE "2.1" "2.1(2.0)" _nvcc_out "${_nvcc_out}")
    set(__cuda_arch_bin "${_nvcc_out}")
    set(DEFAULT_CUDA_ARCH ${__cuda_arch_bin} CACHE INTERNAL "")
  else()# choose the default arch among those available (take the greatest version)
    if(CUDA_VERSION VERSION_LESS "9.0")
      set(DEFAULT_CUDA_ARCH "6.1" CACHE INTERNAL "")
    else()
      set(DEFAULT_CUDA_ARCH "7.0" CACHE INTERNAL "")
    endif()
  endif()

endif()
