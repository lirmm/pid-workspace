#### referencing external package qtlibs ####
set(qtlibs_PID_Package_AUTHOR _Benjamin_Navarro CACHE INTERNAL "")
set(qtlibs_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(qtlibs_PID_Package_CONTACT_MAIL navarro@lirmm.fr CACHE INTERNAL "")
set(qtlibs_AUTHORS "qt.io authors, see http://www.qt.io/" CACHE INTERNAL "")
set(qtlibs_LICENSES "qtlibs license" CACHE INTERNAL "")
set(qtlibs_DESCRIPTION external package providing the Qt libraries libraries, repackaged for PID CACHE INTERNAL "")
set(qtlibs_CATEGORIES programming/threading programming/io programming/timing programming/windows CACHE INTERNAL "")


#declaration of possible platforms
set(qtlibs_AVAILABLE_PLATFORMS linux64;linux32;macosx64;macosx32 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64_CONFIGURATION x11 opengl CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux32_CONFIGURATION x11 opengl CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_macosx64_OS macosx CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_macosx64_ARCH 64 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_macosx64_CONFIGURATION opengl CACHE INTERNAL "")

# declaration of known references
set(qtlibs_REFERENCES 5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1 linux32 linux64 macosx64 CACHE INTERNAL "")

#linux 32
set(qtlibs_REFERENCE_5.4.1_linux32_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=linux-32-5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_linux32_FOLDER ext-qtlibs-linux-32-5.4.1-f357e44170031f23c91f0897d21c01c4cad4fadf CACHE INTERNAL "")

#linux 64
set(qtlibs_REFERENCE_5.4.1_linux64_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=linux-64-5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_linux64_FOLDER ext-qtlibs-linux-64-5.4.1-721dd518da12100632e4c0c2cdd1fbd636107cb0 CACHE INTERNAL "")

#macosx 64
set(qtlibs_REFERENCE_5.4.1_macosx64_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=macosx-5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_macosx64_FOLDER ext-qtlibs-macosx-5.4.1-ef3b4fb81f28c51e02a6668f5ecc79f5b2585000 CACHE INTERNAL "")


