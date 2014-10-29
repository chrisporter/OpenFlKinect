package openfl.kinect;

import openfl.geom.Vector3D;

/**
 * ...
 * @author Chris Porter
 */
class Bone
{
	public var skeletonPositionIndex(default, default):SkeletonPositionIndex;
	public var endJoint(default, default):SkeletonPositionIndex;
	public var startJoint(default, default):SkeletonPositionIndex;
	public var hierarchicalRotation(default, default):SkeletonBoneRotation;
	public var absoluteRotation(default, default):SkeletonBoneRotation;	
	public var position(default, default):Vector3D;

	public function new() 
	{
		 hierarchicalRotation = new SkeletonBoneRotation();
		absoluteRotation = new SkeletonBoneRotation();
		position = new Vector3D();
	}
		
	public function parse(a:Dynamic)
	{
		if ( a == null )
		{
			return;
		}
		
		skeletonPositionIndex = Type.createEnumIndex(SkeletonPositionIndex, Std.int(a.skeletonPositionIndex));
		startJoint = Type.createEnumIndex(SkeletonPositionIndex, Std.int(a.startJoint));
		endJoint = Type.createEnumIndex(SkeletonPositionIndex, Std.int(a.endJoint));
				
		position.x = a.position.x;
		position.y = a.position.y;
		position.z = a.position.z;
		
		hierarchicalRotation.rotationMatrix.M11 = a.hierarchicalRotation.rotationMatrix.M11;
		hierarchicalRotation.rotationMatrix.M12 = a.hierarchicalRotation.rotationMatrix.M12;
		hierarchicalRotation.rotationMatrix.M13 = a.hierarchicalRotation.rotationMatrix.M13;
		hierarchicalRotation.rotationMatrix.M14 = a.hierarchicalRotation.rotationMatrix.M14;
		hierarchicalRotation.rotationMatrix.M21 = a.hierarchicalRotation.rotationMatrix.M21;
		hierarchicalRotation.rotationMatrix.M22 = a.hierarchicalRotation.rotationMatrix.M22;
		hierarchicalRotation.rotationMatrix.M23 = a.hierarchicalRotation.rotationMatrix.M23;
		hierarchicalRotation.rotationMatrix.M24 = a.hierarchicalRotation.rotationMatrix.M24;
		hierarchicalRotation.rotationMatrix.M31 = a.hierarchicalRotation.rotationMatrix.M31;
		hierarchicalRotation.rotationMatrix.M32 = a.hierarchicalRotation.rotationMatrix.M32;
		hierarchicalRotation.rotationMatrix.M33 = a.hierarchicalRotation.rotationMatrix.M33;
		hierarchicalRotation.rotationMatrix.M34 = a.hierarchicalRotation.rotationMatrix.M34;
		hierarchicalRotation.rotationMatrix.M41 = a.hierarchicalRotation.rotationMatrix.M41;
		hierarchicalRotation.rotationMatrix.M42 = a.hierarchicalRotation.rotationMatrix.M42;
		hierarchicalRotation.rotationMatrix.M43 = a.hierarchicalRotation.rotationMatrix.M43;
		hierarchicalRotation.rotationMatrix.M44 = a.hierarchicalRotation.rotationMatrix.M44;

		hierarchicalRotation.rotationQuaternion.x = a.hierarchicalRotation.rotationQuaternion.x; 
		hierarchicalRotation.rotationQuaternion.y = a.hierarchicalRotation.rotationQuaternion.y;
		hierarchicalRotation.rotationQuaternion.z = a.hierarchicalRotation.rotationQuaternion.z;

		absoluteRotation.rotationMatrix.M11 = a.absoluteRotation.rotationMatrix.M11;
		absoluteRotation.rotationMatrix.M12 = a.absoluteRotation.rotationMatrix.M12;
		absoluteRotation.rotationMatrix.M13 = a.absoluteRotation.rotationMatrix.M13;
		absoluteRotation.rotationMatrix.M14 = a.absoluteRotation.rotationMatrix.M14;
		absoluteRotation.rotationMatrix.M21 = a.absoluteRotation.rotationMatrix.M21;
		absoluteRotation.rotationMatrix.M22 = a.absoluteRotation.rotationMatrix.M22;
		absoluteRotation.rotationMatrix.M23 = a.absoluteRotation.rotationMatrix.M23;
		absoluteRotation.rotationMatrix.M24 = a.absoluteRotation.rotationMatrix.M24;
		absoluteRotation.rotationMatrix.M31 = a.absoluteRotation.rotationMatrix.M31;
		absoluteRotation.rotationMatrix.M32 = a.absoluteRotation.rotationMatrix.M32;
		absoluteRotation.rotationMatrix.M33 = a.absoluteRotation.rotationMatrix.M33;
		absoluteRotation.rotationMatrix.M34 = a.absoluteRotation.rotationMatrix.M34;
		absoluteRotation.rotationMatrix.M41 = a.absoluteRotation.rotationMatrix.M41;
		absoluteRotation.rotationMatrix.M42 = a.absoluteRotation.rotationMatrix.M42;
		absoluteRotation.rotationMatrix.M43 = a.absoluteRotation.rotationMatrix.M43;
		absoluteRotation.rotationMatrix.M44 = a.absoluteRotation.rotationMatrix.M44;
		
		absoluteRotation.rotationQuaternion.x = a.absoluteRotation.rotationQuaternion.x; 
		absoluteRotation.rotationQuaternion.y = a.absoluteRotation.rotationQuaternion.y;
		absoluteRotation.rotationQuaternion.z = a.absoluteRotation.rotationQuaternion.z;
				
	}
	
}
