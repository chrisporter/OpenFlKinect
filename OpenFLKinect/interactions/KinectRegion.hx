package interactions;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
/**
 * ...
 * @author Chris Porter
 */
class KinectRegion extends Sprite
{
	var _width:Float;
	var _height:Float;
	var kinect:Kinect;
	var hands:Map<String, Hand>;
	var debug = false;
	var handsLayer:Sprite;
	var controlsLayer:Sprite;
	var enabled = true;
	var curHand = "debug___";
	var dragging:Map<DisplayObject, Hand>;
	var availableColors:Array<Int>;
	var userColors:Map<String, Int>;
	static var curCol:Int = 0;
	var handSize:HandSize;

	public function new(width, height, kinect, handSize, debug = false ) 
	{
		super();
		this.handSize = handSize;
		initColours();
		this.debug = debug;
		this.kinect = kinect;
		this._height = height;
		this._width = width;
		this.graphics.beginFill(0x445500, 0.0);
		this.graphics.drawRect(0, 0, _width, _height);
		this.graphics.endFill();
		
		
		hands = new Map<String, Hand>();
		
		handsLayer = new Sprite();
		controlsLayer = new Sprite();
		super.addChild(controlsLayer);
		super.addChild(handsLayer);
		this.dragging = new Map<DisplayObject, Hand>();
		addEventListener(Event.ADDED_TO_STAGE, init);	
	}
	
	function initColours()
	{
		userColors = new Map();
		availableColors = new Array<Int>();
		availableColors.push(0x00ff00);
		availableColors.push(0x00ffff);
		availableColors.push(0xffff00);
		availableColors.push(0xff00ff);
		availableColors.push(0xff0000);
		availableColors.push(0x0000ff);
		availableColors.push(0x0000ff);
		availableColors.push(0x0000ff);
	}

	function getColour(id)
	{
		if ( userColors.exists( Std.string(id) ) )
		{
			return userColors.get(Std.string(id));
		}
		
		var col = availableColors[curCol];
		curCol = ++curCol % availableColors.length;
		userColors.set(Std.string(id), col);
		return col;
	}
	
	function init(e)
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		if ( debug )
		{
			var h = new Hand(handSize, HandType.NUI_HAND_TYPE_RIGHT);
			var ctrlDown = false;
			hands['debug___'] = h;
			handsLayer.addChild(h);
			setHandColour(h, -888);
			
			var h2 = new Hand(handSize, HandType.NUI_HAND_TYPE_LEFT);
			var ctrlDown = false;
			hands['debug___2'] = h2;
			handsLayer.addChild(h2);
			setHandColour(h2, -88);
			
			var z = 0.0;
			var pressing = false;
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			this.addEventListener(MouseEvent.MOUSE_DOWN, function(e)
			{
				if ( ctrlDown == false )
				{
					hands[curHand].gripped = true;
				
				}
				else
				{
					pressing = true;
				}
			});
			
			this.addEventListener(MouseEvent.MOUSE_UP, function(e)
			{
				hands[curHand].gripped = false;
				pressing = false;
				z = 0.0;
			});
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent)
			{
				ctrlDown = e.keyCode == 17;
			});
			
			stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent)
			{
				if ( e.keyCode == 17 )
				{
					ctrlDown = false;
				}
				
				if ( e.keyCode == 18 )
				{
					curHand = curHand == 'debug___' ? 'debug___2' : 'debug___';
				}
			});
			
			addEventListener(Event.ENTER_FRAME, function(e)
			{
				if ( pressing )
				{
					z += 0.1;
				}
				hands[curHand].pressedAmount = z;
			});
		}
	}
	
	public function addInteractiveChild(d)
	{
		controlsLayer.addChild(d);
		return d;
	}
	
	private function mouseMove(e:MouseEvent) 
	{
		hands[curHand].x = this.mouseX;
		hands[curHand].y = this.mouseY;
		e.stopImmediatePropagation();
	}
	
	public function run() 
	{
		if ( enabled == false )
		{
			handsLayer.visible = false;
			return;
		}
		
		handsLayer.visible = true;
		
		for ( i in kinect.userInfos )
		{
			if ( i.skeletonTrackingID > 0 )
			{
				for ( j in i.handPointers )
				{
					updateHand(i.skeletonTrackingID, j);
				}
			}
		}
		
		var anyMap = new Map<DisplayObject, Bool>();
		var tEvent = new TouchEvent(TouchEvent.TOUCH_OVER);
		
		for ( y in hands )
		{
			if ( y.visible == false )
			{
				continue;
			}
			
			var gripStart = y.gripStart;
			var gripEnd = y.gripEnd;
			var obj:DisplayObject = null;
			var areaCovered = 0.0;
			var intersection:Rectangle = null;
				
			for ( i in -(controlsLayer.numChildren-1)...1 )
			{
				var x = i * -1;
				var c = controlsLayer.getChildAt(x);
				intersection = y.getRect(this).intersection(c.getRect(this));
				var area = intersection.width * intersection.height;
				if ( area > 0.0 && area > areaCovered )
				{
					areaCovered = area;
					obj = c;
				}
				anyMap[c] = false;	
				
				if ( y.dragging && dragging[c] == y )
				{
					tEvent = new TouchEvent(TouchEvent.TOUCH_MOVE);
					setTouchEvent(y, intersection, tEvent);
					c.dispatchEvent( tEvent );
				}
			}
			
			if ( obj == null )
			{
				continue;
			}
			
			tEvent = new TouchEvent(TouchEvent.TOUCH_OVER);
			
			
			anyMap[obj] = true;
			obj.dispatchEvent( tEvent );
			
			if ( dragging.exists(obj) && dragging[obj] != y )
			{
				continue;
			}
			
			if ( gripStart )
			{
				tEvent = new TouchEvent(TouchEvent.TOUCH_BEGIN);
				setTouchEvent(y, intersection, tEvent);
				obj.dispatchEvent( tEvent );
				dragging[ obj ] = y;
			}
			
			if ( y.pressedAmount >= 1.0 && y.pressed == false )
			{
				tEvent = new TouchEvent(TouchEvent.TOUCH_TAP);
				setTouchEvent(y, intersection, tEvent);
				obj.dispatchEvent( tEvent );
				y.pressed = true;
			}
			if ( gripEnd )
			{
				obj.dispatchEvent( new TouchEvent(TouchEvent.TOUCH_END) );
				dragging.remove(obj);
			}
		}
		
		for ( o in anyMap.keys() )
		{
			if ( anyMap[o] == false )
			{
				tEvent = new TouchEvent(TouchEvent.TOUCH_OUT);
				setTouchEvent(null, new Rectangle(), tEvent);
				//obj.dispatchEvent(tEvent);
			}
		}
	}
	
	function updateHand(skeltonID:Int, handPointer:HandPointer) 
	{
		var h = Std.string(handPointer.handType);
		var key = '$skeltonID-$h';
		
		var hand;
		if ( hands.exists(key ) )
		{
			hand = hands[key];
		}
		else
		{
			hand = new Hand(handSize, handPointer.handType);
			handsLayer.addChild(hand);
			hands[key] = hand;
			
			setHandColour(hand, skeltonID);
		}
		
		if ( handPointer.state.has(HandPointerState.NUI_HANDPOINTER_STATE_PRIMARY_FOR_USER)
			&& handPointer.state.has(HandPointerState.NUI_HANDPOINTER_STATE_ACTIVE) )
		{
			hand.visible = true;
			var halfWidth = hand.width / 2;
			var halfHeight = hand.height / 2;
			//hand.x = constrain(handPointer.x * _width, -halfWidth, _width + halfWidth);
			//hand.y = constrain(handPointer.y * _height, -halfHeight, _height + halfHeight);
			hand.x = (handPointer.x * _width);
			hand.y = (handPointer.y * _height);
			hand.x = constrain(hand.x, -halfWidth, _width + halfWidth);
			hand.y = constrain(hand.y, -halfHeight, _height + halfHeight);
			
			if ( handPointer.handEventType == HandEventType.NUI_HAND_EVENT_TYPE_GRIP )
			{
				hand.gripped = true;
			}
			else if ( handPointer.handEventType == HandEventType.NUI_HAND_EVENT_TYPE_GRIPRELEASE )
			{
				hand.gripped = false;
			}
			
			hand.pressedAmount = handPointer.pressExtent;
		}
		else
		{
			hand.visible = false;
		}
	}
	
	private function constrain(val, min, max)
	{
		return Math.max(min, Math.min(max, val));
	}
	
	function setTouchEvent(hand:Hand, intersection:Rectangle, tEvent):Void 
	{
		tEvent.localX = intersection.x + intersection.width / 2;
		tEvent.localY = intersection.y + intersection.height / 2;
		if ( hand != null )
		{
			tEvent.stageX = hand.x;
			tEvent.stageY = hand.y;
		}
	}
	
	function setHandColour(hand:Hand, skeltonID):Void 
	{
		var colour = getColour(skeltonID);
		hand.colour = colour;
	}
	
}