import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import haxe.Utf8;
import openfl.kinect.interactions.KinectRegion;
import openfl.display.DirectRenderer;
import openfl.kinect.Kinect;
import openfl.kinect.DeviceOptions;
import openfl.kinect.ImageResolution;
#if cpp
import cpp.Lib;
#end
import openfl.display.FPS;

class Main extends Sprite 
{
	var k:Kinect;
	var tilt:Int;
	var d:DeviceOptions;
	var ksv:KinectStatusView;
	var nav:KinectRegion;
	public static inline var WIDTH = 800;
	public static inline var HEIGHT = 600;
	
	public function new () 
	{
		super ();
		
	
		
		d = new DeviceOptions();
		d.depthEnabled = true;
		d.irEnabled = false;
		d.colorEnabled = false;
		d.skeletonTrackingEnabled = true;
		d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		d.flipped = false;		
		d.interactionEnabled = true;
		d.userTrackingEnabled = true;
	
		k = new Kinect(d);
		k.start();
		tilt = k.tilt;
		
		//addChild(k.bmDepth);
		
		addEventListener(Event.ENTER_FRAME, run);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
	
		
		nav = new Navigation(WIDTH, HEIGHT, k);
		addChild(nav);
		
		
		addChild(new FPS(10, 10, 0xFFFFFF));
		ksv = new KinectStatusView();
		addChild(ksv);
		ksv.x = (WIDTH - Std.int(ksv.width)) / 2;
		//cpp.vm.Profiler.start("log.txt");
	}
	
	private function keyUp(e:KeyboardEvent):Void 
	{
		switch (e.keyCode)
		{
			case 38:
				tilt--;
			case 40:
				tilt++;
		}
		//k.tilt = tilt;
	}
	
	public function run(e)
	{
		k.update();		
		nav.run();
		ksv.status = k.status;
		
	}
}