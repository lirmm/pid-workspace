// #include <iso646.h>
#include <iostream>
#include <sstream>

int main(){
  std::stringstream out;
  #if defined _LIBCPP_VERSION
    int version=(_LIBCPP_VERSION/1000);
    int revision=(_LIBCPP_VERSION%1000);
    out<<"c++;"<<version<<"."<<revision;
  #elif defined _GLIBCXX_RELEASE
    out<<"stdc++;"<<_GLIBCXX_RELEASE;
  #elif defined _MSC_VER
    out<<"msvc;"<<_MSC_VER;
  #elif __INTEL_CXXLIB_ICC
    out <<"icc;"<< __INTEL_CXXLIB_ICC;
  #else
    #error Using an unknown standard library
  #endif
  std::cout<<out.str();
  return(0);
}
