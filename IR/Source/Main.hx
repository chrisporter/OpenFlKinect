import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import cpp.Lib;
import openfl.kinect.Kinect;
import openfl.kinect.DeviceOptions;
import openfl.kinect.ImageResolution;

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
		d.irEnabled = true;
		d.colorEnabled = false;
		d.skeletonTrackingEnabled = false;
		d.irResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		d.flipped = false;
		
		k = new Kinect(d);
		k.start();
		tilt = k.tilt;
		
		addChild(k.bmIr);
		
		addEventListener(Event.ENTER_FRAME, run);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
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
		trace(tilt);
		k.tilt = tilt;
	}
		
	public function run(e)
	{
		k.update();		
	}
}