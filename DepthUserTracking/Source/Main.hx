import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import cpp.Lib;
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
		d.skeletonTrackingEnabled = true;
		d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_320x240;
		d.flipped = false;		
		d.userTrackingEnabled = true;
		//d.binaryMode = true;
		//d.inverted = true;
		d.removeBackground = true;
		d.userColor = true;
		
		k = new Kinect(d);
		k.start();
		tilt = k.tilt;
		
		k.bmDepth.scaleX = k.bmDepth.scaleY = 2.0;
		addChild(k.bmDepth);
		addChild(new FPS(10, 10 , 0xFFFFFF));
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
		k.tilt = tilt;
	}
	
	public function run(e)
	{
		k.update();		
	}
}