package openfl.kinect;
import openfl.geom.Point;
import openfl.kinect.SkeletonTransform;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end
/**
 * ...
 * @author Chris Porter
 */
class DeviceOptions
{
	var r:Dynamic;

	//private static var openflkinect_init_device_options = 
		//Lib.load ("openflkinect", "openflkinect_init_device_options", 1);
		//
	//private static var openflkinect_get_irEnabled =
		//Lib.load("openflkinect", "openflkinect_get_irEnabled", 1);
		//
	//private static var openflkinect_set_irEnabled =
		//Lib.load("openflkinect", "openflkinect_set_irEnabled", 2);
	
	public var deviceId(default, default):String;
	public var deviceIndex(default, default):Int;
	
	public var depthEnabled(default, default):Bool;
	public var colorEnabled(default, default):Bool;
    public var irEnabled(default, default):Bool;
	public var skeletonTrackingEnabled(default, default):Bool;
	public var interactionEnabled(default, default):Bool;

	public var depthResolution(default, set):ImageResolution;
	public var depthSize(default, default):Point;
	public var colorResolution(default, set):ImageResolution;
	public var colorSize(default, default):Point;
	public var irResolution(default, set):ImageResolution;
	public var irSize(default, default):Point;
	
	public var nearModeEnabled(default, default):Bool;
	public var seatedModeEnabled(default, default):Bool;
	public var userTrackingEnabled(default, default):Bool;
	public var extendedModeEnabled(default, default):Bool;
	public var mapColorToDepth(default, default):Bool;
	public var mapDepthToColor(default, default):Bool;
	
	public var binaryMode(default, default):Bool;
	public var userColor(default, default):Bool;
	public var removeBackground(default, default):Bool;
	public var inverted(default, default):Bool;
	
	public var flipped(default, default):Bool;
	public var transform(default, default):SkeletonTransform;
	
	public function new() 
	{
		deviceIndex = 0;
		deviceId = "";
		depthEnabled = true;
		skeletonTrackingEnabled = true;
		interactionEnabled = false;
		nearModeEnabled = false;
		seatedModeEnabled = false;
		userTrackingEnabled = true;
		colorEnabled = true;
		extendedModeEnabled = false;
		mapColorToDepth = false;
		irEnabled = false;
		depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_320x240;
		colorResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		irResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		binaryMode = false;
		userColor = false;
		inverted = false;
		removeBackground = false;
		mapDepthToColor = false;
		transform = SkeletonTransform.TRANSFORM_DEFAULT;	
	}
	
	public function enableSkeletonTracking(enable:Bool, seated:Bool):DeviceOptions
	{
		seatedModeEnabled = seated;
		skeletonTrackingEnabled = enable;
		return this;
	}
	
	public function set_depthResolution(resolution:ImageResolution)
	{
		depthResolution = resolution;
		
		switch ( resolution )
		{
			case ImageResolution.NUI_IMAGE_RESOLUTION_640x480:
				depthSize = new Point(640, 480);
				//userTrackingEnabled = false;
				//skeletonTrackingEnabled = false;
				//seatedModeEnabled = false;
			case ImageResolution.NUI_IMAGE_RESOLUTION_320x240:
				depthSize  = new Point(320, 240);
			case ImageResolution.NUI_IMAGE_RESOLUTION_80x60:
				depthSize = new Point(80, 60);
			default:
				depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_INVALID;
				depthSize = new Point();
				depthEnabled = false;
		}
		
		return depthResolution;
	}
	
	//http://msdn.microsoft.com/en-us/library/jj663865.aspx
	public function set_colorResolution(resolution:ImageResolution)
	{
		colorResolution = resolution;
		
		switch ( colorResolution )
		{
			case ImageResolution.NUI_IMAGE_RESOLUTION_1280x960:
				colorSize = new Point(1280, 960);
			case ImageResolution.NUI_IMAGE_RESOLUTION_640x480:
				colorSize = new Point(640, 480);
			default:
				colorResolution = ImageResolution.NUI_IMAGE_RESOLUTION_INVALID;
				colorSize = new Point();
				colorEnabled = false;
		}
		
		return colorResolution;
	}
	
	public function set_irResolution(resolution:ImageResolution)
	{
		irResolution = resolution;
		
		switch ( colorResolution )
		{
			case ImageResolution.NUI_IMAGE_RESOLUTION_640x480:
				 irSize = new Point(640, 480);
			default:
				irResolution = ImageResolution.NUI_IMAGE_RESOLUTION_INVALID;
				irSize = new Point();
				irEnabled = false;
		}
		
		return colorResolution;
	}
}
