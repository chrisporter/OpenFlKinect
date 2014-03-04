package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
 * ...
 * @author Chris Porter
 */
class ScrollView extends Sprite
{
	var scrollLayer:Sprite;
	var velocity:Float = 0.0;
	var viewPortWidth:Float;
	var dragging = false;
	var oldX = 0.0;
	var scrollX = -1.0;
	var lastX = -1.0;
	var moveSpeed = 10.0;
	var lb:ListButton;
	public var handX(null, default):Float = -1.0;

	public function new(width) 
	{
		this.viewPortWidth = width;
		super();
		init();
	}
	
	public function init()
	{
		//this.graphics.beginFill(0x000000, 1);
		//this.graphics.drawRect(0, 0, WIDTH, 210);
		//this.graphics.endFill();
		
		scrollLayer = new Sprite();
		addChild(scrollLayer);
		//scrollLayer.graphics.beginFill(0x000000, 1.1);
		//scrollLayer.graphics.drawRect(0, 0, Main.WIDTH, 210);
		//scrollLayer.graphics.endFill();
		var x = 0.0;
		for ( i in 0...20) 
		{
			var b = new ListButton(i + 1);
			b.x = x;
			x += b.width + 10;
			scrollLayer.addChild(b);
			
			//b.addEventListener(MouseEvent.MOUSE_OVER, function(e)
			//{
				//b.grow();
			//});
			//
			//b.addEventListener(MouseEvent.MOUSE_OUT, function(e)
			//{
				//b.shrink();
			//});
		}
		
		addEventListener(Event.ENTER_FRAME, run);
	}
		
	public function mouseUp(e) 
	{
		dragging = false;
	}
	
	public function mouseDown(localX) 
	{
		dragging = true;
		//scrollX = scrollLayer.x - localX;
		scrollX = -scrollLayer.x + localX;
		//trace(scrollX);
	}
	
	private function run(e) 
	{
		if (dragging)
		{
			scrollLayer.x = handX - scrollX;
			velocity = scrollLayer.x - oldX;
		}
		else
		{
			scrollLayer.x +=  velocity;
			//trace(this.viewPortWidth);
			if ( scrollLayer.x >= 0 || scrollLayer.x <= - scrollLayer.width + viewPortWidth )
			{
				velocity *=  -1;
			}
			scrollLayer.x = Math.max(Math.min(0, scrollLayer.x), viewPortWidth - scrollLayer.width);
		}
		velocity *=  .95;
		oldX = scrollLayer.x;
		
		for ( x in 0...scrollLayer.numChildren )
		{
			var obj = scrollLayer.getChildAt(x);
			if ( Std.is(obj, ListButton) )
			{
				if ( lb != obj )
				{
					var b = cast(obj, ListButton);
					b.shrink();
				}
			}
		}
		lb = null;
	}
	
	public function moveLeft()
	{
		scrollLayer.x += moveSpeed;
		scrollLayer.x = Math.max(Math.min(0, scrollLayer.x), viewPortWidth - scrollLayer.width);
	}
	
	public function moveRight()
	{
		scrollLayer.x -= moveSpeed;
		scrollLayer.x = Math.max(Math.min(0, scrollLayer.x), viewPortWidth - scrollLayer.width);
	}
	
	public function hover(x, y)
	{
		var under = this.getObjectsUnderPoint(new Point(x, y));
		if ( under.length < 1 )
		{
			return;
		}
		
		if ( Std.is(under[0].parent, ListButton) )
		{
			lb = cast(under[0].parent, ListButton);
			lb.grow();
		}
	}
	
	public function button(x, y):ListButton
	{
		var under = this.getObjectsUnderPoint(new Point(x, y));
		
		if ( under.length > 0 && Std.is(under[0].parent, ListButton) )
		{
			lb = cast(under[0].parent, ListButton);
			return lb;
		}
		
		return null;
	}
	
}