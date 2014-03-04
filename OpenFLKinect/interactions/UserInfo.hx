package interactions;
import interactions.events.HandEvent;

/**
 * ...
 * @author Chris Porter
 */
class UserInfo
{
	public var skeletonTrackingID(default, default):Int;
	public var handPointers(default, default):Array<HandPointer>;

	public function new() 
	{
		handPointers = new Array<HandPointer>();
		handPointers.push( new HandPointer() );
		handPointers.push( new HandPointer() );
		handPointers[0].addEventListener( HandEvent.HAND_STATE_CHANGED, handStateChanged);
		handPointers[1].addEventListener( HandEvent.HAND_STATE_CHANGED, handStateChanged);
	}
	
	private function handStateChanged(e:HandEvent):Void 
	{
	}
	
	public function parse(d:Dynamic)
	{
		if ( d.isTracked == false )
		{
			//skeletonTrackingID = 12;
			return;
		}
		
		skeletonTrackingID = d.skeletonTrackingId;
		var count = d.handPointerInfos.length;

		for ( i in 0...count) 
		{
			var h = handPointers[i];
			h.parse(d.handPointerInfos[i]);
			handPointers.push(h);
		}
	}
}