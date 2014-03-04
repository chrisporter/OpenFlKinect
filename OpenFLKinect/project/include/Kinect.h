#ifndef OPENFLKINECT_H
#define OPENFLKINECT_H

//#if defined( _DEBUG )
//#pragma comment( lib, "comsuppwd.lib" )
//#else
//#pragma comment( lib, "comsuppw.lib" )
//#endif
//#pragma comment( lib, "wbemuuid.lib" )

#include <comdef.h>
#include "ole2.h"
#include "NuiApi.h"
#include <vector>
#include <thread>
#include <iostream>
#include <memory>
#include "DeviceOptions.h"
#include "Pixel.h"
#include "Utils.h"
#include "Vec2.h"
#include "Vec3.h"
#include <time.h>
#include <map>
#include "Bone.h"
#include <KinectInteraction.h>
#include "DummyInteractionClient.h"

namespace openflkinect
{

typedef NUI_SKELETON_BONE_ROTATION BoneRotation;
typedef NUI_IMAGE_RESOLUTION ImageResolution;
typedef NUI_SKELETON_POSITION_INDEX JointName;
typedef std::map<JointName, Bone> Skeleton;
typedef Vec3<int> Vec3i;
typedef Vec3<float> Vec3f;

class Kinect
{
public:

  static const int32_t MAXIMUM_TILT_ANGLE = 28;

  Kinect():
    mCapture(false),
    mVerbose(true),
    mConnectCount(0)
  {
    for ( int32_t i = 0; i < NUI_SKELETON_COUNT; ++i )
    {
      mSkeletons.push_back( Skeleton() );
    }
  }
  ~Kinect();
  void init();
  void start();
  void stop();
  void update();
  void error( long hr );

  int32_t getDeviceCount();
  DeviceOptions& getDeviceOptions();
  DeviceOptions& setDeviceOptions(const DeviceOptions& val);

  int* depthPixels() const;
  int* colorPixels() const;
  int* irPixels() const;

  float depthFrameRate();
  float skeletonFrameRate();
  float colorFrameRate();
  float irFrameRate();

  bool isCapturing();
  int32_t getTilt();
  void setTilt(int32_t degrees = 0);
  int32_t getUserCount();
  std::vector<Skeleton> skeletons();
  //! Returns pixel location of skeleton position in depth image.
  Vec2i getSkeletonDepthPos( const Vec3f& v );
  //! Returns pixel location of skeleton position in color image.
  Vec2i getSkeletonColorPos( const Vec3f& v );
  //! Returns pixel location of color position in depth image.
  Vec2i getColorDepthPos( const Vec2i& v );

  static int32_t getUserColor( uint32_t id );

  std::vector<NUI_USER_INFO> interactionInfo();
  int nuiStatus();

private:

  bool mVerbose;
  static const int32_t WAIT_TIME = 255;
  INuiSensor* mSensor;
  std::shared_ptr<std::thread> mThread;
  bool mCapture;
  void* mDepthStreamHandle;
  void *mColorStreamHandle;
  void *mIrStreamHandle;
  volatile bool mNewDepthBitmap;
  volatile bool mNewColorBitmap;
  volatile bool mNewIrBitmap;
  volatile bool mNewInteractionInfo;

  void trace( const std::string& message );
  bool createDevice();
  bool initStreams();
  bool openDepthStream();
  bool openColorStream();
  bool openIrStream();
  void pixelToDepthBitmap( uint16_t* buffer );
  void pixelToDepthBitmap( NUI_DEPTH_IMAGE_PIXEL * pBuffer );
  void pixelToColorBitmap( uint8_t* buffer );
  void pixelToIrBitmap( uint16_t* bufffer );
  Pixel shortToPixel ( uint16_t value );
  unsigned char* mRgbDepth;
  int* mDepthPixels;
  int* mColorPixels;
  int* mIrPixels;
  bool mActiveUsers[ NUI_SKELETON_COUNT ];
  double mReadTimeDepth;
  double mReadTimeSkeleton;
  double mReadTimeColor;
  double mReadTimeIR;
  float mFrameRateDepth;
  float mFrameRateSkeleton;
  float mFrameRateColor;
  float mFrameRateIR;
  int mConnectCount;
  DeviceOptions mDeviceOptions;
  int32_t mUserCount;
  double mTiltRequestTime;
  //! Returns current device angle in degrees between -28 and 28.
  void run();
  double elapsedSeconds();
  void deactivateUsers();

  bool mNewSkeletons;
  bool mIsSkeletonDevice;
  static std::vector<int32_t> sUserColors;
  static std::vector<int32_t> getUserColors();
  std::vector<Skeleton> mSkeletons;
  std::vector<NUI_USER_INFO> mInteractionInfo;
  INuiInteractionStream* mNuiIStream;
  DummyInteractionClient mNuiIClient;
  bool openInteractionStream();
  int mNuiStatus;
};

}


#endif
