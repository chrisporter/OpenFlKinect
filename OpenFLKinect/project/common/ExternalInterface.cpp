#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Kinect.h"
#include <vector>
#include "DeviceOptions.h"

using namespace openflkinect;
using namespace std;

DEFINE_KIND(k_DeviceOptions);
DEFINE_KIND(k_Kinect);

static vector<Kinect> kinects;

static value openflkinect_init(value in)
{
  value v;
  v = alloc_abstract(k_Kinect, new Kinect());

  Kinect* k = static_cast<Kinect*>(val_data(v));
  DeviceOptions& opts = k->getDeviceOptions();

  opts.deviceId = val_string(val_field(in, val_id("deviceId")));
  opts.deviceIndex = val_int(val_field(in, val_id("deviceIndex;")));

  opts.depthEnabled = val_bool(val_field(in, val_id("depthEnabled")));
  opts.colorEnabled = val_bool(val_field(in, val_id("colorEnabled")));
  opts.irEnabled = val_bool(val_field(in, val_id("irEnabled")));
  opts.skeletonTrackingEnabled =
    val_bool(val_field(in, val_id("skeletonTrackingEnabled")));
  opts.interactionEnabled = val_bool(val_field(in, val_id("interactionEnabled")));
  cout << opts.interactionEnabled << endl;
  opts.depthResolution =
     opts.getResolution(val_string(val_field(in, val_id("depthResolution"))));

  opts.depthSize = opts.Vec2fromHaxePoint(in, "depthSize");

  opts.colorResolution =
      opts.getResolution(val_string(
                  val_field(in, val_id("colorResolution"))));
  opts.colorSize = opts.Vec2fromHaxePoint(in, "colorSize");
  opts.irResolution =
      opts.getResolution(val_string(
                  val_field(in, val_id("irResolution"))));
  opts.irSize = opts.Vec2fromHaxePoint(in, "irSize");

  opts.nearModeEnabled = val_bool(val_field(in, val_id("nearModeEn:wabled")));
  opts.seatedModeEnabled = val_bool(val_field(in, val_id("seatedModeEnabled")));
  opts.userTrackingEnabled = val_bool(val_field(in, val_id("userTrackingEnabled")));
  opts.extendedModeEnabled = val_bool(val_field(in, val_id("extendedModeEnabled")));
  opts.mapColorToDepth = val_bool(val_field(in, val_id("mapColorToDepth")));
  opts.mapDepthToColor = val_bool(val_field(in, val_id("mapDepthToColor")));

  opts.binaryMode = val_bool(val_field(in, val_id("binaryMode")));
  opts.userColor = val_bool(val_field(in, val_id("userColor")));
  opts.removeBackground = val_bool(val_field(in, val_id("removeBackground")));
  opts.inverted = val_bool(val_field(in, val_id("inverted")));

  opts.flipped = val_bool(val_field(in, val_id("flipped")));
  opts.transform = opts.getTransform(val_string(val_field(in,
          val_id("transform"))));
  return v;
}
DEFINE_PRIM (openflkinect_init, 1);


static void openflkinect_start(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));
  k->start();
}
DEFINE_PRIM (openflkinect_start, 1);

static void openflkinect_update(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));
  k->update();
}
DEFINE_PRIM (openflkinect_update, 1);

static value openflkinect_update_depth_pixels(value ref, value depthArray)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  int* ints = val_array_int(depthArray);
  if ( ! ints )
  {
    cout << "not ints" << endl;
    return alloc_bool(false);
  }

  if ( k->isCapturing() == false )
  {
    return alloc_bool(false);
  }

  int* depth = k->depthPixels();
  int dims = k->getDeviceOptions().numDepthPixels();
  memcpy(ints, depth, dims*sizeof(int));
  return alloc_bool(true);
}
DEFINE_PRIM (openflkinect_update_depth_pixels, 2);

static value openflkinect_update_color_pixels(value ref, value colorArray)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  int* ints = val_array_int(colorArray);
  if ( ! ints )
  {
    return alloc_bool(false);
  }

  if ( k->isCapturing() == false )
  {
    return alloc_bool(false);
  }

  int* color = k->colorPixels();
  int dims = k->getDeviceOptions().numColorPixels();
  memcpy(ints, color, dims*sizeof(int));
  return alloc_bool(true);
}
DEFINE_PRIM (openflkinect_update_color_pixels, 2);

static value openflkinect_update_ir_pixels(value ref, value irArray)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  int* ints = val_array_int(irArray);
  if ( ! ints )
  {
    return alloc_bool(false);
  }

  if ( k->isCapturing() == false )
  {
    return alloc_bool(false);
  }

  int* ir = k->irPixels();
  int dims = k->getDeviceOptions().numIrPixels();
  memcpy(ints, ir, dims*sizeof(int));
  return alloc_bool(true);
}
DEFINE_PRIM (openflkinect_update_ir_pixels, 2);

static value openflkinect_ir_frame_rate(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  if ( k->isCapturing() == false )
  {
    return alloc_float(0.0f);
  }

  return alloc_float(k->depthFrameRate());
}
DEFINE_PRIM (openflkinect_ir_frame_rate, 1);

static value openflkinect_color_frame_rate(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  if ( k->isCapturing() == false )
  {
    return alloc_float(0.0f);
  }

  return alloc_float(k->colorFrameRate());
}
DEFINE_PRIM (openflkinect_color_frame_rate, 1);

static value openflkinect_depth_frame_rate(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  if ( k->isCapturing() == false )
  {
    return alloc_float(0.0f);
  }

  return alloc_float(k->depthFrameRate());
}
DEFINE_PRIM (openflkinect_depth_frame_rate, 1);

static value openflkinect_get_tilt(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  if ( k->isCapturing() == false )
  {
    return alloc_int(0);
  }

  return alloc_int(k->getTilt());
}
DEFINE_PRIM (openflkinect_get_tilt, 1);

static value openflkinect_get_user_count(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  if ( k->isCapturing() == false )
  {
    return alloc_int(0);
  }

  return alloc_int(k->getUserCount());
}
DEFINE_PRIM (openflkinect_get_user_count, 1);

static value openflkinect_get_is_capturing(value ref)
{
  val_check_kind(ref, k_Kinect);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  return alloc_bool(k->isCapturing());
}
DEFINE_PRIM (openflkinect_get_is_capturing, 1);

static void openflkinect_set_tilt(value ref, value degrees)
{
  val_check_kind(ref, k_Kinect);
  val_check(degrees, int);
  Kinect* k = static_cast<Kinect*>(val_data(ref));

  k->setTilt(val_int(degrees));
}
DEFINE_PRIM (openflkinect_set_tilt, 2);

static value get_bone(Bone b)
{
  value bone;
  bone = alloc_empty_object();

  alloc_field(bone, val_id("skeletonPositionIndex"),
      alloc_int(b.orientation.endJoint) );
  alloc_field(bone, val_id("startJoint"),
      alloc_int(b.orientation.startJoint) );
  alloc_field(bone, val_id("endJoint"),
      alloc_int(b.orientation.endJoint) );
  // POSITION

  value pos = alloc_empty_object();
  //if ( b.orientation.endJoint == NUI_SKELETON_POSITION_HAND_RIGHT )
  //{
     //cout << b.position.x << endl;
  //}
  alloc_field(pos, val_id("x"), alloc_float(b.position.x));
  alloc_field(pos, val_id("y"), alloc_float(b.position.y));
  alloc_field(pos, val_id("z"), alloc_float(b.position.z));
  alloc_field(bone, val_id("position"), pos );
  //

  // HIERACHICAL ROTATION
  _NUI_SKELETON_BONE_ROTATION rot;
  //rot.rotationMatrix.M11 = 1.4f;
  //rot.rotationQuaternion.x = 0.9f;
  value hRot = alloc_empty_object();
  value rotationMatrix = alloc_empty_object();
  value rotationQuaternion = alloc_empty_object();
  alloc_field(hRot, val_id("rotationMatrix"), rotationMatrix);
  alloc_field(hRot, val_id("rotationQuaternion"), rotationQuaternion);

  alloc_field(rotationMatrix, val_id("M11"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M11 ));
  alloc_field(rotationMatrix, val_id("M12"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M12 ));
  alloc_field(rotationMatrix, val_id("M13"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M13 ));
  alloc_field(rotationMatrix, val_id("M14"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M14 ));
  alloc_field(rotationMatrix, val_id("M21"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M21 ));
  alloc_field(rotationMatrix, val_id("M22"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M22 ));
  alloc_field(rotationMatrix, val_id("M23"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M23 ));
  alloc_field(rotationMatrix, val_id("M24"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M24 ));
  alloc_field(rotationMatrix, val_id("M31"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M31 ));
  alloc_field(rotationMatrix, val_id("M32"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M32 ));
  alloc_field(rotationMatrix, val_id("M33"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M33 ));
  alloc_field(rotationMatrix, val_id("M34"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M34 ));
  alloc_field(rotationMatrix, val_id("M41"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M41 ));
  alloc_field(rotationMatrix, val_id("M42"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M42 ));
  alloc_field(rotationMatrix, val_id("M43"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M43 ));
  alloc_field(rotationMatrix, val_id("M44"),
      alloc_float( b.orientation.hierarchicalRotation.rotationMatrix.M44 ));

  alloc_field(rotationQuaternion, val_id("x"),
      alloc_float( b.orientation.hierarchicalRotation.rotationQuaternion.x));
  alloc_field(rotationQuaternion, val_id("y"),
      alloc_float( b.orientation.hierarchicalRotation.rotationQuaternion.y));
  alloc_field(rotationQuaternion, val_id("z"),
      alloc_float( b.orientation.hierarchicalRotation.rotationQuaternion.z));
  alloc_field(bone, val_id("hierarchicalRotation"), hRot);
  //
  // ABSOLUTE ROTATION
  _NUI_SKELETON_BONE_ROTATION rotA;
  value hRot2 = alloc_empty_object();
  value rotationMatrix2 = alloc_empty_object();
  value rotationQuaternion2 = alloc_empty_object();
  alloc_field(hRot2, val_id("rotationMatrix"), rotationMatrix2);
  alloc_field(hRot2, val_id("rotationQuaternion"), rotationQuaternion2);

  alloc_field(rotationMatrix2, val_id("M11"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M11 ));
  alloc_field(rotationMatrix2, val_id("M12"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M12 ));
  alloc_field(rotationMatrix2, val_id("M13"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M13 ));
  alloc_field(rotationMatrix2, val_id("M14"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M14 ));
  alloc_field(rotationMatrix2, val_id("M21"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M21 ));
  alloc_field(rotationMatrix2, val_id("M22"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M22 ));
  alloc_field(rotationMatrix2, val_id("M23"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M23 ));
  alloc_field(rotationMatrix2, val_id("M24"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M24 ));
  alloc_field(rotationMatrix2, val_id("M31"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M31 ));
  alloc_field(rotationMatrix2, val_id("M32"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M32 ));
  alloc_field(rotationMatrix2, val_id("M33"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M33 ));
  alloc_field(rotationMatrix2, val_id("M34"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M34 ));
  alloc_field(rotationMatrix2, val_id("M41"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M41 ));
  alloc_field(rotationMatrix2, val_id("M42"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M42 ));
  alloc_field(rotationMatrix2, val_id("M43"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M43 ));
  alloc_field(rotationMatrix2, val_id("M44"),
      alloc_float( b.orientation.absoluteRotation.rotationMatrix.M44 ));

  alloc_field(rotationQuaternion2, val_id("x"),
      alloc_float( b.orientation.absoluteRotation.rotationQuaternion.x));
  alloc_field(rotationQuaternion2, val_id("y"),
      alloc_float( b.orientation.absoluteRotation.rotationQuaternion.y));
  alloc_field(rotationQuaternion2, val_id("z"),
      alloc_float( b.orientation.absoluteRotation.rotationQuaternion.z));

  alloc_field(bone, val_id("absoluteRotation"), hRot2);
  return bone;
}

typedef std::map<JointName, Bone>::iterator boneIt;

static value openflkinect_update_skeletons(value ref)
{
  val_check_kind(ref, k_Kinect);

  Kinect* k = static_cast<Kinect*>(val_data(ref));

  vector<Skeleton> trackedSkels = k->skeletons();
  value skeletons = alloc_array(trackedSkels.size());
  for ( int i=0; i<trackedSkels.size(); i++ )
  {
    Skeleton& s = trackedSkels[i];
    value skeleton = alloc_empty_object();
    val_array_set_i(skeletons, i, skeleton);

    if ( trackedSkels[i].size() > 0 )
    {
      alloc_field( skeleton, val_id( "isTracked" ),
          alloc_bool( true ) );
      value bones = alloc_array( trackedSkels[i].size() );
      alloc_field(skeleton, val_id("bones"), bones);

      for ( int j=0; j<trackedSkels[i].size(); j++ )
      {
        int k = 0;
        for ( boneIt it = trackedSkels[i].begin();
            it != trackedSkels[i].end(); ++it )
        {
          //cout << it->second.orientation.startJoint << endl;
          value b = get_bone(it->second);
          val_array_set_i(bones, k++, b);
        }
      }

    }
    else
    {
      alloc_field( skeleton, val_id( "isTracked" ),
          alloc_bool( false ) );

    }
  }
  return skeletons;
}
DEFINE_PRIM (openflkinect_update_skeletons, 1);

static value openflkinect_get_skeleton_color_pos(value ref, value vec3)
{
  val_check_kind(ref, k_Kinect);

  Kinect* k = static_cast<Kinect*>(val_data(ref));
  Vec2i adjusted = k->getSkeletonColorPos(Vec3f(
        val_float(val_field(vec3, val_id("x"))),
        val_float(val_field(vec3, val_id("y"))),
        val_float(val_field(vec3, val_id("z"))) ));
  value ret = alloc_empty_object();
  alloc_field( ret, val_id("x"), alloc_int(adjusted.x));
  alloc_field( ret, val_id("y"), alloc_int(adjusted.y));
  return ret;
}
DEFINE_PRIM (openflkinect_get_skeleton_color_pos, 2);

static value openflkinect_get_skeleton_depth_pos(value ref, value vec3)
{
  val_check_kind(ref, k_Kinect);

  Kinect* k = static_cast<Kinect*>(val_data(ref));
  Vec2i adjusted = k->getSkeletonDepthPos(Vec3f(
        val_float(val_field(vec3, val_id("x"))),
        val_float(val_field(vec3, val_id("y"))),
        val_float(val_field(vec3, val_id("z"))) ));
  value ret = alloc_empty_object();
  alloc_field( ret, val_id("x"), alloc_int(adjusted.x));
  alloc_field( ret, val_id("y"), alloc_int(adjusted.y));
  return ret;
}
DEFINE_PRIM (openflkinect_get_skeleton_depth_pos, 2);

static value openflkinect_get_user_col(value ref, value userID)
{
  val_check_kind(ref, k_Kinect);

  Kinect* k = static_cast<Kinect*>(val_data(ref));
  return alloc_int( k->getUserColor( val_int(userID) ) );
}
DEFINE_PRIM (openflkinect_get_user_col, 2);

static value openflkinect_update_interactions(value ref)
{
  val_check_kind(ref, k_Kinect);

  Kinect* k = static_cast<Kinect*>(val_data(ref));

  vector<NUI_USER_INFO> userInfos = k->interactionInfo();
  value users = alloc_array(userInfos.size());
  for ( int i=0; i<userInfos.size(); i++ )
  {
    NUI_USER_INFO& s = userInfos[i];
    value user = alloc_empty_object();
    val_array_set_i(users, i, user);

    if ( userInfos[i].SkeletonTrackingId > 0 )
    {
      alloc_field( user, val_id( "isTracked" ),
          alloc_bool( true ) );
      alloc_field( user, val_id("skeletonTrackingId"),
          alloc_int(userInfos[i].SkeletonTrackingId ));
      value hands = alloc_array( NUI_USER_HANDPOINTER_COUNT );
      alloc_field( user, val_id("handPointerInfos"),
          hands);

      for ( int j=0; j<NUI_USER_HANDPOINTER_COUNT; j++ )
      {
        value hand = alloc_empty_object();
        val_array_set_i(hands, j, hand);
        alloc_field( hand, val_id("handTypeEvent"),
            alloc_float( userInfos[i].HandPointerInfos[j].HandEventType ));
        alloc_field( hand, val_id("handType"),
            alloc_float( userInfos[i].HandPointerInfos[j].HandType ));
        alloc_field( hand, val_id("pressExtent"),
            alloc_float( userInfos[i].HandPointerInfos[j].PressExtent ));
        alloc_field( hand, val_id("rawX"),
            alloc_float( userInfos[i].HandPointerInfos[j].RawX ));
        alloc_field( hand, val_id("rawY"),
            alloc_float( userInfos[i].HandPointerInfos[j].RawY ));
        alloc_field( hand, val_id("rawZ"),
            alloc_float( userInfos[i].HandPointerInfos[j].RawZ ));
        alloc_field( hand, val_id("state"),
            alloc_float( userInfos[i].HandPointerInfos[j].State ));
        alloc_field( hand, val_id("x"),
            alloc_float( userInfos[i].HandPointerInfos[j].X ));
        alloc_field( hand, val_id("y"),
            alloc_float( userInfos[i].HandPointerInfos[j].Y ));
        val_array_set_i(hands, j, hand);

      }
    }
    else
    {
      alloc_field( user, val_id( "isTracked" ), alloc_bool( false ) );
    }
  }
  return users;
}
DEFINE_PRIM (openflkinect_update_interactions, 1);

static value openflkinect_get_status(value ref)
{
  val_check_kind(ref, k_Kinect);

  Kinect* k = static_cast<Kinect*>(val_data(ref));
  return alloc_int( k->nuiStatus() );
}
DEFINE_PRIM (openflkinect_get_status, 1);

