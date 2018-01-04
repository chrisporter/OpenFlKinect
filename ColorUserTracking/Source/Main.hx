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
		d.colorEnabled = true;
		d.skeletonTrackingEnabled = false;
		d.colorResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		d.depthResolution = ImageResolution.NUI_IMAGE_RESOLUTION_640x480;
		d.userTrackingEnabled = true;
		d.removeBackground = true;
		d.flipped = false;
		//d.mapColorToDepth
		
		k = new Kinect(d);
		k.start();
		tilt = k.tilt;
		
		k.bmColor.alpha = .5;
		k.bmDepth.alpha = .5;
		k.bmDepth.width = k.bmColor.width;
		k.bmDepth.height = k.bmColor.height;
		addChild(k.bmColor);
		addChild(k.bmDepth);
		addChild(new FPS());

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
