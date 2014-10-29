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

class Main extends Sprite 
{
	var k:Kinect;
	var tilt:Int;
	var bmdSkel:BitmapData;
	var bmSkel:Bitmap;
	var d:DeviceOptions;
	var s:Shape;
	
	public function new () 
	{
		super ();
		
		
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
		tilt = k.tilt;
		addChild(k.bmColor);
		bmdSkel = new BitmapData(Std.int(d.colorSize.x), Std.int(d.colorSize.y));
		bmSkel = new Bitmap(bmdSkel);
		addChild(bmSkel);
		
		s = new Shape();
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
		trace(tilt);
		k.tilt = tilt;
	}
	
	public function run(e)
	{
		k.update();
		bmdSkel.fillRect(bmdSkel.rect, 0x00000000);
		s.graphics.clear();
		
		var col = 0;
		
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
		
	}
}