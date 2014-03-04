package ;
import interactions.HandPointer;
import interactions.HandPointerState;
import haxe.EnumFlags;
import interactions.UserInfo;
import interactions.HandType;

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
	
	public function testParse()
	{
		var hpt = Type.createEnumIndex(HandType, 2);
		assertEquals(hpt, HandType.NUI_HAND_TYPE_RIGHT);
	}
    
	public function testFlags()
	{
		var h = new HandPointer();
		var flags = h.handPointerState(6);
		trace("----");
		trace( flags.has(HandPointerState.NUI_HANDPOINTER_STATE_ACTIVE ) );
		trace( flags.has(HandPointerState.NUI_HANDPOINTER_STATE_INTERACTIVE ));
		trace( flags.has(HandPointerState.NUI_HANDPOINTER_STATE_NOT_TRACKED ));
		trace( flags.has(HandPointerState.NUI_HANDPOINTER_STATE_PRESSED ));
		trace( flags.has(HandPointerState.NUI_HANDPOINTER_STATE_PRIMARY_FOR_USER ));
		trace( flags.has(HandPointerState.NUI_HANDPOINTER_STATE_TRACKED ));
		assertTrue(flags.has(HandPointerState.NUI_HANDPOINTER_STATE_ACTIVE) && 
			flags.has(HandPointerState.NUI_HANDPOINTER_STATE_INTERACTIVE));
	}
	
	public function testFlags_none()
	{
		var h = new HandPointer();
		var flags = h.handPointerState(0);

		assertTrue(flags.has(HandPointerState.NUI_HANDPOINTER_STATE_NOT_TRACKED));
	}
}