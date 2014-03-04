#ifndef VEC3_H
#define VEC3_H

#include "Vec2.h"

namespace openflkinect
{
  template <typename T>
  struct Vec3 : Vec2<T>
  {
    T z;

    Vec3():
      Vec2(),
      z(0)
    {

    }

    Vec3(T nx, T ny, T nz):
      Vec2(nx, ny),
      z(nz)
    {

    }
  };

}

#endif

