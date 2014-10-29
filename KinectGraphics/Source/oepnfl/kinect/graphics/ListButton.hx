package openfl.kinect.graphics;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import motion.Actuate;

/**
 * ...
 * @author Chris Porter
 */
class ListButton extends Sprite
{
	var origWidth:Float;
	var origHeight:Float;
	var startX:Float;
	var startY:Float;
	var container:Sprite;
	var growing:Bool = false;
	var shrinking:Bool = false;
	public var id(default, default):Int = -1;
	
	public function new(num) 
	{
		super();
		init();
		
		this.id = num;
		origWidth = width;
		origHeight = height;
		startX = x;
		startY = y;
	}
	
	public function init():Void 
	{
		container = new Sprite();
		addChild(container);
		
		container.graphics.lineStyle(1, 0x97959A);
		container.graphics.beginFill(0xEEEBF4);
		container.graphics.drawRect(0, 0, 210, 210);
		
		container.graphics.beginFill(0x53318F);
		container.graphics.lineStyle(0, 0);
		container.graphics.drawRect(1, 1, 208, 140);		
		container.graphics.endFill();
		
		var tf = new TextFormat("Arial");
		tf.color = 0x97959A;
		tf.size = 32;
	
		var text = new TextField();
		text.setTextFormat(tf);
		text.defaultTextFormat = tf;
	
		text.autoSize = TextFieldAutoSize.LEFT;
		container.addChild(text);
		text.text = Std.string(id);
		text.y = 160;
		text.x = 20;
	}
	
	public function grow()
	{
		if ( growing )
		{
			return;
		}
		
		growing = true;
		shrinking = false;
		this.parent.setChildIndex(this, this.parent.numChildren - 1);
		
		var toWidth = origWidth * 1.15;
		var toHeight = origHeight * 1.15;
		var toX = container.x - (toWidth - origWidth) / 2;
		var toY = container.y - (toHeight - origHeight) / 2;
		Actuate.tween(container, 1.0, { x : toX, y: toY, width:toWidth, height:toHeight } ).onComplete(
			function(x)
			{
				//growing = false;
			});
	}
	
	public function shrink()
	{
		if ( shrinking )
		{
			return;
		}
		growing = false;
		shrinking = true;
		var toX = 0;
		var toY = 0;
		Actuate.tween(container, 1.0, { x : toX, y: toY, width:origWidth, height:origHeight } );
	}
	
	
	
	
}
