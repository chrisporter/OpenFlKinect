package openfl.kinect;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Vector3D;
import openfl.kinect.interactions.UserInfo;
#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import openfl.geom.Point;

/**
 * ...
 * @author Chris Porter
 */
class Kinect
{
	var r:Dynamic;
	
	static inline var MAX_DEVICE_COUNT = 8;
	static inline var NUI_SKELETON_COUNT = 6;
	
	public var deviceOptions(default, default):DeviceOptions;
	public var depthFrameRate(get, null):Int;
	public var skeletonFrameRate(default, null):Int;
	public var colorFrameRate(get, null):Int;
	public var irFrameRate(get, null):Int;
	
	public var tilt(get, set):Int;
	public var userCount(get, null):Int;
	
	public var isCapturing(get, null):Bool;
	
	private var depthPixels:Array<Int>;
	private var bmdDepth:BitmapData;
	public var bmDepth(default, default):Bitmap;
		
	private var colorPixels:Array<Int>;
	private var bmdColor:BitmapData;
	public var bmColor(default, default):Bitmap;
	
	private var irPixels:Array<Int>;
	private var bmdIr:BitmapData;
	public var bmIr(default, default):Bitmap;
	public var skeletons(default, null):Array<Skeleton>;
	public var userInfos(default, null):Array<UserInfo>;
	public var status(get, null):KinectStatus;
	

	private static var openflkinect_init = 
		Lib.load ("openflkinect", "openflkinect_init", 1);
	
	public function new(opts:DeviceOptions) 
	{
		deviceOptions = opts;
		r = openflkinect_init(deviceOptions);
		
		if ( opts.depthEnabled )
		{
			depthPixels = new Array<Int>();
			depthPixels[ Std.int(deviceOptions.depthSize.x * deviceOptions.depthSize.y)] = 0;
			bmdDepth = new BitmapData(Std.int(deviceOptions.depthSize.x),
				Std.int(deviceOptions.depthSize.y), false);
			bmdDepth.fillRect(bmdDepth.rect, 0);			
			bmDepth = new Bitmap(bmdDepth);
		}
		else
		{
			bmDepth = new Bitmap();
		}
		
		if ( opts.colorEnabled )
		{
			colorPixels = new Array<Int>();
			colorPixels[ Std.int(deviceOptions.colorSize.x * deviceOptions.colorSize.y)] = 0;
			bmdColor = new BitmapData(Std.int(deviceOptions.colorSize.x),
				Std.int(deviceOptions.colorSize.y), false);
			bmdColor.fillRect(bmdColor.rect, 0);
			bmColor = new Bitmap(bmdColor);
		}
		else
		{
			bmColor = new Bitmap();
		}
		
		if ( opts.irEnabled )
		{
			irPixels = new Array<Int>();
			irPixels[ Std.int(deviceOptions.irSize.x * deviceOptions.irSize.y)] = 0;
			bmdIr = new BitmapData(Std.int(deviceOptions.irSize.x),
				Std.int(deviceOptions.irSize.y), false);
			bmdIr.fillRect(bmdIr.rect, 0);
			bmIr = new Bitmap(bmdIr);
		}
		else
		{
			bmIr = new Bitmap();
		}
		
		skeletons = new Array<Skeleton>();
		for ( i in 0...NUI_SKELETON_COUNT) 
		{
			skeletons.push( new Skeleton() );
		}
		
		userInfos = new Array<UserInfo>();
		for ( i in 0...NUI_SKELETON_COUNT )
		{
			userInfos.push( new UserInfo() );
		}
		
		status = KinectStatus.None;
	}
	
	private static var openflkinect_start = 
		Lib.load ("openflkinect", "openflkinect_start", 1);
	
	public function start()
	{
		openflkinect_start(r);
	}
	
	private static var openflkinect_update = 
		Lib.load ("openflkinect", "openflkinect_update", 1);
		
	private static var openflkinect_update_depth_pixels = 
		Lib.load ("openflkinect", "openflkinect_update_depth_pixels", 2);
		
	private static var openflkinect_update_color_pixels = 
		Lib.load ("openflkinect", "openflkinect_update_color_pixels", 2);
		
	private static var openflkinect_update_ir_pixels = 
		Lib.load ("openflkinect", "openflkinect_update_ir_pixels", 2);
		
	private static var openflkinect_update_skeletons = 
		Lib.load ("openflkinect", "openflkinect_update_skeletons", 1);
		
	private static var openflkinect_update_interactions = 
		Lib.load ("openflkinect", "openflkinect_update_interactions", 1);
	
	public function update()
	{
		openflkinect_update(r);
		if ( deviceOptions.interactionEnabled )
		{
			var users:Array<Dynamic> = openflkinect_update_interactions(r);
			
			for ( i in 0...userInfos.length)
			{
				userInfos[i].skeletonTrackingID = 0;
			}
			
			for ( i in 0...users.length ) 
			{
				userInfos[i].parse(users[i]);
			}
			return;
		}

		if ( deviceOptions.depthEnabled )
		{
			openflkinect_update_depth_pixels(r, depthPixels);
			bmdDepth.setVector(bmdDepth.rect, depthPixels);
		}
		
		if ( deviceOptions.colorEnabled )
		{
			openflkinect_update_color_pixels(r, colorPixels);
			bmdColor.setVector(bmdColor.rect, colorPixels);
		}
		
		if ( deviceOptions.irEnabled )
		{
			openflkinect_update_ir_pixels(r, irPixels);
			bmdIr.setVector(bmdIr.rect, irPixels);
		}
		
		if ( deviceOptions.skeletonTrackingEnabled )
		{
			var skels:Array<Dynamic> = openflkinect_update_skeletons(r);
			for ( i in 0...skels.length )
			{
				if ( skels[i].isTracked )
				{
					skeletons[i].parse(skels[i]);
				}
			}
		}
	}
	
	public function stop()
	{
		
	}
	
	private static var openflkinect_get_user_col = 
	Lib.load ("openflkinect", "openflkinect_get_user_col", 2);
	public function userColor(userID)
	{
		return openflkinect_get_user_col(r, userID);
	}
	
	//Returns depth value as 0.0 - 1.0 float for pixel at \a pos.
	public function getDepthAt( p:Point )
	{
		var depthNorm = 0.0;
		if ( deviceOptions.depthEnabled )
		{
			var r = bmDepth.bitmapData.getPixel( Std.int(p.x), Std.int(p.y) ) >> 16;
			//var depth = 0x10000 - r;
			//depth = depth << 2;
			depthNorm = cast(r, Float) / 255.0;
			//depthNorm = 1.0 - cast(depth, Float) / 65535.0;
		}
		return depthNorm;
	}
	
	private static var openflkinect_ir_frame_rate = 
		Lib.load ("openflkinect", "openflkinect_ir_frame_rate", 1);
	private function get_irFrameRate()
	{
		var ret:Float = openflkinect_ir_frame_rate(r);
		return Std.int(ret);
	}
	
	private static var openflkinect_depth_frame_rate = 
		Lib.load ("openflkinect", "openflkinect_depth_frame_rate", 1);
	private function get_depthFrameRate()
	{
		var ret:Float = openflkinect_depth_frame_rate(r);
		return Std.int(ret);
	}
	
	private static var openflkinect_color_frame_rate = 
		Lib.load ("openflkinect", "openflkinect_color_frame_rate", 1);
	private function get_colorFrameRate()
	{
		var ret:Float = openflkinect_color_frame_rate(r);
		return Std.int(ret);
	}
	
	private static var openflkinect_get_tilt = 
		Lib.load ("openflkinect", "openflkinect_get_tilt", 1);
	private function get_tilt()
	{
		return openflkinect_get_tilt(r);
	}
	
	private static var openflkinect_set_tilt = 
		Lib.load ("openflkinect", "openflkinect_set_tilt", 2);
	private function set_tilt(degrees)
	{
		openflkinect_set_tilt(r, degrees);
		return 0;
	}
	
	private static var openflkinect_get_user_count = 
		Lib.load ("openflkinect", "openflkinect_get_user_count", 1);
	private function get_userCount()
	{
		return openflkinect_get_user_count(r);
	}	
	
	private static var openflkinect_get_is_capturing = 
		Lib.load ("openflkinect", "openflkinect_get_is_capturing", 1);
	private function get_isCapturing()
	{
		return openflkinect_get_is_capturing(r);
	}
	
	private static var openflkinect_get_skeleton_color_pos = 
		Lib.load ("openflkinect", "openflkinect_get_skeleton_color_pos", 2);
	public function skeletonColorPos(pos)
	{
		var ret = openflkinect_get_skeleton_color_pos(r, pos);
		return new Point(ret.x, ret.y);
	}
	
	private static var openflkinect_get_skeleton_depth_pos = 
		Lib.load ("openflkinect", "openflkinect_get_skeleton_depth_pos", 2);
	public function skeletonDepthPos(pos)
	{
		var ret = openflkinect_get_skeleton_depth_pos(r, pos);
		return new Point(ret.x, ret.y);
	}
	
	private var statusCount = 0;
	private static var openflkinect_get_status = 
		Lib.load ("openflkinect", "openflkinect_get_status", 1);
	public function get_status()
	{
		if ( ++statusCount % 120 == 0 )
		{
			var ret = openflkinect_get_status(r);
			status = getStatus(ret);
		}
		return status;
	}
	
	public function adjustBonesToDepth(skeleton:Skeleton)
	{
		for ( j in skeleton.joints )
		{
			var p = skeletonDepthPos(j.position);
			j.position.x = p.x;
			j.position.y = p.y;
		}
	}
	
	public function adjustBonesToColor(skeleton:Skeleton)
	{
		for ( j in skeleton.joints )
		{
			var p = skeletonColorPos(j.position);
			j.position.x = p.x;
			j.position.y = p.y;
		}
	}
	
	public function adjustBoneToColor(b:Bone)
	{
		var p = skeletonColorPos(b.position);
		b.position.x = p.x;
		b.position.y = p.y;
	}
		
	public static function getStatus(code:Int)
	{
		switch ( code )
		{
			case 0 :
				return KinectStatus.SensorStarted;
			case 1 :
				return KinectStatus.SensorError;
			case 2 :
				return KinectStatus.SensorError;
			case 3 :
				return KinectStatus.SensorConflict;
			case 4 :
				return KinectStatus.SensorError;
			case 5 :
				return KinectStatus.SensorNotGenuine;
			case 6 :
				return KinectStatus.SensorInsufficientBandwidth;
			case 7 :
				return KinectStatus.SensorNotSupported;
			case 8 :
				return KinectStatus.SensorConflict;
			
		}
		return KinectStatus.SensorInitializing;
		//#define S_NUI_INITIALIZING                      MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_NUI, 1:                                             // 0x03010001
		//#define E_NUI_FRAME_NO_DATA                     MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 1:
		//static_assert(E_NUI_FRAME_NO_DATA == 0x83010001, "Error code has changed.":;
		//#define E_NUI_STREAM_NOT_ENABLED                MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 2:
		//#define E_NUI_IMAGE_STREAM_IN_USE               MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 3:
		//#define E_NUI_FRAME_LIMIT_EXCEEDED              MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 4:
		//#define E_NUI_FEATURE_NOT_INITIALIZED           MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 5:
		//#define E_NUI_NOTGENUINE                        MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 6:
		//#define E_NUI_INSUFFICIENTBANDWIDTH             MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 7:
		//#define E_NUI_NOTSUPPORTED                      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 8:
		//#define E_NUI_DEVICE_IN_USE                     MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 9:
	}

}
