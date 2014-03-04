#ifndef BONE_H
#define BONE_H



#include "NuiImageCamera.h"
#include "NuiApi.h"

namespace openflkinect
{

struct Bone
{
  Bone(Vector4 pos, NUI_SKELETON_BONE_ORIENTATION orien)
    :
    position(pos),
    orientation(orien)
  {

  }

  NUI_SKELETON_BONE_ORIENTATION orientation;
  Vector4 position;

};

}
#endif
