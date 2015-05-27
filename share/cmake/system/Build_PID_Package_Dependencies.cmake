
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
if(DEPENDENT_PACKAGES)
	foreach(dep_pack IN ITEMS ${DEPENDENT_PACKAGES})
		execute_process (COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${dep_pack}/build ${BUILD_TOOL} build)
	endforeach()
else()
	message("[ERROR] : no package to build !")
endif()



