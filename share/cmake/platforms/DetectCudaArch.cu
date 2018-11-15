#include <stdio.h>
int main()
{
    int count = 0;
    if (cudaSuccess != cudaGetDeviceCount(&count)){return -1;}
    if (count == 0) {return -1;}

    printf("%d",count);
    for (int device = 0; device < count; ++device)
    {
        cudaDeviceProp prop;
        if (cudaSuccess != cudaGetDeviceProperties(&prop, device)){ continue;}
        printf(";%d.%d", prop.major, prop.minor);
    }
    int driver_version = 0, runtime_version = 0;
    if (cudaSuccess != cudaDriverGetVersion(&driver_version)){return -1;}
    if (cudaSuccess != cudaRuntimeGetVersion(&runtime_version)){return -1;}

    printf(";%d;%d", driver_version, runtime_version);
    return 0;
}
