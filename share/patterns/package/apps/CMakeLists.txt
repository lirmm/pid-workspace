
if(<PROJECT_NAME>_WITH_EXAMPLES)
## pc side example executable ##
set(EXE_SRC_PC_SIDE_INTERFACE "")
list(APPEND EXE_SRC_PC_SIDE_INTERFACE pc_side_simple_interface/pc_side_simple_interface.c)

add_executable(pc_side_interface EXCLUDE_FROM_ALL ${EXE_SRC_PC_SIDE_INTERFACE})
target_link_libraries(pc_side_interface mpo700_interface_st ${EXTERNAL_LIBS})

## platform side example executable ##
set(EXE_SRC_PLATFORM_SIDE_INTERFACE "")
list(APPEND EXE_SRC_PLATFORM_SIDE_INTERFACE platform_side_simple_interface/platform_side_simple_interface.c)

add_executable(platform_side_interface EXCLUDE_FROM_ALL ${EXE_SRC_PLATFORM_SIDE_INTERFACE})
target_link_libraries(platform_side_interface mpo700_side_st ${EXTERNAL_LIBS})


## building and installing example targets, if any ##

INSTALL(TARGETS pc_side_interface platform_side_interface
	RUNTIME DESTINATION ${INSTALL_BIN_PATH}/${INSTALL_PATH_SUFFIX}
	LIBRARY DESTINATION ${INSTALL_LIB_PATH}/${INSTALL_PATH_SUFFIX}
	ARCHIVE DESTINATION ${INSTALL_AR_PATH}/${INSTALL_PATH_SUFFIX}
)

add_custom_target(examples COMMAND ${CMAKE_COMMAND} -E echo "Building examples targets" DEPENDS pc_side_interface platform_side_interface)

endif(<PROJECT_NAME>_WITH_EXAMPLES)



