package ;
import interactions.HandPointerState;
import haxe.EnumFlags;
import interactions.UserInfo;

/**
 * ...
 * @author Chris Porter
 */
class Tests extends haxe.unit.TestCase 
{
    
    public function testBasic()
	{
        assertEquals( "A", "A" );
    }
	
	public function testHandPointerState()
	{
		var flags = new EnumFlags<HandPointerState>();
        flags.set(HandPointerState.NUI_HANDPOINTER_STATE_ACTIVE);
        flags.set(HandPointerState.NUI_HANDPOINTER_STATE_INTERACTIVE);
		assertTrue(flags.has(HandPointerState.NUI_HANDPOINTER_STATE_ACTIVE) && 
			flags.has(HandPointerState.NUI_HANDPOINTER_STATE_INTERACTIVE));
	}
	
	public function testUserInfo()
	{
		var x = new UserInfo();
	}
    
}