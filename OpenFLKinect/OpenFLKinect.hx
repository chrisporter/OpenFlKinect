package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end


class OpenFLKinect 
{	
	public static function sampleMethod (inputValue:Int):Int 
	{		
		return openflkinect_sample_method(inputValue);	
	}
	
	
	private static var openflkinect_sample_method = Lib.load ("openflkinect", "openflkinect_sample_method", 1);
}