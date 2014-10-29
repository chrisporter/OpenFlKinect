package openfl.kinect.interactions.events;

import openfl.events.Event;
import openfl.kinect.interactions.HandEventType;

/**
 * ...
 * @author Chris Porter
 */
class HandEvent extends Event
{
	public static inline var HAND_STATE_CHANGED = "HAND_STATE_CHANGED";

	public var handEventType(default, default):HandEventType;

	public function new(type, handEventType = null, bubbles = false, cancelable = false)
	{
		super(type, bubbles, cancelable);
		this.handEventType = handEventType;
	}

	public override function clone()
	{
		return new HandEvent(type, this.handEventType, bubbles, cancelable);
	}
	
}
