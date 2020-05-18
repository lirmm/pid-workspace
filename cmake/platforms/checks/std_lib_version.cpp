// #include <iso646.h>
#include <iostream>
#include <sstream>

int main(){
  std::stringstream out;
  #if defined _LIBCPP_VERSION
    out<<_LIBCPP_VERSION;
  #elif defined _GLIBCXX_RELEASE
    out<<_GLIBCXX_RELEASE;
  #elif __INTEL_CXXLIB_ICC
    out << __INTEL_CXXLIB_ICC;
  #else
    #error Using an unknown standard library
  #endif
  std::cout<<out.str();
  return(0);
}
