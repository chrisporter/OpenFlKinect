package ;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import interactions.HandType;
import motion.easing.Linear;
import openfl.Assets;
import motion.Actuate;
import flash.geom.ColorTransform;
import flash.display.BitmapData;
import flash.utils.ByteArray;

/**
 * ...
 * @author Chris Porter
 */
class Hand extends Sprite
{
	var closed:Bitmap;
	var closedIntenal:Bitmap;
	var open:Bitmap;
	var openProgress:Bitmap;
	var progress:Sprite;
	var openBack:Bitmap;
	var bmdMask:BitmapData;
	var bmdProgress:BitmapData;
	var s:flash.display.Shape;
	
	public var gripStart(get, null):Bool = false;
	public var gripEnd(get, null):Bool = false;
	public var dragging = false;
	public var dragTarget(default, default):DisplayObject;
	
	
	public var pressedAmount(default, set):Float;
	public var pressed:Bool = true; // need to pull hand back initially
	public var gripped(default, set):Bool;
	public var colour(null, set):Int;
	
	public function new(size:HandSize, handType) 
	{
		super();
		
		var ex = "";
		
		switch ( size )
		{
			case HandSize.Small:
				ex = "_25";
			case HandSize.Medium:
				ex = "_50";
			case HandSize.Large:
				ex = "_75";
			default:
				
		}
		
		this.closed = new Bitmap(Assets.getBitmapData('img/closed_hand$ex.png'));
		this.closedIntenal = new Bitmap(Assets.getBitmapData('img/closed_hand_internal$ex.png'));
		
		this.open = new Bitmap(Assets.getBitmapData('img/open_hand$ex.png'));
		this.openProgress = new Bitmap(Assets.getBitmapData('img/open_hand_internal$ex.png'));
		this.openBack = new Bitmap(Assets.getBitmapData('img/open_hand_back$ex.png'));
		
		bmdMask = Assets.getBitmapData('img/open_hand_internal$ex.png');
		bmdProgress = new BitmapData(bmdMask.width, bmdMask.height, true, 0x0);
		
		progress = new Sprite();
		progress.addChild( new Bitmap(bmdProgress));
		
		this.open.x = -this.open.width / 2;
		this.open.y = -this.open.height / 2;
		this.closed.x = -this.closed.width / 2;
		this.closed.y = -this.closed.height / 2;
		this.closedIntenal.x = -this.closedIntenal.width / 2;
		this.closedIntenal.y = -this.closedIntenal.height / 2;
		this.openProgress.x = this.open.x;
		this.openProgress.y = this.open.y;
		this.openBack.x = this.open.x;
		this.openBack.y = this.open.y;
		this.progress.x = this.open.x;
		this.progress.y = this.open.y;
		
		//openProgress.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 255, 255, 255, 1);
		
		this.closed.visible = false;
		this.closedIntenal.visible = false;
		
		addChild(this.openBack);
		addChild(this.openProgress);
		//addChild(progress);
		addChild(this.open);
		
		addChild(this.closed);
		addChild(this.closedIntenal);
		
		//this.progress.blendMode = BlendMode.LIGHTEN;
		//progress.mask = openProgress;
		//progress.cacheAsBitmap = true;
		//openProgress.cacheAsBitmap = true;
		//progress.alpha = 0.0;
		
		if ( handType == HandType.NUI_HAND_TYPE_LEFT )
		{
			this.scaleX = -1;
		}
	}
	
	private function set_gripped(val)
	{
		this.gripped = val;
		closed.visible = this.gripped;
		closedIntenal.visible = this.gripped;
		this.open.visible = ! this.gripped;
		//this.openProgress.visible = ! this.gripped;
		this.progress.visible = ! this.gripped;
		this.openProgress.visible = ! this.gripped;
		this.openBack.visible = ! this.gripped;
		gripStart = val;
		gripEnd = ! val;
		dragging = val;
		return this.gripped;
	}
	
	private function get_gripStart()
	{
		var ret = gripStart;
		gripStart = false;
		return ret;
	}
	
	private function get_gripEnd()
	{
		var ret = gripEnd;
		gripEnd = false;
		return ret;
	}
	
	private function set_pressedAmount(val:Float)
	{
		var tr = this.open.height;
		
		val = Math.min(1.0, val);
		if ( val < 0.5 )
		{
			pressed = false;
		}
		//progress.graphics.clear();
		//progress.graphics.beginFill(0x4800FF);
		//progress.graphics.drawCircle(0, open.height/2, val * open.height);
		//progress.graphics.endFill();
		//s = new Shape();
		//s.graphics.clear();
		//s.graphics.beginFill(0x000000, .75);
		//s.graphics.drawCircle(bmdMask.width / 2, bmdMask.height, val * open.height);
		//s.graphics.endFill();
		//
		//bmdProgress.fillRect(bmdProgress.rect, 0x00000000);
		//bmdProgress.draw(s);
		//applyAlphaMask(bmdProgress, bmdMask, false);
		
		//this.openProgress.alpha  = val;
		
		this.openProgress.scaleX = this.openProgress.scaleY = val;
		this.openProgress.x = -this.openProgress.width / 2;
		this.openProgress.y = -this.openProgress.height / 2;
		
		pressedAmount = val;
		return pressedAmount;
	}
	
	private function set_colour(c)
	{
		var r = (( c >> 16 ) & 0xFF) / 255.0;
		var g = ( (c >> 8) & 0xFF ) / 255;
		var b = ( c & 0xFF ) / 255;
		openBack.transform.colorTransform = new ColorTransform(r, g, b, 1, 0, 0, 0, 0);
		closedIntenal.transform.colorTransform = new ColorTransform(r, g, b, 1, 0, 0, 0, 0);
		//hand.transform.colorTransform = new ColorTransform(r, g, b, 1, 0, 0, 0, 0);
		return c;
	}
	
	/**
	 * Masks the `source` BitmapData (in place) using alpha data from `alphaMask`.
	 * 
	 * Note: `source` and `alphaMask` must be of the same size.
	 * 
	 * @param	source		BitmapData to be masked.
	 * @param	alphaMask	BitmapData to be used as mask.
	 * @param	copyAlpha	If true the alpha value of `alphaMask` will be copied over to `source`.
	 */
	public static function applyAlphaMask(source:BitmapData, alphaMask:BitmapData, copyAlpha:Bool = false):Void 
	{
		var sourceRect = source.rect;
		var sourceBytes:ByteArray = source.getPixels(sourceRect);
		var alphaMaskBytes:ByteArray = alphaMask.getPixels(sourceRect);
		
		sourceBytes.position = 0;
		alphaMaskBytes.position = 0;
		
		var nPixels:Int = Std.int(sourceRect.width * sourceRect.height);
		var sourceAlpha:Int = 0;
		var maskAlpha:Int = 0;
		var alphaIdx:Int = 0;
		
		for (idx in 0...nPixels) {
			alphaIdx = idx << 2;
			maskAlpha = alphaMaskBytes[alphaIdx];
			sourceAlpha = sourceBytes[alphaIdx];
			sourceBytes[alphaIdx] = copyAlpha ? maskAlpha : sourceAlpha * (maskAlpha > 0 ? 1 : 0);
		}
		
		source.setPixels(sourceRect, sourceBytes);
	}
}
