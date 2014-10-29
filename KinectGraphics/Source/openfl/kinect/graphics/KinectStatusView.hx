package openfl.kinect.graphics;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Assets;
import openfl.text.TextFieldAutoSize;
import motion.Actuate;
import openfl.kinect.KinectStatus;
/**
 * ...
 * @author Chris Porter
 */
class KinectStatusView extends Sprite
{
	var normal:Bitmap;
	var ready:Bitmap;
	var error:Bitmap;
	public var status(default, set):KinectStatus;
	private var tf:TextFormat;
	private var text:TextField;

	public function new()
	{
		super();
		normal = new  Bitmap( Assets.getBitmapData("img/KinectSensor.png"));
		ready = new  Bitmap( Assets.getBitmapData("img/KinectSensor_ready.png"));
		error = new  Bitmap( Assets.getBitmapData("img/KinectSensor_error.png"));
		
		addChild(normal);
		addChild(ready);
		addChild(error);
		
		tf = new TextFormat("Arial");
		tf.color = 0x000000; // 0xffffff;

		text = new TextField();
		text.width = normal.width;
		text.setTextFormat(tf);
		text.defaultTextFormat = tf;

		text.autoSize = TextFieldAutoSize.CENTER;
		addChild(text);
		//text.text = "Hello World";
		text.y = normal.height;
		text.filters = [ new GlowFilter(0xFFFFFF) ];
		status = KinectStatus.None;
	}
	
	private function set_status(val)
	{
		normal.visible = false;
		ready.visible = false;
		error.visible = false;
		text.visible = false;
		Actuate.stop(normal);
		
		switch( val )
		{
			case KinectStatus.None:
				normal.visible = true;

			case KinectStatus.SensorInitializing:
				Actuate.tween(normal, 1.0, { alpha : 0.0 } ).repeat().reflect();
				normal.visible = true;
				
			case KinectStatus.SensorStarted:
				ready.visible = true;

			case KinectStatus.NoAvailableSensors:
				error.visible = true;
				text.visible = true;
				text.text = "No available sensor";

			case KinectStatus.SensorConflict:
				error.visible = true;
				text.visible = true;
				text.text = "Sensor Conflict";

			case KinectStatus.SensorNotPowered:
				error.visible = true;
				text.visible = true;
				text.text = "Sensor not powered";

			case KinectStatus.SensorInsufficientBandwidth:
				error.visible = true;
				text.visible = true;
				text.text = "Insufficient sensor bandwidth";

			case KinectStatus.SensorNotGenuine:
				error.visible = true;
				text.visible = true;
				text.text = "Fake sensor";

			case KinectStatus.SensorNotSupported:				
				error.visible = true;
				text.visible = true;
				text.text = "Sensor not supported";

			case KinectStatus.SensorError:	
				error.visible = true;
				text.visible = true;
				
				
		}
		
		status = val;
		return status;
	}
}
