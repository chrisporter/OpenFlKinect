package interactions;

import flash.events.EventDispatcher;
import haxe.EnumFlags;
import interactions.events.HandEvent;
/**
 * ...
 * @author Chris Porter
 */
class HandPointer extends EventDispatcher
{
	private var lastHandEventType:HandEventType;
	private var event:HandEvent;
	public var handEventType(default, default):HandEventType;
	public var handType(default, default):HandType;
	public var pressExtent(default, default):Float;
	public var rawX(default, default):Float;
	public var rawY(default, default):Float;
	public var rawZ(default, default):Float;
	public var state(default, default):EnumFlags<HandPointerState>;
	public var x(default, default):Float;
	public var y(default, default):Float;
	
	public function new() 
	{
		super();
		lastHandEventType = HandEventType.NUI_HAND_EVENT_TYPE_NONE;
		event = new HandEvent(HandEvent.HAND_STATE_CHANGED, HandEventType.NUI_HAND_EVENT_TYPE_NONE);
	}
	
	public function parse(d:Dynamic)
	{
		handEventType = Type.createEnumIndex(HandEventType, d.handTypeEvent);
		handType = Type.createEnumIndex(HandType, d.handType);
		pressExtent = Std.parseFloat(d.pressExtent);
		rawX = d.rawX;
		rawY = d.rawY;
		rawZ = d.rawZ;
		state = handPointerState(d.state);
		x = d.x;
		y = d.y;
		//trace(d);
		if ( lastHandEventType != handEventType )
		{
			event.handEventType = handEventType;
			dispatchEvent(event);
		}
		
		lastHandEventType = handEventType;
	}
	
	public function handPointerState(flags)
	{
		var ret = new EnumFlags<HandPointerState>();
		if ( flags & 0x00 == 0x00 )
		{
			ret.set(HandPointerState.NUI_HANDPOINTER_STATE_NOT_TRACKED);
		}
		
		if ( flags & 0x01 == 0x01 )
		{
			ret.set(HandPointerState.NUI_HANDPOINTER_STATE_TRACKED);
		}
		
		if ( flags & 0x02 == 0x02 )
		{
			ret.set(HandPointerState.NUI_HANDPOINTER_STATE_ACTIVE);
		}
		
		if ( flags & 0x04 == 0x04 )
		{
			ret.set(HandPointerState.NUI_HANDPOINTER_STATE_INTERACTIVE);
		}
		
		if ( flags & 0x08 == 0x08 )
		{
			ret.set(HandPointerState.NUI_HANDPOINTER_STATE_PRESSED);
		}
		
		if ( flags & 0x10 == 0x10 )
		{
			ret.set(HandPointerState.NUI_HANDPOINTER_STATE_PRIMARY_FOR_USER);
		}
		
		return ret;

		//NUI_HANDPOINTER_STATE_NOT_TRACKED = 0x00,
		//NUI_HANDPOINTER_STATE_TRACKED = 0x01,
		//NUI_HANDPOINTER_STATE_ACTIVE = 0x02,
		//NUI_HANDPOINTER_STATE_INTERACTIVE = 0x04,
		//NUI_HANDPOINTER_STATE_PRESSED = 0x08,
		//NUI_HANDPOINTER_STATE_PRIMARY_FOR_USER = 0x10
	}
	//}
}