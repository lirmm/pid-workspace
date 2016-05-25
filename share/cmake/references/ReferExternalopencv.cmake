#### referencing external package opencv ####
set(opencv_PID_Package_AUTHOR _Robin_Passama CACHE INTERNAL "")
set(opencv_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(opencv_PID_Package_CONTACT_MAIL passama@lirmm.fr CACHE INTERNAL "")
set(opencv_AUTHORS "OpenCV.org authors, see http://www.opencv.org" CACHE INTERNAL "")
set(opencv_LICENSES "3-clause BSD License" CACHE INTERNAL "")
set(opencv_DESCRIPTION external package providing C++ libraries for computer vision, repackaged for PID CACHE INTERNAL "")
set(opencv_CATEGORIES image vision CACHE INTERNAL "")


#declaration of possible platforms
set(opencv_AVAILABLE_PLATFORMS linux64cxx11;linux64;linux32 CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64cxx11_OS linux CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64cxx11_ARCH 64 CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64cxx11_ABI CXX11 CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64cxx11_CONFIGURATION  CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64_ABI CXX CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux64_CONFIGURATION  CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux32_ABI CXX CACHE INTERNAL "")
set(opencv_AVAILABLE_PLATFORM_linux32_CONFIGURATION  CACHE INTERNAL "")

# declaration of known references
set(opencv_REFERENCES 2.4.11 CACHE INTERNAL "")
set(opencv_REFERENCE_2.4.11 linux64cxx11 linux32 linux64 CACHE INTERNAL "")

#linux 32
set(opencv_REFERENCE_2.4.11_linux32_URL https://gite.lirmm.fr/pid/ext-opencv/repository/archive.tar.gz?ref=linux-32-2.4.11 CACHE INTERNAL "")
set(opencv_REFERENCE_2.4.11_linux32_FOLDER ext-opencv-linux-32-2.4.11-691f1f1dfefa162bb643b81f6362ef53f02efa2e CACHE INTERNAL "")

#linux 64 
set(opencv_REFERENCE_2.4.11_linux64_URL https://gite.lirmm.fr/pid/ext-opencv/repository/archive.tar.gz?ref=linux-64-2.4.11 CACHE INTERNAL "")
set(opencv_REFERENCE_2.4.11_linux64_FOLDER ext-opencv-linux-64-2.4.11-3438bee806663c2d17517c40f26d17d506b61298 CACHE INTERNAL "")

#linux64cxx11

set(opencv_REFERENCE_2.4.11_linux64cxx11_URL https://gite.lirmm.fr/pid/ext-opencv/repository/archive.tar.gz?ref=linux-64-cxx11-2.4.11 CACHE INTERNAL "")
set(opencv_REFERENCE_2.4.11_linux64cxx11_FOLDER ext-opencv-linux-64-cxx11-2.4.11-87d4c6d4d43c230daefc6d6acbed9162d17f9240 CACHE INTERNAL "")
