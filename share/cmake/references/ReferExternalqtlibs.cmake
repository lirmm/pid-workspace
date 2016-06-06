#### referencing external package qtlibs ####
set(qtlibs_PID_Package_AUTHOR _Benjamin_Navarro CACHE INTERNAL "")
set(qtlibs_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(qtlibs_PID_Package_CONTACT_MAIL navarro@lirmm.fr CACHE INTERNAL "")
set(qtlibs_AUTHORS "qt.io authors, see http://www.qt.io/" CACHE INTERNAL "")
set(qtlibs_LICENSES "qtlibs license" CACHE INTERNAL "")
set(qtlibs_DESCRIPTION external package providing the Qt libraries libraries, repackaged for PID CACHE INTERNAL "")
set(qtlibs_CATEGORIES programming/threading programming/io programming/timing programming/windows CACHE INTERNAL "")


#declaration of possible platforms
set(qtlibs_AVAILABLE_PLATFORMS linux64cxx11;linux64;linux32;macosx64 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64cxx11_OS linux64cxx11 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64cxx11_ARCH 64 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64cxx11_ABI CXX11 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64cxx11_CONFIGURATION x11 opengl CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux64_CONFIGURATION x11 opengl CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_linux32_CONFIGURATION x11 opengl CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_macosx64_OS macosx CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_macosx64_ARCH 64 CACHE INTERNAL "")
set(qtlibs_AVAILABLE_PLATFORM_macosx64_CONFIGURATION CACHE INTERNAL "")

# declaration of known references
set(qtlibs_REFERENCES 5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1 linux64cxx11 linux32 linux64 macosx64 CACHE INTERNAL "")

#linux 32
set(qtlibs_REFERENCE_5.4.1_linux32_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=linux-32-5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_linux32_FOLDER ext-qtlibs-linux-32-5.4.1-d3b1e8730c48f326ee54b35c4b3555a2046b4f79 CACHE INTERNAL "")


#linux 64 cxx11
set(qtlibs_REFERENCE_5.4.1_linux64cxx11_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=linux-64cxx11-5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_linux64cxx11_FOLDER ext-qtlibs-linux-64cxx11-5.4.1-4dfe67a0d19f66a15c1ae7cfbca620f1167f6394 CACHE INTERNAL "")

#linux 64
set(qtlibs_REFERENCE_5.4.1_linux64_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=linux-64-5.4.1 CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_linux64_FOLDER ext-qtlibs-linux-64-5.4.1-e51168017730a6b17f4dd036e9f898eeef1014ed CACHE INTERNAL "")

#macosx 64
set(qtlibs_REFERENCE_5.4.1_macosx64_URL https://gite.lirmm.fr/pid/ext-qtlibs/repository/archive.tar.gz?ref=macosx-5.4.1CACHE INTERNAL "")
set(qtlibs_REFERENCE_5.4.1_macosx64_FOLDER ext-qtlibs-macosx-5.4.1-cd27fc4c101f1e425982495cc2e0bc205a15dee8 CACHE INTERNAL "")


