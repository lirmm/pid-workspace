#### referencing external package ffmpeg ####
set(ffmpeg_PID_WRAPPER_CONTACT_AUTHOR _Robin_Passama CACHE INTERNAL "")
set(ffmpeg_PID_WRAPPER_CONTACT_INSTITUTION "LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr" CACHE INTERNAL "")
set(ffmpeg_PID_WRAPPER_CONTACT_CONTACT_MAIL passama@lirmm.fr CACHE INTERNAL "")

set(ffmpeg_AUTHORS "FFMPEG.org authors, see http://www.ffmpeg.org/" CACHE INTERNAL "")
set(ffmpeg_LICENSES "LGPL v2.1 license" CACHE INTERNAL "")
set(ffmpeg_DESCRIPTION external package providing C++ libraries to manage video streams, repackaged for PID CACHE INTERNAL "")
set(ffmpeg_CATEGORIES programming/video CACHE INTERNAL "")


# declaration of known references
set(ffmpeg_REFERENCES 2.7.1 2.8.2 CACHE INTERNAL "")

######## #version 2.7.1 ###########
set(ffmpeg_REFERENCE_2.7.1 x86_32_linux_abi98 x86_64_linux_abi98 CACHE INTERNAL "")

#linux 32
set(ffmpeg_REFERENCE_2.7.1_x86_32_linux_abi98_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux-32-2.7.1 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.7.1_x86_32_linux_abi98_FOLDER ext-ffmpeg-linux-32-2.7.1-b005d0ae1584a59850830ffb683e3bdcb274625e CACHE INTERNAL "")
#linux 64
set(ffmpeg_REFERENCE_2.7.1_x86_64_linux_abi98_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux-64-2.7.1 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.7.1_x86_64_linux_abi98_FOLDER ext-ffmpeg-linux-64-2.7.1-73e535c5c664ba25ee51f6c48b36df20cd06fd50 CACHE INTERNAL "")

######## #version 2.8.2 ###########
set(ffmpeg_REFERENCE_2.8.2 x86_64_linux_abi11 x86_64_linux_abi98 CACHE INTERNAL "")

#linux 64
set(ffmpeg_REFERENCE_2.8.2_x86_64_linux_abi98_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux-64-2.8.2 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.8.2_x86_64_linux_abi98_FOLDER ext-ffmpeg-linux-64-2.8.2-189082e52216ea8f2d92609aa91e7aa664486571 CACHE INTERNAL "")

#linux 64 cxx11
set(ffmpeg_REFERENCE_2.8.2_x86_64_linux_abi11_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux64cxx11-2.8.2 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.8.2_linux64cxx11_FOLDER ext-ffmpeg-linux64cxx11-2.8.2-39e2ea773a957f069bf24556bd0c1eabc34c7b0a CACHE INTERNAL "")
