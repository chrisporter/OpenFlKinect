package openfl.kinect;
import openfl.geom.Vector3D;

/**
 * ...
 * @author Chris Porter
 */
class SkeletonBoneRotation
{

	public var rotationMatrix(default, default):Matrix4;
	public var rotationQuaternion(default, default):Vector3D;
	
	public function new()
	{
		rotationMatrix = new Matrix4();
		rotationQuaternion = new Vector3D();
		
	}
	
}
