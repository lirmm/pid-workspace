#### referencing external package vimba ####
set(vimba_PID_Package_AUTHOR _Robin_Passama CACHE INTERNAL "")
set(vimba_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(vimba_PID_Package_CONTACT_MAIL passama@lirmm.fr CACHE INTERNAL "")
set(vimba_AUTHORS "Allied Vision Technology Gmbh, see http://www.alliedvision.com/" CACHE INTERNAL "")
set(vimba_LICENSES "Allied Vision Technology license for Vimba" CACHE INTERNAL "")
set(vimba_DESCRIPTION "external package providing driver for AVT cameras" CACHE INTERNAL "")
set(vimba_CATEGORIES camera/avt CACHE INTERNAL "")



#declaration of possible platforms
set(vimba_AVAILABLE_PLATFORMS linux64;linux32;macosx64;macosx32 CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_linux64_CONFIGURATION  CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_linux32_CONFIGURATION  CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_macosx64_OS macosx CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_macosx64_ARCH 64 CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_macosx64_CONFIGURATION  CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_macosx32_OS macosx CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_macosx32_ARCH 32 CACHE INTERNAL "")
set(vimba_AVAILABLE_PLATFORM_macosx32_CONFIGURATION  CACHE INTERNAL "")

# declaration of known references
set(vimba_REFERENCES 1.3.0 CACHE INTERNAL "")
set(vimba_REFERENCE_1.3.0 linux32 linux64 CACHE INTERNAL "")

# linux 32
set(vimba_REFERENCE_1.3.0_linux32_URL https://gite.lirmm.fr/rob-vision-devices/ext-vimba/repository/archive.tar.gz?ref=linux-32-1.3.0 CACHE INTERNAL "")
set(vimba_REFERENCE_1.3.0_linux32_FOLDER ext-vimba-linux-32-1.3.0-83564ee58dca03c61d0755fa03a5a1060f5276cc CACHE INTERNAL "")

# linux 64 

set(vimba_REFERENCE_1.3.0_linux64_URL https://gite.lirmm.fr/rob-vision-devices/ext-vimba/repository/archive.tar.gz?ref=linux-64-1.3.0 CACHE INTERNAL "")
set(vimba_REFERENCE_1.3.0_linux64_FOLDER ext-vimba-linux-64-1.3.0-a21b70072d7cf8ecc38fe4e019929b3ff52470f2 CACHE INTERNAL "")
