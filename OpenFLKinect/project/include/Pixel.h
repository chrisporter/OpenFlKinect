#ifndef PIXEL_H
#define PIXEL_H

namespace openflkinect
{
  struct Pixel
  {
    Pixel():
      r(0),
      g(0),
      b(0),
      a(0)
    {

    };

    char r;
    char g;
    char b;
    char a;
  };
}

#endif

