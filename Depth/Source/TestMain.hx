package ;
import haxe.unit.TestRunner;

/**
 * ...
 * @author Chris Porter
 */
class TestMain
{

	public function new() 
	{
		var r = new TestRunner();
        r.add(new Tests());
        r.run();
	}
	
}