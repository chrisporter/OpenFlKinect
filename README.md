OpenFlKinect
============

Openfl / Haxe native extension for Microsoft Kinect for Windows SDK

**To build ndll library:**

haxelib run hxcpp Build.xml

**To compile samples:**

[haxelib run] openfl build project.xml windows

Copy KinectInteraction180_32.dll from %KINECT_TOOLKIT_DIR%/bin into same directory as .exe

```bat
xcopy "%KINECT_TOOLKIT_DIR%\Redist\x86\KinectInteraction180_32.dll" "./Export/Windows/cpp/bin" /Y /C
```

## Usage

```Haxe

// Set options
d = new DeviceOptions();
d.depthEnabled = true;
d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;

// Create a Kinect references
k = new Kinect(d);
k.start();

// Add the image stream display list
addChild(k.bmDepth);

// call update each frame
addEventListener(Event.ENTER_FRAME, function(e)
{
  k.update();
});

```


## Dependencies

* Kinect for Windows SDK (v1.8) https://www.microsoft.com/en-gb/download/details.aspx?id=40278
* Kinect for Windows Developer Toolkit https://www.microsoft.com/en-us/download/details.aspx?id=40276
* Haxe and OpenFL http://www.openfl.org/documentation/setup/install-haxe/
* Visual Studio 2012 / Visual Studio 2012 Express (2010 Will not compile) http://www.microsoft.com/en-us/download/details.aspx?id=34673

## Depth Stream

![](https://lh4.googleusercontent.com/-_HtY04KcUTw/Uz2W7jbH6qI/AAAAAAAADZ4/dW_7oVNZ5y4/w303-h240-no/depth.png)


```Haxe
d = new DeviceOptions();
d.depthEnabled = true;
d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
d.userColor = false;
d.userTrackingEnabled = false

k = new Kinect(d);
k.start();

addChild(k.bmDepth);;

```

## Colour Stream

![](https://lh3.googleusercontent.com/-Glij7YoYaOg/Uz2W9FM6QNI/AAAAAAAADaM/s8deUGa8pO4/w301-h240-no/color.png)

```Haxe
d = new DeviceOptions();
d.irEnabled = false;
d.colorEnabled = true;
d.colorResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
     
k = new Kinect(d);
k.start();
tilt = k.tilt;
addChild(k.bmColor);

```


## IR Stream

![](https://lh5.googleusercontent.com/-YhAzTU-m5bA/Uz2W9CP-1YI/AAAAAAAADaU/1dGobEL_KGw/w305-h240-no/ir.png)

```Haxe
d = new DeviceOptions();
d.irEnabled = true;
d.irResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;

k = new Kinect(d);
k.start();

addChild(k.bmIr);

```

## User Tracking

![](https://lh4.googleusercontent.com/-DiTZ9UtHUp0/Uz2W97FFHmI/AAAAAAAADac/_FCOEHmQmXE/w304-h240-no/user.png)

```Haxe
d = new DeviceOptions();
d.depthEnabled = true;
d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_320x240;
d.userTrackingEnabled = true;
//d.binaryMode = true;
//d.inverted = true;
d.removeBackground = true;
d.userColor = true;

k = new Kinect(d);
k.start();
addChild(k.bmDepth);

```

## Skeleton Stream

![](https://lh4.googleusercontent.com/-7KWziKIuymA/Uz2W9ODPzmI/AAAAAAAADaQ/M9X5AxCEQCg/w303-h240-no/skeleton.png)

```Haxe
d = new DeviceOptions();
d.depthEnabled = true;
d.irEnabled = false;
d.colorEnabled = false;
d.nearModeEnabled = false;
d.skeletonTrackingEnabled = true;
d.userTrackingEnabled = true;
//d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_320x240;
d.flipped = false;

k = new Kinect(d);
k.start();


for ( i in k.skeletons )
{
    if ( i.isTracked )
    {
        k.adjustBonesToColor(i);
        
        var c = k.userColor(col);
        s.graphics.beginFill( c );
        s.graphics.lineStyle(2, c, .75);
        
        for ( j in i.joints.keys() )
        {
            var b = i.joints[j];
            s.graphics.drawCircle(b.position.x, b.position.y, 5);
            
            var start = i.joints[b.startJoint];
            s.graphics.moveTo(start.position.x, start.position.y); 
            s.graphics.lineTo(b.position.x, b.position.y);
        }
        
        bmdSkel.draw(s);
        s.graphics.endFill();
        bmdSkel.draw(s);
        
    }
    col++;
}
```

## Interactions

![](https://lh5.googleusercontent.com/-tNBRedd49Dw/Uz2W7m1CIWI/AAAAAAAADZ8/tkN5iyPK1dM/w307-h240-no/interactions.png)

```Haxe
class Navigation extends KinectRegion
addInteractiveChild(s);
s.addEventListener(TouchEvent.TOUCH_OVER, handOver);
s.addEventListener(TouchEvent.TOUCH_BEGIN, handDown);
s.addEventListener(TouchEvent.TOUCH_END, handUp);
s.addEventListener(TouchEvent.TOUCH_MOVE, handDrag);
s.addEventListener(TouchEvent.TOUCH_TAP, handTap);
```
