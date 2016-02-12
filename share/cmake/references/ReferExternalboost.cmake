#### referencing external package boost ####
set(boost_PID_Package_AUTHOR _Robin_Passama CACHE INTERNAL "")
set(boost_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(boost_PID_Package_CONTACT_MAIL passama@lirmm.fr CACHE INTERNAL "")
set(boost_AUTHORS "Boost.org authors, see http://www.boost.org/" CACHE INTERNAL "")
set(boost_LICENSES "Boost license" CACHE INTERNAL "")
set(boost_DESCRIPTION external package providing many usefull C++ libraries, repackaged for PID CACHE INTERNAL "")
set(boost_CATEGORIES programming/threading;programming/io;programming/timing;programming/container;programming/meta CACHE INTERNAL "")

#declaration of possible platforms
set(boost_AVAILABLE_PLATFORMS linux64;linux32;macosx64;macosx32 CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_linux64_CONFIGURATION  CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_linux32_CONFIGURATION  CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_macosx64_OS macosx CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_macosx64_ARCH 64 CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_macosx64_CONFIGURATION  CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_macosx32_OS macosx CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_macosx32_ARCH 32 CACHE INTERNAL "")
set(boost_AVAILABLE_PLATFORM_macosx32_CONFIGURATION  CACHE INTERNAL "")

#declaration of references
set(boost_REFERENCES 1.55.0 CACHE INTERNAL "")
set(boost_REFERENCE_1.55.0 linux32 linux64 macosx64 CACHE INTERNAL "")

#linux 32
set(boost_REFERENCE_1.55.0_linux32_URL https://gite.lirmm.fr/pid/ext-boost/repository/archive.tar.gz?ref=linux-32-1.55.0 CACHE INTERNAL "")
set(boost_REFERENCE_1.55.0_linux32_FOLDER ext-boost-linux-32-1.55.0-c74d0acc8e7a4b683eed88c55077b4a34f821e31 CACHE INTERNAL "")

#linux 64
set(boost_REFERENCE_1.55.0_linux64_URL https://gite.lirmm.fr/pid/ext-boost/repository/archive.tar.gz?ref=linux-64-1.55.0 CACHE INTERNAL "")
set(boost_REFERENCE_1.55.0_linux64_FOLDER ext-boost-linux-64-1.55.0-e86d35e51b47bd069d721337c2ce37b4f794400a CACHE INTERNAL "")

#macosx 64
set(boost_REFERENCE_1.55.0_macosx64_URL https://gite.lirmm.fr/pid/ext-boost/repository/archive.tar.gz?ref=macosx-1.55.0 CACHE INTERNAL "")
set(boost_REFERENCE_1.55.0_macosx64_FOLDER ext-boost-macosx-1.55.0-401061767ee224bb6ffa66c4307c0abe84a2455f CACHE INTERNAL "")

