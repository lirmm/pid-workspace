
function(get_All_Cpp_Sources_Absolute RESULT dir)
file(	GLOB_RECURSE
	RES
	${dir}
	"${dir}/*.c"
	"${dir}/*.C"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.c++"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.h++"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Cpp_Sources_Absolute)

function(format_source_directory dir)
    # get C/C++ files based on extension matching
    get_All_Cpp_Sources_Absolute(sources ${dir})

    foreach(file IN LISTS sources)
        # format the file inplace (-i) using the closest .clang-format file in the hierarchy (-style=file)
        execute_process(
            COMMAND ${CLANG_FORMAT_EXE} -style=file -i ${file}
            RESULT_VARIABLE res
            OUTPUT_VARIABLE out)
    endforeach()
endfunction(format_source_directory)

set(PACKAGE_DIR ${WORKSPACE_DIR}/packages/${PACKAGE_NAME})

format_source_directory(${PACKAGE_DIR}/apps)
format_source_directory(${PACKAGE_DIR}/include)
format_source_directory(${PACKAGE_DIR}/src)
format_source_directory(${PACKAGE_DIR}/test)
