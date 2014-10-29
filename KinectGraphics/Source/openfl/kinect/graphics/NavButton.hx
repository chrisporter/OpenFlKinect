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
class NavButton extends Sprite
{
	var origWidth:Float;
	var origHeight:Float;

	public function new(isLeft = true) 
	{
		super();
		
		this.graphics.beginFill(0xD3D3D3);
		this.graphics.lineStyle(0, 0);
		this.graphics.drawRect(0, 0, 400, 200);
		this.graphics.endFill();
		
		var tf = new TextFormat("Arial");
		tf.color = 0x97959A;
		tf.size = 108;

		var text = new TextField();
		text.setTextFormat(tf);
		text.defaultTextFormat = tf;
		//text.border = true;

		text.autoSize = TextFieldAutoSize.CENTER;
		addChild(text);
		text.text = isLeft ? "<" : ">";
		text.y = (height - text.height) / 2;
		text.x = (width / 2) - text.width/2;
		origWidth = width;
		origHeight = height;
	}
	
	public function grow()
	{
		var toWidth = origWidth * 1.35;
		var toHeight = origHeight * 1.35;
		var toX = x - (toWidth - origWidth) / 2;
		var toY = y - (toHeight - origHeight) / 2;
		Actuate.tween(this, 1.0, { x : toX, y: toY, width:toWidth, height:toHeight } );
	}
	
	public function shrink()
	{
		var toX = x + (width - origWidth) / 2;
		var toY = y + (height - origHeight) / 2;
		Actuate.tween(this, 1.0, { x : toX, y: toY, width:origWidth, height:origHeight } );
	}
	
	
	
	
}
