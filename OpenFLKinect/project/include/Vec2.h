#ifndef VEC2_H
#define VEC2_H

namespace openflkinect
{
  template <typename T>
  struct Vec2
  {
    T x;
    T y;

    Vec2():
      x(0),
      y(0)
    {

    }

    Vec2(T nx, T ny):
      x(nx),
      y(ny)
    {

    }

    //Vec2( const Vec2& src ):
      //x(src.x),
      //y(src.y)
    //{
    //}

  };

}

#endif

