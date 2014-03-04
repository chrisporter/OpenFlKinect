#pragma once
#ifndef UTILS_H
#define UTILS_H
#define NEKO_COMPATIBLE
#include <hx/CFFI.h>

struct Utils
{
    template<typename T>
    static T clamp(T val, T min=0, T max=1)
    {
        return ( val < min ) ? min : ( ( val > max ) ? max : val );
    }


};

#endif
