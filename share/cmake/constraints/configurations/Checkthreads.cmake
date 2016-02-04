
find_package(Threads)
set(threads_COMPILE_OPTIONS CACHE INTERNAL "")
set(threads_LINK_OPTIONS ${CMAKE_THREAD_LIBS_INIT} CACHE INTERNAL "")
set(threads_RPATH CACHE INTERNAL "")
if(Threads_FOUND)
	set(threads_LINK_OPTIONS ${CMAKE_THREAD_LIBS_INIT} CACHE INTERNAL "")
	set(CHECK_threads_RESULT TRUE)
else()
	set(CHECK_threads_RESULT FALSE)
endif()


