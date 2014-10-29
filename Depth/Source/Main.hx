import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.kinect.Kinect;
import openfl.kinect.DeviceOptions;
import openfl.kinect.ImageResolution;

#if cpp
import cpp.Lib;
#end
#if neko

#end
import openfl.display.FPS;

class Main extends Sprite 
{
	var k:Kinect;
	var tilt:Int;
	var d:DeviceOptions;
	
	public function new () 
	{
		super ();
				
		d = new DeviceOptions();
		d.depthEnabled = true;
		d.irEnabled = false;
		d.colorEnabled = false;
		d.skeletonTrackingEnabled = false;
		d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		d.flipped = false;		
		d.userColor = false;
		d.userTrackingEnabled = false;
		d.interactionEnabled = false;
	
		k = new Kinect(d);
		k.start();
		tilt = k.tilt;
		
		addChild(k.bmDepth);
		addChild(new FPS());
		
		addEventListener(Event.ENTER_FRAME, run);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
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
		k.tilt = tilt;
	}
	
	public function run(e)
	{
		k.update();		
	}
}