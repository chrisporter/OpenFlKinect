package ;
import openfl.display.Sprite;
import openfl.events.TouchEvent;
import openfl.kinect.interactions.KinectRegion;
import openfl.events.MouseEvent;
import motion.Actuate;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
/**
 * ...
 * @author Chris Porter
 */
class Navigation extends KinectRegion
{
	var message:Sprite;
	var left:NavButton;
	var right:NavButton;
	var tf:TextFormat;
	var text:openfl.text.TextField;
	var s:ScrollView;
	
	public function new(width, height, kinect) 
	{
		super(width, height, kinect, HandSize.Small );
		s = new ScrollView(width);
		addChild(s);
		s.addEventListener(TouchEvent.TOUCH_OVER, handOver);
		s.addEventListener(TouchEvent.TOUCH_BEGIN, handDown);
		s.addEventListener(TouchEvent.TOUCH_END, handUp);
		s.addEventListener(TouchEvent.TOUCH_MOVE, handDrag);
		s.addEventListener(TouchEvent.TOUCH_TAP, handTap);
		left = new NavButton();
		addChild(left);
		left.addEventListener(TouchEvent.TOUCH_OVER, handOver);
		//left.addEventListener(TouchEvent.TOUCH_BEGIN, handDown);
		//left.addEventListener(TouchEvent.TOUCH_END, handUp);
		//left.addEventListener(TouchEvent.TOUCH_MOVE, handDrag);
		right = new NavButton(false);
		addChild(right);
		left.y = Main.HEIGHT - left.height;
		right.x = Main.WIDTH - left.width;
		left.y = right.y = Main.HEIGHT - left.height;
		
		right.addEventListener(TouchEvent.TOUCH_OVER, handOver);
		//right.addEventListener(TouchEvent.TOUCH_BEGIN, handDown);
		//right.addEventListener(TouchEvent.TOUCH_END, handUp);
		//right.addEventListener(TouchEvent.TOUCH_MOVE, handDrag);
		
		
		//cpp.vm.Profiler.start("log.txt");
		//Lib.current.addChild (new  );	
		message = new Sprite();
		message.graphics.beginFill(0x00BCF2);
		message.graphics.drawRect(0, 0, width, height - left.height); 
		message.graphics.endFill();
		tf = new TextFormat("Arial");
		tf.color = 0xFFFFFFF;
		tf.size = 48;
		text = new TextField();
		text.setTextFormat(tf);
		text.defaultTextFormat = tf;
		text.autoSize = TextFieldAutoSize.LEFT;
		//addChild(text);
		text.text = "you selected X";
		text.y = (message.height - text.height) / 2;
		text.x = (message.width- text.width ) /2;
		message.addChild(text);
		message.alpha = 0;
		addChild(message);
	}
	
	override function run()
	{
		super.run();
	}
	
	private function handOver(e:TouchEvent) 
	{
		//trace("handOver");
		
		if ( Std.is(e.target, ScrollView) )
		{
			s.hover(e.localX, e.localY);
			return;
		}
		
		var nb = cast(e.target, NavButton);
		if ( nb == left )
		{
			s.moveLeft();
		}
		else
		{
			s.moveRight();
		}
	}
	
	private function handDown(e)
	{
		if ( Std.is(e.target, ScrollView) )
		{
			s.mouseDown(e.stageX);
			return;
		}
	}
	
	private function handUp(e)
	{
		if ( Std.is(e.target, ScrollView) )
		{
			s.mouseUp(e.localX);
			return;
		}
	}
	
	private function handDrag(e)
	{
		if ( Std.is(e.target, ScrollView) )
		{
			s.handX = e.localX;
			return;
		}
	}
	
	private function handTap(e)
	{
		trace("tap");
		if ( Std.is(e.target, ScrollView) )
		{
			var lb = s.button(e.localX, e.localY);
			if ( lb != null )
			{
				showSelect(lb.id);
			}
			return;
		}
	}
	
	public function showSelect(selected:Int)
	{
		text.text = 'you selected $selected';
		message.scaleX = message.scaleY = .3;
		var startX = (Main.WIDTH-message.width)/2;
		var startY = (Main.HEIGHT - left.height - message.height) / 2;
		message.x = startX;
		message.y - startY;
		
		var a = Actuate.tween(message, 1.0, { scaleX: 1.0, scaleY: 1.0, x: 0, y:0, alpha: 1.0 } ).onComplete(
			function()
			{
				Actuate.tween(message, 1.0, { scaleX: .3, scaleY: 0.3, x: startX, y:startY, alpha: 0.0 } ).delay(3.0);
			});
	}
	
}