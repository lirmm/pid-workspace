set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Which compilers to use for C and C++
set(CMAKE_C_COMPILER ${CMAKE_SOURCE_DIR}/environments/host64_linux32/i686-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${CMAKE_SOURCE_DIR}/environments/host64_linux32/i686-linux-gnu-g++)

set(CMAKE_SYSTEM_LIBRARY_PATH /lib32 /usr/lib32)
