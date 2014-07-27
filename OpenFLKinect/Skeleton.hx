package ;
import openfl.errors.Error;

/**
 * ...
 * @author Chris Porter
 */
class Skeleton
{
	public var joints:Map<SkeletonPositionIndex, Bone>;
	public var isTracked(default, default):Bool = false;

	public function new() 
	{
		joints = new Map<SkeletonPositionIndex, Bone>();
	}
	
	public function parse(d:Dynamic)
	{
		isTracked = d.isTracked;
		
		if ( isTracked == false )
		{
			isTracked = false;
			return;
		}
		isTracked = true;
		var count = d.bones.length;
		for ( i in 0...count) 
		{
			var b = new Bone();
			b.parse(d.bones[i]);
			
			if ( b == null || b.skeletonPositionIndex == null )
			{
				trace("CRASH");
				continue;
			}
			
			try 
			{
				joints[b.skeletonPositionIndex] = b;
			}
			catch(e:Error)
			{
				trace(b);
			}
		}
	}
}