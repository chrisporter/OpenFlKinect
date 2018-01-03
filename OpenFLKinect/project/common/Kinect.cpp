#include "Kinect.h"

using namespace openflkinect;
using namespace std;

const double kTiltRequestInterval = 1.5;

const NUI_TRANSFORM_SMOOTH_PARAMETERS kTransformNone = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
const NUI_TRANSFORM_SMOOTH_PARAMETERS kTransformDefault  = { 0.5f, 0.5f, 0.5f, 0.05f, 0.04f };
const NUI_TRANSFORM_SMOOTH_PARAMETERS kTransformSmooth = { 0.5f, 0.1f, 0.5f, 0.1f, 0.1f };
const NUI_TRANSFORM_SMOOTH_PARAMETERS kTransformVerySmooth = { 0.7f, 0.3f, 1.0f, 1.0f, 1.0f };
const NUI_TRANSFORM_SMOOTH_PARAMETERS kTransformMax = { 1.0f, 1.0f, 1.0f, 1.0f, 1.0f };
const NUI_TRANSFORM_SMOOTH_PARAMETERS kTransformParams[ 5 ] =
{ kTransformNone, kTransformDefault, kTransformSmooth, kTransformVerySmooth, kTransformMax };

void CALLBACK deviceStatus( long hr, const WCHAR *instanceName,
    const WCHAR *deviceId, void *data )
{
    cout << "status callback in effect yall " << endl;
    Kinect* kinect = reinterpret_cast<Kinect*>( data );
    if ( SUCCEEDED( hr ) )
    {
      kinect->start();
    }
    else
    {
      std::cout << "device status " << std::endl;
      kinect->error( hr );
      kinect->stop();
    }
}

Kinect::~Kinect()
{
  stop();

  if ( mSensor != 0 )
  {
    mSensor->NuiShutdown();
    mSensor->Release();
    mSensor = 0;
  }

  if ( mNuiIStream )
  {
    //mNuiIStream->Disable();
    mNuiIStream->Release();
  }
}

void Kinect::init()
{
  NuiSetDeviceStatusCallback( &deviceStatus, this );
  mNewDepthBitmap = false;
  mNewColorBitmap = false;
  mNewIrBitmap = false;
  mNewSkeletons = false;
  mCapture = false;
  mDepthStreamHandle = 0;
  mColorStreamHandle = 0;
  mIrStreamHandle = 0;
  mIsSkeletonDevice = false;

  mFrameRateColor = 0.0;
  mFrameRateDepth = 0.0;
  mFrameRateIR = 0.0;
  mFrameRateSkeleton = 0.0;
  mReadTimeDepth = 0.0;
  mReadTimeSkeleton = 0.0;
  mReadTimeColor = 0.0;
  mReadTimeIR = 0.0;
  mNuiStatus = E_NUI_DEVICE_NOT_READY;
  mUserCount = 0;
  mNuiIStream = 0;
  deactivateUsers();
  if ( mDeviceOptions.deviceIndex >= 0 )
  {
    mDeviceOptions.deviceIndex =
      Utils::clamp<int32_t>( mDeviceOptions.deviceIndex, 0,
         max(getDeviceCount()-1, 0));
  }
}

DeviceOptions& Kinect::getDeviceOptions()
{
  return mDeviceOptions;
}

DeviceOptions& Kinect::setDeviceOptions(const DeviceOptions& val)
{
  mDeviceOptions = val;
  return mDeviceOptions;
}

bool Kinect::isCapturing()
{
  return mCapture;
}

void Kinect::start()
{
  if ( mCapture == true )
  {
    return;
  }

  init();
  if ( createDevice() == false )
  {
    return;
  }
  if ( initStreams() == false )
  {
    mNuiStatus = mSensor->NuiStatus();
    return;
  }

  mNuiStatus = mSensor->NuiStatus();
  // Start thread
  mCapture = true;
  mThread = std::shared_ptr<std::thread>(
      new std::thread( std::bind( &Kinect::run, this )));
}

bool Kinect::createDevice()
{
  long hr = S_OK;

  if ( mDeviceOptions.deviceId.length() > 0 )
  {
    _bstr_t id = mDeviceOptions.deviceId.c_str();
    hr = NuiCreateSensorById( id, &mSensor );
    if ( FAILED( hr ) )
    {
      cout << "Unable to create device instance by deviceID " <<
          mDeviceOptions.deviceId << endl;
      error( hr );
      return false;
    }
  }
  else if ( mDeviceOptions.deviceIndex >= 0 )
  {
    hr = NuiCreateSensorByIndex( mDeviceOptions.deviceIndex, &mSensor );
    if ( FAILED( hr ) )
    {
      cout << "Unable to create device instance by index " <<
        mDeviceOptions.deviceIndex << " " << mSensor << endl;
      error(hr);
      return false;
    }
  }
  else
  {
    cout << "Invalid device ID or index" << endl;
    return false;
  }

  // Check device
  hr = mSensor != 0 ? mSensor->NuiStatus() : E_NUI_NOTCONNECTED;
  if ( hr == E_NUI_NOTCONNECTED )
  {
    error( hr );
    return false;
  }

  // Get device name and index
  if ( mSensor != 0 )
  {
    mDeviceOptions.deviceIndex = mSensor->NuiInstanceIndex();
    BSTR id = ::SysAllocString( mSensor->NuiDeviceConnectionId() );
    _bstr_t idStr( id );
    if ( idStr.length() > 0 )
    {
      mDeviceOptions.deviceId = std::string( idStr);
    }
    ::SysFreeString( id );
  }

  return true;
}

bool Kinect::initStreams()
{
  long hr = S_OK;
  unsigned long flags;
  if ( !mDeviceOptions.userTrackingEnabled )
  {
    flags = NUI_INITIALIZE_FLAG_USES_DEPTH;
  }
  else
  {
    flags = NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX;
  }
  if ( mDeviceOptions.skeletonTrackingEnabled )
  {
    flags |= NUI_INITIALIZE_FLAG_USES_SKELETON;
    if ( mDeviceOptions.nearModeEnabled )
    {
      flags |= NUI_SKELETON_TRACKING_FLAG_ENABLE_IN_NEAR_RANGE;
    }
  }


  if ( mDeviceOptions.colorEnabled | mDeviceOptions.irEnabled )
  {
    flags |= NUI_INITIALIZE_FLAG_USES_COLOR;
  }

  hr = mSensor->NuiInitialize( flags );
  if ( FAILED( hr ) )
  {
    cout << "Unable to initialize device " << mDeviceOptions.deviceId
      << ":";
    error( hr );
    return false;
  }

  // Skeletons are only supported on the first device
  if ( mDeviceOptions.skeletonTrackingEnabled
      && HasSkeletalEngine( mSensor ) )
  {
    flags = NUI_SKELETON_TRACKING_FLAG_ENABLE_IN_NEAR_RANGE;
    if ( mDeviceOptions.seatedModeEnabled )
    {
      flags |= NUI_SKELETON_TRACKING_FLAG_ENABLE_SEATED_SUPPORT;
    }
    hr = mSensor->NuiSkeletonTrackingEnable( 0, flags );
    if ( FAILED( hr ) )
    {
      cout << "Unable to initialize skeleton tracking for device "
        << mDeviceOptions.deviceId;
      error( hr );
      return false;
    }
    mIsSkeletonDevice = true;
  }
  else
  {
    mDeviceOptions.skeletonTrackingEnabled = false;
  }

  // Initialize depth image
  if ( mDeviceOptions.depthResolution
      != NUI_IMAGE_RESOLUTION::NUI_IMAGE_RESOLUTION_INVALID )
  {
    if ( mDeviceOptions.depthEnabled && !openDepthStream() )
    {
      return false;
    }
    mDepthPixels = new int[mDeviceOptions.numDepthPixels()];
    // Set image stream flags
    if ( mDeviceOptions.depthEnabled )
    unsigned long flags = NUI_IMAGE_STREAM_FRAME_LIMIT_MAXIMUM;
    if ( mDeviceOptions.nearModeEnabled )
    {
        flags |= NUI_IMAGE_STREAM_FLAG_ENABLE_NEAR_MODE |
          NUI_IMAGE_STREAM_FLAG_DISTINCT_OVERFLOW_DEPTH_VALUES;
    }
    long hr = mSensor->NuiImageStreamSetImageFrameFlags(
        mDepthStreamHandle, flags );
    if ( FAILED( hr ) )
    {
      cout << "Unable to set image frame flags: " << endl;
      error( hr );
    }
  }

  if ( mDeviceOptions.colorResolution != NUI_IMAGE_RESOLUTION_INVALID )
  {
    if ( mDeviceOptions.colorEnabled && openColorStream() == false )
    {
      return false;
    }
    mColorPixels = new int[ mDeviceOptions.numColorPixels() ];
  }

  if ( mDeviceOptions.irResolution != NUI_IMAGE_RESOLUTION_INVALID )
  {
    if ( mDeviceOptions.irEnabled && openIrStream() == false )
    {
      return false;
    }
    mIrPixels = new int[ mDeviceOptions.numIrPixels() ];
  }

  openInteractionStream();
  return true;
}

bool Kinect::openDepthStream()
{
  if ( mSensor != 0)
  {
    NUI_IMAGE_TYPE imageType =
      //mDeviceOptions.depthResolution != NUI_IMAGE_RESOLUTION_640x480 &&
      HasSkeletalEngine( mSensor ) && mDeviceOptions.userTrackingEnabled ? NUI_IMAGE_TYPE_DEPTH_AND_PLAYER_INDEX :
      NUI_IMAGE_TYPE_DEPTH;
    long hr = mSensor->NuiImageStreamOpen(imageType,mDeviceOptions.depthResolution, 0, 2,
        NULL, &mDepthStreamHandle);
    if ( FAILED( hr ) )
    {
      cout <<  "Unable to open depth image stream: " << endl;
      error( hr );
      stop();
      return false;
    }
  }
  return true;
}

bool Kinect::openColorStream()
{
  if ( mSensor != 0 )
  {
    long hr = mSensor->NuiImageStreamOpen( NUI_IMAGE_TYPE_COLOR,
        mDeviceOptions.colorResolution,
        0, 2, 0, &mColorStreamHandle );
    if ( FAILED( hr ) )
    {
      cout << "Unable to open color image stream: " << endl;
      error( hr );
      stop();
      return false;
    }
  }
  return true;
}

bool Kinect::openIrStream()
{
  if ( mSensor != 0 )
  {
    long hr = mSensor->NuiImageStreamOpen( NUI_IMAGE_TYPE_COLOR_INFRARED,
        mDeviceOptions.irResolution,
        0, 2, 0, &mIrStreamHandle );
    if ( FAILED( hr ) )
    {
      cout << "Unable to open IR image stream: " << endl;
      error( hr );
      stop();
      return false;
    }
  }
  return true;
}

bool Kinect::openInteractionStream()
{

  if ( mDeviceOptions.interactionEnabled )
  {
    long hr = NuiCreateInteractionStream(mSensor,(INuiInteractionClient *)&mNuiIClient, &mNuiIStream);
    if( FAILED( hr ) )
    {
      error(hr);
      return false;
    }

    hr = mNuiIStream->Enable(NULL);
    if( FAILED( hr ) )
    {
      cout << "Could not open Interation stream" << endl;
      error( hr );
      return false;
    }
    return true;
  }
  return false;
}

void Kinect::run()
{
  while ( mCapture )
  {
    if ( mSensor != 0 )
    {
      double time = elapsedSeconds();

      if ( mDepthStreamHandle != 0 ) // Depth Img
      {
        _NUI_IMAGE_FRAME imageFrame;
        long hr = mSensor->NuiImageStreamGetNextFrame(
                mDepthStreamHandle, WAIT_TIME, &imageFrame );

        INuiFrameTexture * pTexture = NULL;
        if ( mDeviceOptions.interactionEnabled )
        {
            BOOL bNearMode = mDeviceOptions.nearModeEnabled;
            hr = mSensor->NuiImageFrameGetDepthImagePixelFrameTexture(mDepthStreamHandle, &imageFrame,
                &bNearMode, &pTexture);
        }
        if ( FAILED( hr ) )
        {
          error( hr );
        }
        else
        {
          INuiFrameTexture * texture = imageFrame.pFrameTexture;
          _NUI_LOCKED_RECT lockedRect;

          if ( mDeviceOptions.interactionEnabled )
          {
            hr = pTexture->LockRect(0, &lockedRect, NULL, 0 );
          }
          else
          {
            hr = texture->LockRect( 0, &lockedRect, 0, 0 );
          }

          if ( FAILED( hr ) )
          {
            error( hr );
          }

          if ( lockedRect.Pitch != 0 )
          {
            if ( mDeviceOptions.interactionEnabled )
            {
              HRESULT hr = mNuiIStream->ProcessDepth(
                  (UINT)lockedRect.size, (BYTE*)lockedRect.pBits,
                  (LARGE_INTEGER)imageFrame.liTimeStamp);
              if ( FAILED(hr ) )
              {
                error(hr);
              }
            }

            if ( mDeviceOptions.interactionEnabled )
            {
              pixelToDepthBitmap( (NUI_DEPTH_IMAGE_PIXEL *) lockedRect.pBits );
            }
            else
            {
              cout << lockedRect.pBits << endl;
              pixelToDepthBitmap( (uint16_t*)lockedRect.pBits );
            }
          }

          hr = mSensor->NuiImageStreamReleaseFrame(mDepthStreamHandle, &imageFrame);
          if ( FAILED ( hr ) )
          {
            error(hr);
          }

          mFrameRateDepth = (float)( 1.0 / (time - mReadTimeDepth) );
          mReadTimeDepth = time;

          mUserCount = 0;
          for ( uint32_t i = 0; i < NUI_SKELETON_COUNT; ++i )
          {
            if ( mActiveUsers[ i ] )
            {
              mUserCount++;
            }
          }

          mNewDepthBitmap = true;
        }
      }

      if ( mDeviceOptions.colorEnabled && mColorStreamHandle != 0
          && mNewColorBitmap == false )
      {
        _NUI_IMAGE_FRAME imageFrame;

        long hr = mSensor->NuiImageStreamGetNextFrame(
            mColorStreamHandle, WAIT_TIME, &imageFrame);

        if ( FAILED( hr ) )
        {
          error(hr);
        }
        else
        {
          INuiFrameTexture* texture = imageFrame.pFrameTexture;
          _NUI_LOCKED_RECT lockedRect;
          hr = texture->LockRect( 0, &lockedRect, 0, 0 );
          if ( FAILED( hr ) )
          {
            error( hr );
          }
          if ( lockedRect.Pitch != 0 )
          {
            if ( mDeviceOptions.mapColorToDepth )
            {

            }
            else
            {
              pixelToColorBitmap( (uint8_t*)lockedRect.pBits );
            }
          }
          else
          {
            cout << "Invalid buffer length received." << endl;
          }

          hr = mSensor->NuiImageStreamReleaseFrame( mColorStreamHandle,
              &imageFrame );

          if ( FAILED(hr ) )
          {
            error( hr );
          }

          mFrameRateColor = (float)( 1.0 / (time - mReadTimeColor) );
          mReadTimeColor = time;

          mNewColorBitmap = true;

        }

      }

      if ( mDeviceOptions.irEnabled && mIrPixels != 0 &&
          mNewIrBitmap == false)
      {
        _NUI_IMAGE_FRAME imageFrame;
        long hr = mSensor->NuiImageStreamGetNextFrame(
            mIrStreamHandle, WAIT_TIME, &imageFrame );
        if ( FAILED( hr ) )
        {
          error( hr );
        }
        else
        {
          INuiFrameTexture * texture = imageFrame.pFrameTexture;
          _NUI_LOCKED_RECT lockedRect;
          hr = texture->LockRect( 0, &lockedRect, 0, 0 );
          if ( FAILED( hr ) )
          {
            error( hr );
          }

          if ( lockedRect.Pitch != 0 )
          {
            pixelToIrBitmap( (uint16_t*)lockedRect.pBits );
          }
          else
          {
            cout << "Invalid buffer length received." << endl;
          }

          hr = mSensor->NuiImageStreamReleaseFrame( mIrStreamHandle,
              &imageFrame );
          if ( FAILED( hr ) )
          {
            error( hr );
          }

          mFrameRateIR = (float)( 1.0 / ( time - mReadTimeIR ) );
          mReadTimeIR = time;

          mNewIrBitmap = true;
        }
      }

      if ( mDeviceOptions.skeletonTrackingEnabled
          && mIsSkeletonDevice && !mNewSkeletons )
      {
        _NUI_SKELETON_FRAME skeletonFrame;
        long hr = mSensor->NuiSkeletonGetNextFrame( WAIT_TIME,
            &skeletonFrame );
        if ( FAILED( hr ) )
        {
          //error( hr );
        }
        else
        {

          if ( mDeviceOptions.interactionEnabled )
          {
            Vector4 v;
            mSensor->NuiAccelerometerGetCurrentReading(&v);
            hr = mNuiIStream->ProcessSkeleton(NUI_SKELETON_COUNT, skeletonFrame.SkeletonData,
              &v, skeletonFrame.liTimeStamp);
            if ( FAILED( hr ) )
            {
              error( hr );
            }
          }

          bool foundSkeleton = false;
          for ( int32_t i = 0; i < NUI_SKELETON_COUNT; ++i )
          {
            mSkeletons.at( i ).clear();
            NUI_SKELETON_TRACKING_STATE trackingState =
              skeletonFrame.SkeletonData[ i ].eTrackingState;

            if ( trackingState == NUI_SKELETON_TRACKED ||
                trackingState == NUI_SKELETON_POSITION_ONLY )
            {
              if ( !foundSkeleton )
              {
                _NUI_TRANSFORM_SMOOTH_PARAMETERS transform =
                  kTransformParams[ mDeviceOptions.transform ];
                  hr = mSensor->NuiTransformSmooth( &skeletonFrame,
                      &transform );
                  if ( FAILED( hr ) )
                  {
                      error( hr );
                  }
                  foundSkeleton = true;
              }

              if ( mDeviceOptions.flipped )
              {
                ( skeletonFrame.SkeletonData + i )->Position.x *= -1.0f;
                for ( int32_t j = 0; j < (int32_t)NUI_SKELETON_POSITION_COUNT; ++j )
                {
                  ( skeletonFrame.SkeletonData + i )->SkeletonPositions[ j ].x *= -1.0f;
                }
              }

              _NUI_SKELETON_BONE_ORIENTATION bones[ NUI_SKELETON_POSITION_COUNT ];
              hr = NuiSkeletonCalculateBoneOrientations( skeletonFrame.SkeletonData + i, bones );
              if ( FAILED( hr ) )
              {
                error( hr );
              }

              for ( int32_t j = 0; j < (int32_t)NUI_SKELETON_POSITION_COUNT; ++j )
              {
                Bone bone( *( ( skeletonFrame.SkeletonData + i )->SkeletonPositions + j ), *( bones + j ) );
                ( mSkeletons.begin() + i )->insert( std::pair<JointName, Bone>( (JointName)j, bone ) );
              }

            }

          }
          mFrameRateSkeleton = (float)( 1.0 / ( time - mReadTimeSkeleton ) );
          mReadTimeSkeleton = time;

          mNewSkeletons = true;
        }

      }

      if ( mDeviceOptions.interactionEnabled && mNuiIStream != 0
          && mNewInteractionInfo == false )
      {
        NUI_INTERACTION_FRAME interactionFrame;
        long hr = mNuiIStream->GetNextFrame( 0, &interactionFrame );
        if( FAILED( hr  ) )
        {
            error(hr);
        }
        else
        {
          int trackingID = 0;
          int event = 0;
          mInteractionInfo.clear();

          for ( int i=0; i<NUI_SKELETON_COUNT; i++ )
          {
              if ( interactionFrame.UserInfos[i].SkeletonTrackingId > 0 )
              {
                  mInteractionInfo.push_back(interactionFrame.UserInfos[i]);
              }
          }
          mNewInteractionInfo = true;
        }
      }

      Sleep(8);
    }
  }
  return;
}

int32_t Kinect::getDeviceCount()
{
    int32_t deviceCount = 0;
    NuiGetSensorCount( &deviceCount );
    return deviceCount;
}

void Kinect::stop()
{
  cout << "stop" << endl;
  mCapture = false;
  if ( mThread )
  {
    mThread->join();
    mThread.reset();
  }
}

int* Kinect::depthPixels() const
{
  return mDepthPixels;
}

int* Kinect::colorPixels() const
{
  return mColorPixels;
}

int* Kinect::irPixels() const
{
  return mIrPixels;
}

void Kinect::pixelToDepthBitmap( uint16_t *buffer )
{
  int32_t height = mDeviceOptions.depthSize.y;
  int32_t width = mDeviceOptions.depthSize.x;
  int32_t size = width * height * 6; // 6 is 3 color channels * sizeof( uint16_t )

  int* pixelRun  = mDepthPixels;
  for ( int32_t y = 0; y < height; y++ )
  {
    for ( int32_t x = 0; x < width; x++ )
    {
      int32_t pix = mDeviceOptions.flipped ?
        (y * width) + (width -1  -x) :
        y * width + x;
      Pixel pixel = shortToPixel( buffer[pix] );
      int num = // (pixel.a << 24) +
          (pixel.r << 16)
        + (pixel.g << 8)
        +  pixel.b;
      *pixelRun++ = num;
    }
  }
}

void Kinect::pixelToDepthBitmap( NUI_DEPTH_IMAGE_PIXEL * buffer )
{
  int32_t height = mDeviceOptions.depthSize.y;
  int32_t width = mDeviceOptions.depthSize.x;
  int32_t size = width * height * 6; // 6 is 3 color channels * sizeof( uint16_t )

  int* pixelRun  = mDepthPixels;
  for ( int32_t y = 0; y < height; y++ )
  {
    for ( int32_t x = 0; x < width; x++ )
    {
      int32_t pix = mDeviceOptions.flipped ?
          y * width + (width - x) :
          y * width + x;
      Pixel pixel = shortToPixel(buffer[pix].depth* 8) ;
       int num = // (pixel.a << 24) +
          (pixel.r << 16)
        + (pixel.g << 8)
        +  pixel.b;
      *pixelRun++ = num;
    }
  }
}

//http://stackoverflow.com/questions/13193607/flipping-depth-frame-received-from-kinect
Pixel Kinect::shortToPixel( uint16_t value )
{
  uint16_t depth = value >> 3; // mms
  unsigned char intensity = depth == 0 || depth > 4095 ?
    0 : 255 - (unsigned char)(((float)depth / 4095.0f) * 255.0f);
  uint16_t user = value & 7;
  Pixel pixel;

  // Mark user active
  if ( user > 0 && user < 7 )
  {
    mActiveUsers[ user - 1 ] = true;
  }
  // Binary mode
  if ( mDeviceOptions.binaryMode )
  {
    // Set black and white values
    uint16_t backgroundColor = mDeviceOptions.inverted ? 0xFFFF : 0;
    uint16_t userColor = mDeviceOptions.inverted ? 0 : 0xFFFF;

    // Set color
    if ( user == 0 || user == 7 )
    {
      pixel.r = pixel.g = pixel.b = backgroundColor;
    }
    else
    {
      pixel.r = pixel.g = pixel.b = userColor;
    }
  }
  else if ( mDeviceOptions.userColor )
  {
    // Colorize each user
    switch ( user )
    {
      case 0:
        if ( mDeviceOptions.removeBackground == false )
        {
          pixel.r = intensity / 4;
          pixel.g = pixel.r;
          pixel.b = pixel.g;
        }
        break;
      case 1:
        pixel.r = intensity;
        break;
      case 2:
        pixel.r = intensity;
        pixel.g = intensity;
        break;
      case 3:
        pixel.r = intensity;
        pixel.b = intensity;
        break;
      case 4:
        pixel.r = intensity;
        pixel.g = intensity / 2;
        break;
      case 5:
        pixel.r = intensity;
        pixel.b = intensity / 2;
        break;
      case 6:
        pixel.r = intensity;
        pixel.g = intensity / 2;
        pixel.b = pixel.g;
        break;
      case 7:
        if ( mDeviceOptions.removeBackground == false )
        {
          pixel.r = 0xFFFF - ( intensity / 2 );
          pixel.g = pixel.r;
          pixel.b = pixel.g;
        }
      }
  }
  else
  {
    // Set greyscale value
    if ( user == 0 || user == 7 )
    {
      pixel.r = mDeviceOptions.removeBackground ? 0 : intensity;
    }
    else
    {
      pixel.r = intensity;
    }
    pixel.g = pixel.r;
    pixel.b = pixel.g;
  }

  // Invert image
  //pixel.r = 0xFFFF - pixel.r;
  //pixel.g = 0xFFFF - pixel.g;
  //pixel.b = 0xFFFF - pixel.b;

  return pixel;
}

void Kinect::pixelToColorBitmap( uint8_t *buffer )
{
  int32_t height = mDeviceOptions.colorSize.y;
  int32_t width = mDeviceOptions.colorSize.x;
  int32_t size = mDeviceOptions.numColorPixels() * 3;
  int32_t colPos = 0;

  for ( int32_t y = 0; y < height; y++ )
  {
    for ( int32_t x = 0; x < width; x++ )
    {
      int32_t pix = mDeviceOptions.flipped ?
        (y * width) + (width -1  -x) :
        y * width + x;
      pix *= 4;
      int32_t col =
        ( buffer[ pix + 2 ] << 16)
        | ( buffer[pix + 1 ] << 8)
        |  buffer[ pix ];

      mColorPixels[ colPos++ ] = col;
    }
  }

}

void Kinect::pixelToIrBitmap( uint16_t *buffer )
{
  int32_t height = mDeviceOptions.irSize.y;
  int32_t width = mDeviceOptions.irSize.x;

  int* pixelRun  = mIrPixels;
  for ( int32_t y = 0; y < height; y++ )
  {
    for ( int32_t x = 0; x < width; x++ )
    {
      int32_t pix = mDeviceOptions.flipped ?
        (y * width) + (width -1  -x) :
        y * width + x;
      Pixel pixel;
      pixel.r = pixel.g = pixel.b = buffer[pix] >> 8;
      int num = // (pixel.a << 24) +
          (pixel.r << 16)
        + (pixel.g << 8)
        +  pixel.b;
      *pixelRun++ = num;
    }
  }
}

void Kinect::update()
{
  if ( mCapture == false && ++mConnectCount%90 == 0 )
  {
    start();
    return;
  }

  if ( mNewDepthBitmap )
  {
    //mSignalDepth( mDepthBitmap, mDeviceOptions );
    mNewDepthBitmap = false;
  }
  if ( mNewSkeletons )
  {
    //mSignalSkeleton( mSkeletons, mDeviceOptions );
    mNewSkeletons = false;
  }
  if ( mNewColorBitmap )
  {
    //mSignalColor( mColorBitmap, mDeviceOptions );
    mNewColorBitmap = false;
  }

  if ( mNewIrBitmap )
  {
    mNewIrBitmap = false;
  }

  if ( mNewInteractionInfo )
  {
    mNewInteractionInfo = false;
  }
}

void Kinect::error( long hr )
{
    if ( !mVerbose )
    {
      return;
    }
    switch ( hr )
    {
      case E_POINTER:
          cout << ( "Bad pointer." ) << endl;
          break;
      case E_INVALIDARG:
          cout << ( "Invalid argument." ) << endl;
          break;
      case E_NUI_DEVICE_NOT_READY:
          mNuiStatus = hr;
          cout << ( "Device not ready." ) << endl;
          break;
      case E_NUI_FEATURE_NOT_INITIALIZED:
          cout << ( "Feature not initialized." ) << endl;
          break;
      case E_NUI_NOTCONNECTED:
          mNuiStatus = hr;
          cout << ( "Unable to connect to device." ) << endl;
          break;
      case E_FAIL:
          cout << ( "Attempt failed." ) << endl;
          break;
      case E_NUI_IMAGE_STREAM_IN_USE:
          mNuiStatus = hr;
          cout << ( "Image stream already in use." ) << endl;
          break;
      case E_NUI_FRAME_NO_DATA:
          cout << ( "No frame data available" ) << endl;
          break;
      case E_OUTOFMEMORY:
          cout << ( "Out of memory (maximum number of Kinect devices may have been reached)." ) << endl;
          break;
      case ERROR_TOO_MANY_CMDS:
          cout << ( "Too many commands sent. Angle change requests must be made at least 1.5s apart." ) << endl;
          break;
      case ERROR_RETRY:
          cout << ( "Device is busy.  Retry in a moment." ) << endl;
          break;
      case S_FALSE:
          cout << ( "Data not available." ) << endl;
      case S_OK:
          break;
      default:
          cout << "Unknown error (Code " << hr << ")"  << endl;
    }
}

void Kinect::trace( const string& message )
{
  if ( mVerbose )
  {
    cout << message << endl;
  }
}

float Kinect::depthFrameRate()
{
  return mFrameRateDepth;
}

float Kinect::colorFrameRate()
{
  return mFrameRateColor;
}

float Kinect::irFrameRate()
{
  return mFrameRateIR;
}

float Kinect::skeletonFrameRate()
{
  return mFrameRateSkeleton;
}

double Kinect::elapsedSeconds()
{
  return GetTickCount() / 1000.0;
}

int32_t Kinect::getTilt()
{
  long degrees = 0L;
  if ( mCapture && mSensor != 0 )
  {
    long hr = mSensor->NuiCameraElevationGetAngle( &degrees );
    if ( FAILED( hr ) )
    {
      cout << "Unable to retrieve device angle " << endl;
      error( hr );
    }
  }
  return (int32_t)degrees;
}

void Kinect::setTilt( int32_t degrees )
{
  double elapsed = elapsedSeconds();
  if ( mCapture && mSensor != 0 &&
      elapsed - mTiltRequestTime > kTiltRequestInterval )
  {
    degrees = Utils::clamp<int32_t>( degrees, -MAXIMUM_TILT_ANGLE,
                                    MAXIMUM_TILT_ANGLE);
    cout << degrees << endl;
    long hr = mSensor->NuiCameraElevationSetAngle( degrees );
    if ( FAILED(hr) )
    {
      cout << "unable to change device angle: " << endl;
      error( hr );
    }
    mTiltRequestTime = elapsed;
  }
}

int32_t Kinect::getUserCount()
{
  return mDeviceOptions.depthEnabled ? mUserCount : 0;
}

void Kinect::deactivateUsers()
{
  for ( uint32_t i = 0; i < NUI_SKELETON_COUNT; ++ i )
  {
    mActiveUsers[ i ] = false;
  }
}

vector<int32_t> Kinect::sUserColors = getUserColors();

int32_t Kinect::getUserColor( uint32_t id )
{
  return sUserColors.at( Utils::clamp<int32_t>(id, 0, 5 ) );
}

vector<int32_t> Kinect::getUserColors()
{
  if ( sUserColors.size() == NUI_SKELETON_COUNT )
  {
    return sUserColors;
  }

  vector<int32_t> colors;
  colors.push_back( 0x00FFFF );
  colors.push_back( 0x0000FF );
  colors.push_back( 0x00FF00 );
  colors.push_back( 0x007FFF );
  colors.push_back( 0x00FF7F );
  colors.push_back( 0x007F7F );
  return colors;
}

Vec2i Kinect::getSkeletonDepthPos( const Vec3f& position )
{
  float x;
  float y;
  Vector4 pos;
  pos.x = position.x;
  pos.y = position.y;
  pos.z = position.z;
  pos.w = 1.0f;
  NuiTransformSkeletonToDepthImage( pos, &x, &y,
      mDeviceOptions.depthResolution );
  return Vec2i( (int32_t)x, (int32_t)y );
}

Vec2i Kinect::getSkeletonColorPos( const Vec3f& position )
{
  float x;
  float y;
  Vector4 pos;
  pos.x = position.x;
  pos.y = position.y;
  pos.z = position.z;
  pos.w = 1.0f;
  NuiTransformSkeletonToDepthImage( pos, &x, &y,
      mDeviceOptions.colorResolution );
  return Vec2i( x, y );
}

Vec2i Kinect::getColorDepthPos( const Vec2i& v )
{
  long x;
  long y;
  int pixel = mDepthPixels[ (int)v.y *
    (int)mDeviceOptions.depthSize.x + (int)v.x ] >> 16;
  mSensor->NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution(
      mDeviceOptions.colorResolution, mDeviceOptions.depthResolution,
      0, v.x, v.y, pixel, &x, &y );
  return Vec2i( x, y );
}

std::vector<Skeleton> Kinect::skeletons()
{
  return mSkeletons;
}

std::vector<NUI_USER_INFO> Kinect::interactionInfo()
{
  return mInteractionInfo;
}

int Kinect::nuiStatus()
{
  return mNuiStatus;
}
