#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_BINARIES_REGISTRY_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_BINARIES_REGISTRY_FUNCTIONS_INCLUDED TRUE)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)

##########################################################################################


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Available_Binary_Package_Versions| replace:: ``get_Available_Binary_Package_Versions``
#  .. _get_Available_Binary_Package_Versions:
#
#  get_Available_Binary_Package_Versions
#  --------------------------------------
#
#   .. command:: get_Available_Binary_Package_Versions(package LIST_OF_VERSIONS LIST_OF_VERSION_PLATFORM)
#
#    Get the list of versions of a given package that conforms to current platform constraints and for which a binary archive is available.
#
#      :package: The name of the package.
#
#      :LIST_OF_VERSIONS: the output variable that contains the list of versions of package that are available with a binary archive.
#      :LIST_OF_VERSION_PLATFORM: the output variable that contains the list of versions+platform of package that are available with a binary archive.
#
function(get_Available_Binary_Package_Versions package LIST_OF_VERSIONS LIST_OF_VERSION_PLATFORM)
# listing available binaries of the package and searching if there is any "good version"
set(available_binary_package_version)
foreach(ref_version IN LISTS ${package}_REFERENCES)
	foreach(ref_platform IN LISTS ${package}_REFERENCE_${ref_version})
		check_Package_Platform_Against_Current(BINARY_OK ${package} ${ref_platform} ${ref_version})#will return TRUE if the platform conforms to current one
    if(BINARY_OK)
			list(APPEND available_binary_package_version "${ref_version}")
			list(APPEND available_binary_package_version_with_platform "${ref_version}/${ref_platform}")
			# need to test for following platform because many instances may match
		endif()
	endforeach()
endforeach()
if(NOT available_binary_package_version)
	return()#nothing to do
endif()
list(REMOVE_DUPLICATES available_binary_package_version)
list(REMOVE_DUPLICATES available_binary_package_version_with_platform)
set(${LIST_OF_VERSIONS} ${available_binary_package_version} PARENT_SCOPE)
set(${LIST_OF_VERSION_PLATFORM} ${available_binary_package_version_with_platform} PARENT_SCOPE)
endfunction(get_Available_Binary_Package_Versions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Platform_Binary_For_Version| replace:: ``select_Platform_Binary_For_Version``
#  .. _select_Platform_Binary_For_Version:
#
#  select_Platform_Binary_For_Version
#  ----------------------------------
#
#   .. command:: select_Platform_Binary_For_Version(version list_of_bin_with_platform RES_FOR_PLATFORM)
#
#    Select the version passed as argument in the list of binary versions of a package and get corresponding platform.
#
#      :version: The selected version.
#      :list_of_bin_with_platform: list of available version+platform for a package (returned from get_Available_Binary_Package_Versions). All these archives are supposed to be binary compatible with current platform.
#
#      :RES_FOR_PLATFORM: the output variable that contains the platform to use.
#
function(select_Platform_Binary_For_Version version list_of_bin_with_platform RES_FOR_PLATFORM)
set(chosen_platform)
if(list_of_bin_with_platform)
  get_Platform_Variables(INSTANCE instance_name)# detect the instance name used for current platform
  foreach(bin IN LISTS list_of_bin_with_platform)
    if(bin MATCHES "^${version}/(.*)$") #only select for the given version
      set(bin_platform_name ${CMAKE_MATCH_1})
      extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI res_instance res_base_name ${bin_platform_name})
      if(instance_name AND res_instance STREQUAL instance_name)#the current platform is an instance so verify that binary archive is for this instance
        # This is the best choice we can do because there is a perfect match of platform instances
        set(${RES_FOR_PLATFORM} ${bin_platform_name} PARENT_SCOPE)
        return()
      else()
        if(NOT chosen_platform)
          set(chosen_platform ${bin_platform_name})#memorize the first in list, it will be selected by default
        elseif((NOT instance_name) AND (NOT res_instance))# if the current workspace has no instance specified, prefer a binary archive that is agnostic of instance, if any provided
          set(chosen_platform ${bin_platform_name})#memorize this archive because it is agnostic of platform instance
        endif()
      endif()
		endif()
	endforeach()
endif()
set(${RES_FOR_PLATFORM} ${chosen_platform} PARENT_SCOPE)
endfunction(select_Platform_Binary_For_Version)


#.rst:
#
# .. ifmode:: internal
#
#  .. |unload_Binary_Package_Install_Manifest| replace:: ``unload_Binary_Package_Install_Manifest``
#  .. _unload_Binary_Package_Install_Manifest:
#
#  unload_Binary_Package_Install_Manifest
#  --------------------------------------
#
#   .. command:: unload_Binary_Package_Install_Manifest(package version platform)
#
#    Unload info coming from an install manifest (use file) provided by a binary package.
#
#      :package: The name of the package.
#      :version: The version of the package.
#      :platform: platform for which the binary has been built for.
#
function(unload_Binary_Package_Install_Manifest package)
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "NATIVE")
    reset_Native_Package_Dependency_Cached_Variables_From_Use(${package} Release FALSE)
    reset_Native_Package_Dependency_Cached_Variables_From_Use(${package} Debug FALSE)
  elseif(PACK_TYPE STREQUAL "EXTERNAL")
    reset_External_Package_Dependency_Cached_Variables_From_Use(${package} Release FALSE)
    reset_External_Package_Dependency_Cached_Variables_From_Use(${package} Debug FALSE)
  endif()
endfunction(unload_Binary_Package_Install_Manifest)




#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Info_From_Install_Manifest| replace:: ``get_Info_From_Install_Manifest``
#  .. _get_Info_From_Install_Manifest:
#
#  get_Info_From_Install_Manifest
#  --------------------------------------
#
#   .. command:: get_Info_From_Install_Manifest(RES package path_to_manifest)
#
#   Extract information from a manifest file
#
#      :package: The name of the package.
#      :path_to_manifest: The path to the package manifest file
#      :RESULT: OUTPUT variable that is true if manifest is OK
#
function(get_Info_From_Install_Manifest RESULT package path_to_manifest)
    set(${RESULT} FALSE PARENT_SCOPE)
    if(NOT EXISTS ${path_to_manifest})
        return()
    endif()
    get_Package_Type(${package} PACK_TYPE)
    if(PACK_TYPE STREQUAL "NATIVE")
        set(line_pattern  "^(#.+|set\(.+\))")
    elseif(PACK_TYPE STREQUAL "EXTERNAL")
        set(line_pattern  "^(#.+|set\(.+\)|.+_PID_External_.+)")
    endif()
    file(STRINGS ${path_to_manifest} LINES)
    set(erroneous_file FALSE)
    foreach(line IN LISTS LINES)
        if(NOT line MATCHES "${line_pattern}")
            set(erroneous_file TRUE)
            break()
        endif()
    endforeach()
    if(NOT erroneous_file)
        if(PACK_TYPE STREQUAL "EXTERNAL")
            #need to set the the build type if not executed in the context of a package or wrapper
            if(NOT CMAKE_BUILD_TYPE)
                set(CMAKE_BUILD_TYPE Release)
                include(${path_to_manifest})
                set(CMAKE_BUILD_TYPE)#then reset
            else()
                include(${path_to_manifest})
            endif()
        else()
            include(${path_to_manifest})
        endif()
        set(${RESULT} TRUE PARENT_SCOPE)
    endif()
endfunction(get_Info_From_Install_Manifest)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Binary_Package_Install_Manifest| replace:: ``load_Binary_Package_Install_Manifest``
#  .. _load_Binary_Package_Install_Manifest:
#
#  load_Binary_Package_Install_Manifest
#  ------------------------------------
#
#   .. command:: load_Binary_Package_Install_Manifest(MANIFEST_FOUND package version platform)
#
#    Get the manifest file provided with a package binary reference.
#
#      :package: The name of the package.
#      :version: The version of the package.
#      :platform: platform for which the binary has been built for.
#
#      :MANIFEST_FOUND: the output variable that is TRUE is manifest file has been found, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The binaries referencing file must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(load_Binary_Package_Install_Manifest MANIFEST_FOUND package version platform)
set(${MANIFEST_FOUND} FALSE PARENT_SCOPE)
set(ws_download_folder ${WORKSPACE_DIR}/build/downloaded)
set(manifest_name Use${package}-${version}.cmake)
if(NOT EXISTS ${ws_download_folder})
  file(MAKE_DIRECTORY ${ws_download_folder})
endif()
if(EXISTS ${ws_download_folder}/${manifest_name})
  file(REMOVE ${ws_download_folder}/${manifest_name})
endif()
unload_Binary_Package_Install_Manifest(${package})
set(to_include)
if(${package}_FRAMEWORK) #references are deployed in a framework
	set(FRAMEWORK_ADDRESS ${${${package}_FRAMEWORK}_SITE})#get the address of the framework static site
  get_Package_Type(${package} PACK_TYPE)
  set(manifest_address)
  if(PACK_TYPE STREQUAL "NATIVE")
    set(manifest_address ${FRAMEWORK_ADDRESS}/packages/${package}/binaries/${version}/${platform}/${manifest_name})
  elseif(PACK_TYPE STREQUAL "EXTERNAL")
    set(manifest_address ${FRAMEWORK_ADDRESS}/external/${package}/binaries/${version}/${platform}/${manifest_name})
  endif()
  if(manifest_address)
    file(DOWNLOAD ${manifest_address} ${ws_download_folder}/${manifest_name} STATUS res TLS_VERIFY OFF)
		list(GET res 0 numeric_error)
		if(numeric_error EQUAL 0 #framework site is online & reference available.
		  AND EXISTS ${ws_download_folder}/${manifest_name})
      set(to_include ${ws_download_folder}/${manifest_name})
		else() #it may be an external package, try this
      if(ADDITIONAL_DEBUG_INFO)
        message("[PID] INFO: no manifest found for ${package} version ${version} for platform ${platform}. Binary is possibly incompatible.")
      endif()
    endif()
  else()
    if(ADDITIONAL_DEBUG_INFO)
      message("[PID] WARNING: cannot download install manifest for unknown package ${package}")
    endif()
  endif()
elseif(${package}_SITE_GIT_ADDRESS)  #references are deployed in a lone static site
	#when package has a lone static site, the reference file can be directly downloaded
	file(DOWNLOAD ${${package}_SITE_ROOT_PAGE}/binaries/${version}/${platform}/${manifest_name}
                ${ws_download_folder}/${manifest_name} STATUS res TLS_VERIFY OFF)
	list(GET res 0 numeric_error)
	if(numeric_error EQUAL 0 #static site online & reference available.
    AND EXISTS ${ws_download_folder}/${manifest_name})
		set(to_include ${ws_download_folder}/${manifest_name})
  else() #it may be an external package, try this
    if(ADDITIONAL_DEBUG_INFO)
      message("[PID] INFO: no manifest found for ${package} version ${version} for platform ${platform}. Binary is possibly incompatible.")
    endif()
	endif()
endif()
if(to_include)#there is a file to include but if static site is private it may have returned an invalid file (HTML connection ERROR response)
    get_Info_From_Install_Manifest(RES ${package} ${to_include})
    set(${MANIFEST_FOUND} ${RES} PARENT_SCOPE)
endif()
endfunction(load_Binary_Package_Install_Manifest)



#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Package_Binary_References| replace:: ``load_Package_Binary_References``
#  .. _load_Package_Binary_References:
#
#  load_Package_Binary_References
#  ------------------------------
#
#   .. command:: load_Package_Binary_References(REFERENCES_FOUND package)
#
#    Get the references to binary archives containing versions of a given package.
#
#      :package: The name of the package.
#
#      :REFERENCES_FOUND: the output variable that is TRUE is package binary references has been found, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(load_Package_Binary_References REFERENCES_FOUND package)
set(${REFERENCES_FOUND} FALSE PARENT_SCOPE)
set(to_include)
set(workspace_download_folder ${WORKSPACE_DIR}/build/downloaded)
if(${package}_FRAMEWORK) #references are deployed in a framework
  include_Framework_Reference_File(PATH_TO_REF ${${package}_FRAMEWORK})
	if(PATH_TO_REF)
		#when package is in a framework there is one more indirection to get references (we need to get information about this framework before downloading the reference file)
		set(FRAMEWORK_ADDRESS ${${${package}_FRAMEWORK}_SITE})#get the address of the framework static site
        get_Package_Type(${package} PACK_TYPE)
        set(binaries_address)
        if(PACK_TYPE STREQUAL "NATIVE")
            set(binaries_address ${FRAMEWORK_ADDRESS}/packages/${package}/binaries/binary_references.cmake)
        elseif(PACK_TYPE STREQUAL "EXTERNAL")
            set(binaries_address ${FRAMEWORK_ADDRESS}/external/${package}/binaries/binary_references.cmake)
        endif()
        if(binaries_address)
            if(NOT EXISTS ${workspace_download_folder})
                file(MAKE_DIRECTORY ${workspace_download_folder})
            endif()
            file(DOWNLOAD ${binaries_address} ${workspace_download_folder}/${package}_binary_references.cmake STATUS res TLS_VERIFY OFF)
            list(GET res 0 numeric_error)
            if(numeric_error EQUAL 0 #framework site is online & reference available.
                AND EXISTS ${WORKSPACE_DIR}/build/${package}_binary_references.cmake)
                set(to_include ${WORKSPACE_DIR}/build/${package}_binary_references.cmake)
            else() #it may be an external package, try this
                if(ADDITIONAL_DEBUG_INFO)
                    message("[PID] INFO: no binary reference found for ${package}")
                endif()
            endif()
        else()
            if(ADDITIONAL_DEBUG_INFO)
                message("[PID] WARNING: cannot load binary references for unknown package ${package}")
            endif()
        endif()
    else()
        if(ADDITIONAL_DEBUG_INFO)
            message("[PID] WARNING: no reference for framework ${${package}_FRAMEWORK}")
        endif()
    endif()
elseif(${package}_SITE_GIT_ADDRESS)  #references are deployed in a lone static site
	#when package has a lone static site, the reference file can be directly downloaded
	file(DOWNLOAD ${${package}_SITE_ROOT_PAGE}/binaries/binary_references.cmake ${workspace_download_folder}/${package}_binary_references.cmake STATUS res TLS_VERIFY OFF)
	list(GET res 0 numeric_error)
	if(numeric_error EQUAL 0 #static site online & reference available.
        AND EXISTS $${workspace_download_folder}/${package}_binary_references.cmake)
            set(to_include ${workspace_download_folder}/${package}_binary_references.cmake)
    else() #it may be an external package, try this
        if(ADDITIONAL_DEBUG_INFO)
            message("[PID] INFO: no binary reference found for ${package}")
        endif()
	endif()
endif()

if(to_include)#there is a file to include but if static site is private it may have returned an invalid file (HTML connection ERROR response)
  file(STRINGS ${to_include} LINES)
  set(erroneous_file FALSE)
  foreach(line IN LISTS LINES)
    if(NOT line MATCHES "^(#.+|set\(.+\))")
      set(erroneous_file TRUE)
      break()
    endif()
  endforeach()
  if(NOT erroneous_file)
    include(${to_include})
  endif()
endif()
if(${package}_REFERENCES) #if there are direct reference (simpler case), no need to do more becase binary references are already included
	set(${REFERENCES_FOUND} TRUE PARENT_SCOPE)
endif()
endfunction(load_Package_Binary_References)


#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Binary_References_File| replace:: ``generate_Binary_References_File``
#  .. _generate_Binary_References_File:
#
#  generate_Binary_References_File
#  -----------------------------------
#
#   .. command:: generate_Binary_References_File(package ref_file)
#
#    Generate the CMake file referencing all binaries available for a given package
#
#      :package: The name of the package.
#      :ref_file: path to file to write to
#
#
function(generate_Binary_References_File package ref_file)
file(WRITE ${ref_file} "# Contains references to binaries that are available for ${package} \n")
file(APPEND ${ref_file} "set(${package}_REFERENCES ${${package}_FOUND_REFERENCES} CACHE INTERNAL \"\")\n") # all versions are registered

foreach(version IN LISTS ${package}_FOUND_REFERENCES)
  file(APPEND ${ref_file} "set(${package}_REFERENCE_${version} ${${package}_FOUND_REFERENCES_${version}} CACHE INTERNAL \"\")\n")
  foreach(platform IN LISTS ${package}_FOUND_REFERENCES_${version})#for each platform of this version
			#release binary referencing
			file(APPEND ${ref_file} "set(${package}_REFERENCE_${version}_${platform}_URL_MANIFEST ${${package}_FOUND_REFERENCES_${version}_${platform}_URL_MANIFEST} CACHE INTERNAL \"\")\n")#reference on the release binary
			file(APPEND ${ref_file} "set(${package}_REFERENCE_${version}_${platform}_URL_RELEASE ${${package}_FOUND_REFERENCES_${version}_${platform}_URL_RELEASE} CACHE INTERNAL \"\")\n")#reference on the release binary
			#debug binary referencing
			if(${package}_FOUND_REFERENCES_${version}_${platform}_URL_DEBUG) #always true for open source native packages, may be true for external packages, never true for close source native packages
				file(APPEND ${ref_file} "set(${package}_REFERENCE_${version}_${platform}_URL_DEBUG ${${package}_FOUND_REFERENCES_${version}_${platform}_URL_DEBUG} CACHE INTERNAL \"\")\n")#reference on the debug binary
			endif()
  endforeach()
endforeach()
endfunction(generate_Binary_References_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |upload_File| replace:: ``upload_File``
#  .. _upload_File:
#
#  upload_File
#  -------------------------------
#
#   .. command:: upload_File(ERROR file url)
#
#    Upload a file to a registry URL.
#
#      :file: The path to the file to upload.
#      :url: URL where the file is uploaded.
#
#      :ERROR: output variable that is empty if file has been uploaded, or contains the error mssage otherwise.
#
function(upload_File ERROR file url)
    if(NOT DEFINED ENV{PID_USER_TOKEN})
      set(${ERROR} "Cannot upload file to registry because no access token given. Please set the PID_USER_TOKEN environment variable with a valid token." PARENT_SCOPE)
      return()
    endif()
    set(${ERROR} PARENT_SCOPE)
    file(UPLOAD ${file} ${url}
        HTTPHEADER "PRIVATE-TOKEN: $ENV{PID_USER_TOKEN}" 
        STATUS result
    )
    list(GET result 0 RES)
    if(NOT RES EQUAL 0)#error, try again
        file(UPLOAD ${file} ${url}
            HTTPHEADER "PRIVATE-TOKEN: $ENV{PID_USER_TOKEN}" 
            STATUS result
        )
        list(GET result 0 RES)
        if(NOT RES EQUAL 0)#error -> abort
            list(GET output 1 RES)
            set(${ERROR} ${RES} PARENT_SCOPE)
        endif()
    endif()
endfunction(upload_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Package_File_ID_From_JSON| replace:: ``extract_Package_File_ID_From_JSON``
#  .. extract_Package_File_ID_From_JSON:
#
#  _extract_Package_File_ID_From_JSON
#  -----------------------------------
#
#   .. command:: extract_Package_File_ID_From_JSON(ERROR FOUND_FILE FOUND_ID input index)
#
#    extract file name and id for a specific package file
#
#      :input: variable containing the JSON description of files contained in a package.
#      :index: index of the file to extract.
#
#      :ERROR: output variable that is empty if file has been uploaded, or contains the error message otherwise.
#      :FOUND_FILE: output variable that is empty if error occurred, or contains the file name otherwise.
#      :FOUND_ID: output variable that is empty if error occurred, or contains the file ID in registry otherwise.
#
function(extract_Package_File_ID_From_JSON ERROR FOUND_FILE FOUND_ID input index)
  set(${FOUND_FILE} PARENT_SCOPE)
  set(${FOUND_ID} PARENT_SCOPE)
  set(${ERROR} PARENT_SCOPE)

  string(JSON file_info ERROR_VARIABLE err_info
       GET "${${input}}" "${index}")
  if(NOT err_info STREQUAL NOTFOUND
    OR file_info STREQUAL NOTFOUND)
    set(${ERROR} TRUE PARENT_SCOPE)
    #no file description at index
    return()
  endif()

  # pack_info info contains a json string looking like:
  #{"id":470,"package_id":264,"created_at":"2023-03-11T17:16:14.323Z","file_name":"toto.txt","size":98,"file_md5":null,"file_sha1":null,"file_sha256":"cffba0e8adeaa849ce3910029c84fe04ffc7c89ee586aca032b3d38144cf9e5f"}
 
  string(JSON id_info ERROR_VARIABLE err_info
       GET "${file_info}" "id")
  if(NOT err_info STREQUAL NOTFOUND
    OR id_info STREQUAL NOTFOUND)
    # problem retrieving the ID -> invalid
    set(${ERROR} TRUE PARENT_SCOPE)
    return()
  endif()
  string(JSON name_info ERROR_VARIABLE err_info
       GET "${file_info}" "file_name")
  if(NOT err_info STREQUAL NOTFOUND
    OR name_info STREQUAL NOTFOUND)
    # problem retrieving the ID -> invalid
    set(${ERROR} TRUE PARENT_SCOPE)
    return()
  endif()

  set(${FOUND_FILE} ${name_info} PARENT_SCOPE)
  set(${FOUND_ID} ${id_info} PARENT_SCOPE)
endfunction(extract_Package_File_ID_From_JSON)



#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Recorded_Package_Files| replace:: ``reset_Recorded_Package_Files``
#  .. _reset_Recorded_Package_Files:
#
#  reset_Recorded_Package_Files
#  -------------------------------
#
#   .. command:: reset_Recorded_Package_Files(package_id)
#
#    Upload a file to a registry URL.
#
#      :package_id: id of the pakage whose recrded files must be reset.
#
function(reset_Recorded_Package_Files package_id)
foreach(file IN LISTS ${package_id}_FILES)
  unset(${package_id}_FILE_${file} CACHE)
endforeach()
unset(${package_id}_FILES CACHE)
endfunction(reset_Recorded_Package_Files)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Package_Files_List| replace:: ``update_Package_Files_List``
#  .. _update_Package_Files_List:
#
#  update_Package_Files_List
#  -------------------------------
#
#   .. command:: update_Package_Files_List(registry package_id release_archive_name debug_archive_name manifest_name lockfile_name)
#
#    Get the list of package files for a given package in registry and record registry IDs of those files. 
#
#      :registry: URL of teh registry where the package is uploaded.
#      :package_id: id of the package in th registry 
#      :release_archive_name: name of release archive
#      :debug_archive_name: name of debug archive
#      :manifest_name: name of manifest file
#      :lockfile_name: name of lock file
#
function(update_Package_Files_List registry package_id release_archive_name debug_archive_name manifest_name lockfile_name)
  if(NOT DEFINED ENV{PID_USER_TOKEN})
    message("[PID] ERROR: cannot access registry ${registry} because current user has no access token for it. Set the PID_USER_TOKEN environment variable with a valid token usable to access registry. Aborting.")
    return()
  endif()
  reset_Recorded_Package_Files(${package_id})
  execute_process(COMMAND curl
    --request GET "${registry}/packages/${package_id}/package_files"
    OUTPUT_VARIABLE json_list
    ERROR_VARIABLE json_err
  )
  #from here we should have a string like:
  # [{"id":470,"package_id":264,"created_at":"2023-03-11T17:16:14.323Z","file_name":"toto.txt","size":98,"file_md5":null,"file_sha1":null,"file_sha256":"cffba0e8adeaa849ce3910029c84fe04ffc7c89ee586aca032b3d38144cf9e5f"},{"id":486,"package_id":264,"created_at":"2023-03-12T15:56:06.060Z","file_name":"tutu.txt","size":4,"file_md5":null,"file_sha1":null,"file_sha256":"e4ef1f462d4335e2785dfae6f9f59f3135d7c4e15bc4213595a39e7ec1ae5cb0"}]
  #this is an array with files description
  set(index 0)
  set(more_to_extract TRUE)
  while(more_to_extract)
    extract_Package_File_ID_From_JSON(NEXT_ERROR found_file found_id json_list "${index}")
    if(found_file STREQUAL release_archive_name
     OR found_file STREQUAL debug_archive_name
     OR found_file STREQUAL manifest_name
     OR found_file STREQUAL lockfile_name)
      set(${package_id}_FILE_${found_file} ${found_id} CACHE INTERNAL "")
      append_Unique_In_Cache(${package_id}_FILES ${found_file})
    endif()
    if(NEXT_ERROR)
      set(more_to_extract FALSE)
    endif()
    math(EXPR index "${index}+1")
  endwhile()

endfunction(update_Package_Files_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_Remote_File| replace:: ``remove_Remote_File``
#  .. _remove_Remote_File:
#
#  remove_Remote_File
#  -------------------------------
#
#   .. command:: remove_Remote_File(registry package_id file_name)
#
#    Remove a file located at a given URL. Can be called only after update_Package_Files_List has been called.
#
#      :registry: URL of teh registry where the package is uploaded.
#      :package_id: id of the package in th registry 
#      :file_name: file to delete from registry
#
function(remove_Remote_File registry package_id file_name)
  if(NOT ${package_id}_FILE_${file_name})
    #file is unknown
    return()
  endif()
  execute_process(COMMAND curl 
    --header "PRIVATE-TOKEN: $ENV{PID_USER_TOKEN}" 
    --request DELETE ${registry}/packages/${package_id}/package_files/${${package_id}_FILE_${file_name}}
    OUTPUT_QUIET ERROR_QUIET
  )
endfunction(remove_Remote_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_Remote_Package| replace:: ``remove_Remote_Package``
#  .. _remove_Remote_Package:
#
#  remove_Remote_Package
#  -------------------------------
#
#   .. command:: remove_Remote_Package(registry id)
#
#    Remove a file located at a given URL.
#
#      :registry: URL of teh registry where the package is uploaded.
#      :id: id of the package 
#
function(remove_Remote_Package registry id)
  execute_process(COMMAND curl 
    --header "PRIVATE-TOKEN: $ENV{PID_USER_TOKEN}" 
    --request DELETE ${registry}/packages/${id}
    OUTPUT_QUIET ERROR_QUIET
  )
endfunction(remove_Remote_Package)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Remote_File| replace:: ``check_Remote_File``
#  .. check_Remote_File:
#
#  check_Remote_File
#  -------------------------------
#
#   .. command:: check_Remote_File(EXISTS url)
#
#    Check if a file xists a URL.
#
#      :url: URL where the file is uploaded.
#
#      :EXISTS: output variable that is TRUE if file exists, FALSE otherwise.
#
function(check_Remote_File EXISTS url)
  execute_process(COMMAND curl 
    --silent --head --fail ${url}
    RESULT_VARIABLE res
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if(res EQUAL 0)
    set(${EXISTS} TRUE PARENT_SCOPE)
  else()
    set(${EXISTS} FALSE PARENT_SCOPE)
  endif()
endfunction(check_Remote_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Package_ID_Version_From_JSON| replace:: ``extract_Package_ID_Version_From_JSON``
#  .. _extract_Package_ID_Version_From_JSON:
#
#  extract_Package_ID_Version_From_JSON
#  -------------------------------------
#
#   .. command:: extract_Package_ID_Version_From_JSON(ERROR input index)
#
#    From an array of package versions extract the version info at given index 
#
#      :input: variable containing the string
#      :index: Index of the package in the array
#
#      :ERROR: output variable that is TRUE if an error occurred
#
function(extract_Package_ID_Version_From_JSON ERROR input index)
  set(${ERROR} PARENT_SCOPE)
  string(JSON pack_info ERROR_VARIABLE err_info
       GET "${${input}}" "${index}")
  if(NOT err_info STREQUAL NOTFOUND
    OR pack_info STREQUAL NOTFOUND)
    set(${ERROR} TRUE PARENT_SCOPE)
    #no component description at index
    return()
  endif()
  # pack_info info contains a json string looking like:
  # {
  # "_links" : 
  # {
    # "web_path" : "/passama/test_package_registry/-/packages/260"
  # },
  # "created_at" : "2023-03-10T16:17:43.253Z",
  # "id" : 260,
  # "last_downloaded_at" : null,
  # "name" : "my_test_package",
  # "package_type" : "generic",
  # "status" : "default",
  # "tags" : [],
  # "version" : "0.0.1-ghtuhguthg"
  # }
  string(JSON id_info ERROR_VARIABLE err_info
       GET "${pack_info}" "id")
  if(NOT err_info STREQUAL NOTFOUND
    OR id_info STREQUAL NOTFOUND)
    # problem retrieving the ID -> invalid
    set(${ERROR} TRUE PARENT_SCOPE)
    return()
  endif()

  list(FIND ALL_IDS_FOUND ${id_info} INDEX)
  if(NOT INDEX EQUAL -1)#already registered
    return()#OK redundant information
  endif()

  string(JSON version_info ERROR_VARIABLE err_info
       GET "${pack_info}" "version")
  if(NOT err_info STREQUAL NOTFOUND
    OR version_info STREQUAL NOTFOUND)
    # problem retrieving the ID -> invalid
    set(${ERROR} TRUE PARENT_SCOPE)
    return()
  endif()
  #from here we have version and ID info... this is enough
  if(version_info MATCHES "^([0-9]+\.[0-9]+\.[0-9]+)-(.+)$")
    set(tmp_vers ${CMAKE_MATCH_1})
    set(tmp_plat ${CMAKE_MATCH_2})
    if(tmp_plat MATCHES "^[^_]+_[^_]+_[^_]+(_[^_]+)?(__.+__)?$")
      #second is a platform string
      set(ALL_IDS_FOUND ${ALL_IDS_FOUND} ${id_info} CACHE INTERNAL "")
      set(${id_info}_VERSION ${tmp_vers} CACHE INTERNAL "")
      set(${id_info}_PLATFORM ${tmp_plat} CACHE INTERNAL "")
    endif()
  else() #error : bad package description
    set(${ERROR} TRUE PARENT_SCOPE)
    return()
  endif()
endfunction(extract_Package_ID_Version_From_JSON)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Package_All_Versions_From_JSON| replace:: ``extract_Package_All_Versions_From_JSON``
#  .. _extract_Package_All_Versions_From_JSON:
#
#  extract_Package_All_Versions_From_JSON
#  ---------------------------------------
#
#   .. command:: extract_Package_All_Versions_From_JSON(ERROR input)
#
#    From an array of package versions extract the version info of each version and store them in cache 
#
#      :input: variable containing the string
#
#      :ERROR: output variable that is TRUE if an error occurred
#
function(extract_Package_All_Versions_From_JSON ERROR input)
  set(${ERROR} PARENT_SCOPE)
  string(JSON all_pack_versions ERROR_VARIABLE err_info
        GET "${${input}}" "versions")
    
  if(NOT err_info STREQUAL NOTFOUND
    OR all_pack_versions STREQUAL NOTFOUND)
    # problem retrieving the ID -> invalid
    set(${ERROR} TRUE PARENT_SCOPE)
    return()
  endif()

  # from here I get an array of version  like:
  # [
  #   {
  #     "created_at" : "2023-03-10T16:47:37.867Z",
  #     "id" : 261,
  #     "tags" : [],
  #     "version" : "0.0.2-ghtuhguthg"
  #   }
  # ] 
  set(index 0)
  set(more_to_extract TRUE)
  while(more_to_extract)
    extract_Package_ID_Version_From_JSON (NEXT_ERROR all_pack_versions "${index}")
    if(NEXT_ERROR)
      set(more_to_extract FALSE)
    endif()
    math(EXPR index "${index}+1")
  endwhile()
endfunction(extract_Package_All_Versions_From_JSON)


#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Found_References_And_Registry| replace:: ``update_Found_References_And_Registry``
#  .. _update_Found_References_And_Registry:
#
#  update_Found_References_And_Registry
#  -------------------------------------
#
#   .. command:: update_Found_References_And_Registry(package registry)
#
#    Update the binary references found for a given package and remove corrupted packages from registry
#
#      :package: The name of the package.
#      :registry: URL of th registry
#
#
function(update_Found_References_And_Registry package registry)
  set(workspace_download_folder ${WORKSPACE_DIR}/build/downloaded)
  foreach(id IN LISTS ALL_IDS_FOUND)
    set(id_version ${${id}_VERSION})
    set(id_platform ${${id}_PLATFORM})
    extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE ${id_platform})
    
    set(lock_file_name "lock.txt")
    set(manifest_file_name Use${package}-${id_version}.cmake)
    set(release_archive_name ${package}-${id_version}-${RES_PLATFORM_BASE}.tar.gz)
    set(debug_archive_name ${package}-${id_version}-dbg-${RES_PLATFORM_BASE}.tar.gz)
    set(base_url ${registry}/packages/generic/${package}/${id_version}-${id_platform})

    set(lock_url ${base_url}/${lock_file_name})
    set(manifest_url ${base_url}/${manifest_file_name})
    set(release_arcihve_url ${base_url}/${release_archive_name})
    set(debug_arcihve_url ${base_url}/${debug_archive_name})
  
    file(WRITE ${CMAKE_BINARY_DIR}/${lock_file_name} "reading\n")#create the lock file
    # check if manifest file exists
    check_Remote_File(LOCKED ${lock_url})
    if(NOT LOCKED)
      upload_File(ERROR_REASON ${CMAKE_BINARY_DIR}/${lock_file_name} ${lock_url})
      update_Package_Files_List(${registry} ${id} ${release_archive_name} ${debug_archive_name} ${manifest_file_name} ${lock_file_name})
      check_Remote_File(MANIFEST_EXISTS ${manifest_url})
      check_Remote_File(RELEASE_EXISTS ${release_arcihve_url})
      if(NOT MANIFEST_EXISTS OR NOT RELEASE_EXISTS)
        if(NOT MANIFEST_EXISTS)
          message("[PID] WARNING: package ${package} has a corrupted binary archive for version ${id_version} and target platform ${id_platform} (no install manifest). Package is supressed.")
        elseif(NOT RELEASE_EXISTS)
          message("[PID] WARNING: package ${package} has a corrupted binary archive for version ${id_version} and target platform ${id_platform} (no release archive). Package is supressed.")
        endif()
        remove_Remote_Package(${registry} ${id})
        continue()
      endif()
      set(target_manifest_file ${workspace_download_folder}/${manifest_file_name})
      file(DOWNLOAD ${manifest_url} ${target_manifest_file} STATUS res TLS_VERIFY OFF)
      if(NOT res EQUAL 0)
        message("[PID] WARNING: package ${package} has a corrupted binary archive for version ${id_version} and target platform ${id_platform} (cannot download install manifest). Package is supressed.")
        remove_Remote_Package(${registry} ${id})
        continue()
      endif()
      get_Info_From_Install_Manifest(RES_MANIFEST_OK ${package} ${target_manifest_file})
      if(NOT RES_MANIFEST_OK)
        unload_Binary_Package_Install_Manifest(${package})
        message("[PID] WARNING: package ${package} has a corrupted binary archive for version ${id_version} and target platform ${id_platform} (corrupted install manifest). Package is supressed.")
        remove_Remote_Package(${registry} ${id})
        continue()
      endif()
      if(NOT ${package}_BUILT_RELEASE_ONLY)
        get_Package_Type(${package} PACK_TYPE)
        if(PACK_TYPE STREQUAL "NATIVE")
          check_Remote_File(DEBUG_EXISTS ${debug_arcihve_url})
          if(NOT DEBUG_EXISTS)
            unload_Binary_Package_Install_Manifest(${package})
            message("[PID] WARNING: package ${package} has a corrupted binary archive for version ${id_version} and target platform ${id_platform} (no debug artifact provided). Package is supressed.")
            remove_Remote_Package(${registry} ${id})
            continue()
          endif()
        endif()
      endif()
      unload_Binary_Package_Install_Manifest(${package})
      remove_Remote_File(${registry} ${id} ${lock_file_name})   
    # else the lock file is currently held by a publication process
    # skip verification
    endif()
    #now updating variables since evrything is OK
    append_Unique_In_Cache(${package}_FOUND_REFERENCES ${id_version})
    append_Unique_In_Cache(${package}_FOUND_REFERENCES_${id_version} ${id_platform})
    set(prefix ${package}_FOUND_REFERENCES_${id_version}_${id_platform})
    append_Unique_In_Cache(${prefix}_REGISTRY_ID ${id})
    append_Unique_In_Cache(${prefix}_URL_MANIFEST ${manifest_url})
    append_Unique_In_Cache(${prefix}_URL_RELEASE ${release_arcihve_url})
    append_Unique_In_Cache(${prefix}_URL_DEBUG ${debug_arcihve_url})
  endforeach()
endfunction(update_Found_References_And_Registry)


#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Found_References| replace:: ``reset_Found_References``
#  .. _reset_Found_References:
#
#  reset_Found_References
#  -----------------------------------
#
#   .. command:: reset_Found_References(registry package)
#
#    Reset cache variables containing package registry references
#
#      :package: The name of the package.
#
function(reset_Found_References package)
foreach(version IN LISTS ${package}_FOUND_REFERENCES)
  foreach(platform IN LISTS ${package}_FOUND_REFERENCES_${version})
    set(prefix ${package}_FOUND_REFERENCES_${version}_${platform})
      unset(${prefix}_REGISTRY_ID CACHE)
      unset(${prefix}_URL_MANIFEST CACHE)
      unset(${prefix}_URL_RELEASE CACHE)
      unset(${prefix}_URL_DEBUG CACHE)
  endforeach()
  unset(${package}_FOUND_REFERENCES_${version} CACHE)
endforeach()
unset(${package}_FOUND_REFERENCES CACHE)
endfunction(reset_Found_References)


#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Registry_Info| replace:: ``update_Registry_Info``
#  .. _update_Registry_Info:
#
#  update_Registry_Info
#  -----------------------------------
#
#   .. command:: update_Registry_Info(registry package)
#
#    Get info about a package from the registry
#
#      :registry: URL of th registry
#      :package: The name of the package.
#
#
function(update_Registry_Info registry package)
  reset_Found_Package_IDs()
  
  #use gitlab API to get all posible versions about the package
  # 1) get all IDs of all versions of a package 
  execute_process(COMMAND curl
    --request GET "${registry}/packages?package_name=${package}&per_page=1&package_type=generic"
    OUTPUT_VARIABLE json_list
    ERROR_VARIABLE json_err
  )
  #get the first element of the array -> only element
  extract_Package_ID_Version_From_JSON(ERROR json_list "0")
  if(ERROR)# No such package found
    return()
  endif()
  
  set(reference_id ${ALL_IDS_FOUND})#only one package ID by construction
  # we want to get all versions of this package
  execute_process(COMMAND curl
    --request GET "${registry}/packages/${reference_id}"
    OUTPUT_VARIABLE json_list
    ERROR_VARIABLE json_err
  )
  extract_Package_All_Versions_From_JSON(ERROR json_list)
  if(ERROR)
    reset_Found_Package_IDs()
  endif()
endfunction(update_Registry_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Binary_References| replace:: ``update_Binary_References``
#  .. _update_Binary_References:
#
#  update_Binary_References
#  -----------------------------------
#
#   .. command:: update_Binary_References(package native framework registry)
#
#    Update the reference to binaries for a given package. Generates the cmake script that reflects current state of the package registry and put it into the framework repositor
#
#      :package: The name of the package.
#      :native: if true the package is nativbe, external otherwise
#      :framework: name of the framework the package belongs to, or empty if it belongs to no framework.
#      :registry: address of the package registry 
#
#
function(update_Binary_References package native framework registry)

#### preparing the copy depending on the target: lone static site or framework, native or external ####
if(framework)
  set(TARGET_FRAMEWORK_SOURCES ${WORKSPACE_DIR}/sites/frameworks/${framework}/src)
  if(native)
    set(TARGET_PACKAGE_PATH ${TARGET_FRAMEWORK_SOURCES}/_packages/${package})
  else() # external packages have different deployment
    set(TARGET_PACKAGE_PATH ${TARGET_FRAMEWORK_SOURCES}/_external/${package})
  endif()
  set(TARGET_BINARIES_PATH ${TARGET_PACKAGE_PATH}/binaries)
else()#it is a lone static site (no need to adapt the path as they work the same for external wrappers and native packages)
  set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/packages/${package}/src)
  set(TARGET_BINARIES_PATH ${TARGET_PACKAGE_PATH}/_binaries)
endif()
set(ref_file ${TARGET_BINARIES_PATH}/binary_references.cmake)

# 1) get all references online for the given package 
reset_Found_References(${package})

# they are put in lists to easily retrieve their important info  
update_Registry_Info(${registry} ${package})

# 2) generate the cache variables used to generate binary references files
# only valid packages are referenced, other are deleted  
update_Found_References_And_Registry(${package} ${registry})

# 3) generate the binary reference file from these variables 
generate_Binary_References_File(${package} ${ref_file})

# 4) modify jekyll files/folders of the static site to reflect the binary references available
verify_Site_Structure_For_Binaries_Referencing(${package} ${TARGET_BINARIES_PATH})

endfunction(update_Binary_References)




#.rst:
#
# .. ifmode:: internal
#
#  .. |verify_Site_Structure_For_Binaries_Referencing| replace:: ``verify_Site_Structure_For_Binaries_Referencing``
#  .. verify_Site_Structure_For_Binaries_Referencing:
#  _verify_Site_Structure_For_Binaries_Referencing
#  -----------------------------------------------
#
#   .. command:: verify_Site_Structure_For_Binaries_Referencing( folder)
#
#    Verify that the target binaries folder of the web site project (framework or lone static site) is correct according to existing binary references 
#
#      :package: package that is checked.
#      :folder: Folder where binaries are contained.
#
function(verify_Site_Structure_For_Binaries_Referencing package folder)
list_Version_Subdirectories(ALL_VERSIONS ${folder})

foreach(ref_version IN LISTS ALL_VERSIONS) #for each available version, all os for which there is a reference
  if(NOT ${package}_FOUND_REFERENCES_${ref_version})
    # the version as no known binaries -> delete it
    file(REMOVE_RECURSE ${folder}/${ref_version})
    continue()
  endif()
  list_Platform_Subdirectories(ALL_PLATFORMS ${folder}/${ref_version})
	foreach(ref_platform IN LISTS ALL_PLATFORMS)#for each platform of this version
		# now referencing the binaries
    set(target_binaries_dir ${folder}/${ref_version}/${ref_platform})
    if(NOT ${package}_FOUND_REFERENCES_${ref_version}_${ref_platform}_REGISTRY_ID)
      file(REMOVE_RECURSE ${target_binaries_dir})
      continue()
    endif()
		set(target_manifest_file ${target_binaries_dir}/Use${package}-${ref_version}.cmake)
    if(NOT EXISTS ${target_manifest_file}) # check to avoid problem is the binaries have been badly released
      file(REMOVE_RECURSE ${folder}/${ref_version}/${ref_platform})
      continue()
    endif()
	endforeach()
endforeach()
endfunction(verify_Site_Structure_For_Binaries_Referencing)


#
# .. ifmode:: internal
#
#  .. |reset_Found_Package_IDs| replace:: ``reset_Found_Package_IDs``
#  .. reset_Found_Package_IDs:
#
#  reset_Found_Package_IDs
#  -------------------------------
#
#   .. command:: reset_Found_Package_IDs()
#
#    Reset cache variables containing currently found package IDs related information
#
function(reset_Found_Package_IDs)
foreach(id IN LISTS ALL_IDS_FOUND)
  unset(${id}_VERSION CACHE)
  unset(${id}_PLATFORM CACHE)
endforeach()
unset(ALL_IDS_FOUND CACHE)
endfunction(reset_Found_Package_IDs)

#.rst:
#
# .. ifmode:: internal
#
#  .. |upload_Binary_Version| replace:: ``upload_Binary_Version``
#  .. _upload_Binary_Version:
#
#  upload_Binary_Version
#  -------------------------------
#
#   .. command:: upload_Binary_Version(UPLOADED package version native registry)
#
#    Upload a package version binary to a registry.
#
#      :package: The name of the package.
#      :version: version of the package.
#      :native: TRUE if package i native, FALSE otherwise.
#      :registry: URL of the registry.
#
#      :UPLOADED: output variable that is TRUE if package has been uploaded, FALSE otherwise.
#
function(upload_Binary_Version UPLOADED package version native registry)
    set(${UPLOADED} FALSE PARENT_SCOPE)
    get_Platform_Variables(BASENAME current_platform_name)

    if(native)
        set(PATH_TO_PACKAGE_BUILD ${WORKSPACE_DIR}/packages/${package}/build)
        set(manifest_folder_path ${PATH_TO_PACKAGE_BUILD}/release/share)
        set(target_release_folder_path ${PATH_TO_PACKAGE_BUILD}/release)
        set(target_debug_folder_path ${PATH_TO_PACKAGE_BUILD}/debug)
    else()
        set(PATH_TO_PACKAGE_BUILD ${WORKSPACE_DIR}/wrappers/${package}/build)
        set(manifest_folder_path ${PATH_TO_PACKAGE_BUILD})
        set(target_release_folder_path ${PATH_TO_PACKAGE_BUILD}/${version}/installer)
        set(target_debug_folder_path ${PATH_TO_PACKAGE_BUILD}/${version}/installer)
    endif()
    
    set(release_archive_name ${package}-${version}-${current_platform_name}.tar.gz)
    set(debug_archive_name ${package}-${version}-dbg-${current_platform_name}.tar.gz)
    set(manifest_name Use${package}-${version}.cmake)
    set(lockfile_name "lock.txt")


    set(target_archive_release ${target_release_folder_path}/${release_archive_name})
    set(target_archive_debug ${target_debug_folder_path}/${debug_archive_name})
    set(target_manifest ${manifest_folder_path}/${manifest_name})
    set(target_lock ${manifest_folder_path}/${lockfile_name})

    # cannot upload the version because no archive found
    if(NOT EXISTS ${target_archive_release}
        OR NOT EXISTS ${target_manifest})
        return()
    endif()
    
    
    set(target_url_release ${registry}/packages/generic/${package}/${version}-${CURRENT_PLATFORM}/${release_archive_name})
    set(target_url_debug ${registry}/packages/generic/${package}/${version}-${CURRENT_PLATFORM}/${debug_archive_name})
    set(target_url_manifest ${registry}/packages/generic/${package}/${version}-${CURRENT_PLATFORM}/${manifest_name})
    set(target_url_lock ${registry}/packages/generic/${package}/${version}-${CURRENT_PLATFORM}/${lockfile_name})
    
    #1) create and upload the lock to inform that we are currently writing this package
    file(WRITE ${target_lock} "writing\n")#create the lock file
    set(LOCKED TRUE)
    while(LOCKED)
      check_Remote_File(LOCKED ${target_url_lock})
    endwhile()

    upload_File(ERROR_REASON ${target_lock} ${target_url_lock})
    if(ERROR_REASON)
        message("[PID] ERROR: cannot upload package ${package} version ${version} for platform ${CURRENT_PLATFORM}. Reason: ${ERROR_REASON}. ABORTING.")
        return()
    endif()
    # then get info about the package in the registry 
    update_Registry_Info(${registry} ${package})
    #then suppress all artefacts for version (we do not care for errors)
    set(package_id)
    foreach(id IN LISTS ALL_IDS_FOUND)
      if(${id}_VERSION VERSION_EQUAL version
        AND ${id}_PLATFORM STREQUAL CURRENT_PLATFORM)
          set(package_id ${id})#OK the package ID in registry has been found
          break()
      endif()
    endforeach()
    if(NOT package_id)
      message("[PID] ERROR: cannot upload package ${package} version ${version} for platform ${CURRENT_PLATFORM}. There is a problem getting information from the package registry ${registry}. This may be due to a connection problem or to an internal BUG. Please contact PID developers.")
      return()
    endif()
    #update file list for the given package
    update_Package_Files_List(${registry} ${package_id} ${release_archive_name} ${debug_archive_name} ${manifest_name} ${lockfile_name})
    
    #we can suppress the files contained in the package registry
    remove_Remote_File(${registry} ${package_id} ${release_archive_name})
    remove_Remote_File(${registry} ${package_id} ${debug_archive_name})
    remove_Remote_File(${registry} ${package_id} ${manifest_name})
    
    message("[PID] INFO: uploading binary package ${package} version ${version} for platform ${CURRENT_PLATFORM}...")
    upload_File(ERROR_REASON ${target_manifest} ${target_url_manifest})
    upload_File(ERROR_REASON2 ${target_archive_release} ${target_url_release})
    set(ERROR_REASON3)
    if(EXISTS ${target_archive_debug})
      upload_File(ERROR_REASON3 ${target_archive_debug} ${target_url_debug})
    endif()
    update_Package_Files_List(${registry} ${package_id} ${release_archive_name} ${debug_archive_name} ${manifest_name} ${lockfile_name})
    if(ERROR_REASON OR ERROR_REASON2 OR ERROR_REASON3)
        if(ERROR_REASON)
          set(error_output ${ERROR_REASON})
        elseif(ERROR_REASON2)
          set(error_output ${ERROR_REASON2})
        else()
          set(error_output ${ERROR_REASON3})
        endif()
        message("[PID] ERROR: cannot upload package ${package} version ${version} for platform ${CURRENT_PLATFORM}. Reason: ${error_output}. ABORTING.")
        remove_Remote_File(${registry} ${package_id} ${release_archive_name})
        remove_Remote_File(${registry} ${package_id} ${debug_archive_name})
        remove_Remote_File(${registry} ${package_id} ${manifest_name})
        remove_Remote_File(${registry} ${package_id} ${lockfile_name})    
        return()
    endif()
    # finally always removing the lock
    remove_Remote_File(${registry} ${package_id} ${lockfile_name})   
    message("[PID] INFO: binary package ${package} version ${version} for platform ${CURRENT_PLATFORM} has been uploaded...")
    set(${UPLOADED} TRUE PARENT_SCOPE)
endfunction(upload_Binary_Version)