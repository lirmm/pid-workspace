
if(MPO700_ROBOT_WITH_TESTS)
#set(TEST_SRC_<test name> "")
## first subdirectory of test: a test unit ##
#list(APPEND TEST_SRC_<test name> <test name>/<path to file>)
#list(APPEND TEST_SRC_<test name> <test name>/<path to file>)
#add_executable(<test name> EXCLUDE_FROM_ALL TEST_SRC_<test name>)
#target_link_libraries(<test name> assist_driver_st)

## second subdirectory of test: a second unit ##

#add_custom_target(testunits 
#	COMMAND ${CMAKE_COMMAND} -E echo "Building test units" 
#	DEPENDS <test unit 1> <test unit 2>...)

enable_testing()
#add_test(<test1 name> <test unit 1> arg1 arg2 ... )
#add_test(<test2 name> <test unit 1> arg1 arg2 ... )
#add_test(<test3 name> <test unit 2> arg1 arg2 ... )

#INSTALL(TARGETS <test1 name> <test2 name>
#RUNTIME DESTINATION ${INSTALL_TESTS_PATH}/${INSTALL_PATH_SUFFIX}

endif(MPO700_ROBOT_WITH_TESTS)

