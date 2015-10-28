

########################################################################
##################### definition of CMake policies #####################
########################################################################
cmake_policy(SET CMP0026 OLD) #disable warning when reading LOCATION property
cmake_policy(SET CMP0048 OLD) #allow to use a custom versionning system
cmake_policy(SET CMP0037 OLD) #allow to redefine standard target such as clean
cmake_policy(SET CMP0045 OLD) #allow to test if a target exist without a warning

if(POLICY CMP0054)
	cmake_policy(SET CMP0054 NEW) #only KEYWORDS (without "") are considered as KEYWORDS
endif()

if(POLICY CMP0064)
	cmake_policy(SET CMP0064 NEW) #do not warn when a Keyword between guillemet "" is used in an if expression 
endif()

