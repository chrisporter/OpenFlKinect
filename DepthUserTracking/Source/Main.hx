import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.kinect.DeviceOptions;
import openfl.kinect.ImageResolution;
import openfl.kinect.Kinect;

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