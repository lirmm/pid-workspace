
# the gcc compiler is user for building codes on host
set(PID_ENVIRONMENT_DESCRIPTION "The development environment is a 32 bit build based on the host default configuration (${CMAKE_CXX_COMPILER_ID})" CACHE INTERNAL "")

set(PID_CROSSCOMPILATION FALSE CACHE INTERNAL "") #do not crosscompile since it is the same environment (host)

#TODO check these commands (they do not seem to work all as expected)
execute_process(COMMAND sudo apt-get install gcc-multilib)
execute_process(COMMAND sudo apt-get install g++-multilib)
execute_process(COMMAND ln /usr/bin/ar ${CMAKE_SOURCE_DIR}/environments/host_linux32/i686-linux-gnu-ar)
execute_process(COMMAND chmod a+x ${CMAKE_SOURCE_DIR}/environments/host64_linux32/i686-linux-gnu-g++)
execute_process(COMMAND chmod a+x ${CMAKE_SOURCE_DIR}/environments/host64_linux32/i686-linux-gnu-gcc)

