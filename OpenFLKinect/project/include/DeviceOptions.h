#ifndef DEVICE_OPTIONS_H
#define DEVICE_OPTIONS_H

#include <iostream>
#include <map>
#include <string>
#include <hx/CFFI.h>

#include "ole2.h"
#include "NuiApi.h"
#include "NuiImageCamera.h"
#include "Vec2.h"

namespace openflkinect
{

typedef Vec2<int> Vec2i;
typedef Vec2<float> Vec2f;

struct DeviceOptions
{
    enum : uint_fast8_t
    {
      TRANSFORM_NONE, TRANSFORM_DEFAULT, TRANSFORM_SMOOTH, TRANSFORM_VERY_SMOOTH, TRANSFORM_MAX
    } typedef Transform;

    std::string deviceId;
    int deviceIndex;

    bool depthEnabled;
    bool colorEnabled;
    bool irEnabled;
    bool skeletonTrackingEnabled;
    bool interactionEnabled;

    _NUI_IMAGE_RESOLUTION depthResolution;
    Vec2i depthSize;
    _NUI_IMAGE_RESOLUTION colorResolution;
    Vec2i colorSize;
    _NUI_IMAGE_RESOLUTION irResolution;
    Vec2i irSize;


    bool nearModeEnabled;
    bool seatedModeEnabled;
    bool userTrackingEnabled;
    bool extendedModeEnabled;
    bool mapColorToDepth;

    bool binaryMode;
    bool userColor;
    bool removeBackground;
    bool inverted;

    bool flipped;
    uint_fast8_t transform;

    int numDepthPixels()
    {
      return depthSize.x*depthSize.y;
    }

    int numColorPixels()
    {
      return colorSize.x*colorSize.y;
    }

    int numIrPixels()
    {
      return irSize.x*irSize.y;
    }

    std::map<std::string, _NUI_IMAGE_RESOLUTION> imageResolutionMap;
    std::map<std::string, Transform> transformMap;

    DeviceOptions():
        deviceId("")
    {
      imageResolutionMap["ImageResolution.NUI_IMAGE_RESOLUTION_INVALID"] = NUI_IMAGE_RESOLUTION_INVALID;
      imageResolutionMap["ImageResolution.NUI_IMAGE_RESOLUTION_80x60"] = NUI_IMAGE_RESOLUTION_80x60;
      imageResolutionMap["ImageResolution.NUI_IMAGE_RESOLUTION_320x240"] = NUI_IMAGE_RESOLUTION_320x240;
      imageResolutionMap["ImageResolution.NUI_IMAGE_RESOLUTION_640x480"] = NUI_IMAGE_RESOLUTION_640x480;
      imageResolutionMap["ImageResolution.NUI_IMAGE_RESOLUTION_1280x960"] = NUI_IMAGE_RESOLUTION_1280x960;

      transformMap["SkeletonTransform.TRANSFORM_NONE"] = Transform::TRANSFORM_NONE;
      transformMap["SkeletonTransform.TRANSFORM_DEFAULT"] = Transform::TRANSFORM_DEFAULT;
      transformMap["SkeletonTransform.TRANSFORM_SMOOTH"] = Transform::TRANSFORM_SMOOTH;
      transformMap["SkeletonTransform.TRANSFORM_VERY_SMOOTH"] = Transform::TRANSFORM_VERY_SMOOTH;
      transformMap["SkeletonTransform.TRANSFORM_MAX"] = Transform::TRANSFORM_MAX;
    }

    _NUI_IMAGE_RESOLUTION getResolution(const char* val)
    {
      return imageResolutionMap[val];
    }

    Transform getTransform(const char* val)
    {
      return transformMap[val];
    }

    Vec2i Vec2fromHaxePoint(value in, const char* field)
    {
      value ds = val_field(in, val_id(field));
      return Vec2i(val_int(val_field(ds, val_id("x"))),
        val_int(val_field(ds, val_id("y"))));
    }

};

}


#endif
