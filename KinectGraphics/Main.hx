import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import openfl.Assets;
import interactions.HandType;
import openfl.Assets;
import flash.utils.ByteArray;
#if cpp
import cpp.Lib;
#end
import openfl.display.FPS;

class Main extends Sprite 
{	
	var h:Hand;
	var progress:Float = 0.0;
	var mousePress:Bool = false;
	
	public function new () 
	{
		super ();
		addChild(new FPS());
		
		//addEventListener(Event.ENTER_FRAME, run);
		
		
		//var hand = new Bitmap( Assets.getBitmapData('img/open_hand_75.png') );
		//addChild(hand);
		//
		//var progress = new Sprite();
		//addChild(progress);
		//progress.graphics.clear();
		//progress.graphics.beginFill(0x4800FF);
		//progress.graphics.drawCircle(hand.width/2, hand.height/2, 0.5 * hand.height);
		//progress.graphics.endFill();
		//
		//progress.cacheAsBitmap = true;
		//hand.cacheAsBitmap = true;
		//progress.blendMode = BlendMode.SUBTRACT;
		//progress.mask = hand;
		
		
		h = new Hand(HandSize.Medium, HandType.NUI_HAND_TYPE_RIGHT );
		h.colour = 0x00ff00;
		addChild(h);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		addEventListener(Event.ENTER_FRAME, run);
		
		/*
		var s = new Shape();
		s.graphics.beginFill(0x0000ff);
		s.graphics.drawCircle(150, 150, 150);
		s.graphics.endFill();
		
		var bmdBack = new BitmapData(Std.int(s.width), Std.int(s.height), true, 0xff000000);
		bmdBack.draw(s);
		
		//addChild(new Bitmap(bmdBack));
		
		var bmdMask = Assets.getBitmapData('img/open_hand_internal_50.png');
		
		var bmMask = new Bitmap(bmdMask);
		bmMask.x = bmdBack.width;
		//addChild(bmMask);
		
		var opposite = new BitmapData(bmdBack.width, bmdBack.height, true, 0x0);
		xor(bmdBack, bmdMask, opposite);
		
		var opp = new Bitmap(opposite);
		opp.x = bmMask.x + bmMask.width;
		//addChild(opp);
		
		var final = new BitmapData(bmdBack.width, bmdBack.height, true, 0xff000000);
		
		xor(opposite, final, final);
		
		var bmpFinal = new Bitmap(final);
		
		var opp = new Bitmap(opposite);
		var bmBack = new Bitmap(bmdBack);
		var bmMask = new Bitmap(bmdMask);
		bmBack.mask = bmMask;
		bmBack.cacheAsBitmap = true;
		bmMask.cacheAsBitmap = true;
		addChild(bmBack);*/
				
		//addChild(new Bitmap(bmdBack));
		
		//var bmdMask = Assets.getBitmapData('img/mask_50.png');
		//
		//var s = new Shape();
		//s.graphics.beginFill(0x00000000);
		//s.graphics.drawRect(0, 0, bmdMask.width, bmdMask.height);
		//s.graphics.endFill();
		//s.graphics.beginFill(0x0000ff);
		//s.graphics.drawCircle(bmdMask.width / 2, bmdMask.height / 2, 30);
		//s.graphics.endFill();
		//
		//var bmdBack = new BitmapData(Std.int(bmdMask.width), Std.int(bmdMask.height), true, 0x00000000);
		//bmdBack.draw(s);
		//
		//applyAlphaMask(bmdBack, bmdMask, false);
		//var bmBack = new Bitmap(bmdBack);
		//addChild(bmBack);
		//
		//var i = 0;
		//addEventListener(Event.ENTER_FRAME, function(e)
		//{
			//i = ++i % Std.int(Math.max(bmdMask.width, bmdMask.height)/2);
			//trace(i);
			//s.graphics.clear();
			//s.graphics.beginFill(0x0000ff);
			//s.graphics.drawCircle(bmdMask.width / 2, bmdMask.height / 2, i);
			//s.graphics.endFill();
			//bmdBack.fillRect(bmdBack.rect, 0x00000000);
			//bmdBack.draw(s);
			//applyAlphaMask(bmdBack, bmdMask, false);
			//
		//});
		
		
		//bmpFinal.x = opp.x + opp.width;
		//addChild(bmpFinal);
		
		//var i = 0;
		//var j = 0;
		//addEventListener(Event.ENTER_FRAME, function(e)
		//{
			//if ( j++ % 20 != 0 )
				//return;
				//
			//var s = new Shape();
			//s.graphics.beginFill(0x0000ff);
			//s.graphics.drawCircle(150, i, i);
			//s.graphics.endFill();
			//i = i+=5 % 150;
			//bmdBack.fillRect(bmdBack.rect, 0x000000);
			//bmdBack.draw(s);
			//opposite.fillRect(opposite.rect, 0x0);
			//final.fillRect(final.rect, 0x0);
			//xor(bmdBack, bmdMask, opposite);
			//xor(opposite, bmdBack, final);
		//});
		
		
		
		//
		//var ks = new KinectStatusView(); 
		//addChild(ks);
		//ks.x = (600 - ks.width) / 2;
		//ks.status = KinectStatus.SensorNotGenuine;
		
		//var b = new ListButton(5);
		//b.x = b.y = 200;
		//addChild(b);
		//b.addEventListener(MouseEvent.MOUSE_OVER, function(e)
		//{
			//b.grow();
		//});
		//b.addEventListener(MouseEvent.MOUSE_OUT, function(e)
		//{
			//b.shrink();
		//});
		
		//var b = new NavButton(true);
		//b.x = b.y = 200;
		//addChild(b);
		//b.addEventListener(MouseEvent.MOUSE_OVER, function(e)
		//{
			//b.grow();
		//});
		//b.addEventListener(MouseEvent.MOUSE_OUT, function(e)
		//{
			//b.shrink();
		//});
		
		//var s = new ScrollView(640);
		//addChild(s);
		//addEventListener(MouseEvent.MOUSE_DOWN, s.mouseDown);
		//addEventListener(MouseEvent.MOUSE_UP, s.mouseUp);
		//s.addEventListener(MouseEvent.MOUSE_OVER, function(e)
		//{
			//trace("aadds");
		//});
		//s.addEventListener(MouseEvent.MOUSE_OUT, function(e)
		//{
			//trace("asdas");
		//});
	}
	
	private function xor(bmd1:BitmapData, bmd2:BitmapData, bmdOut:BitmapData)
	{
		for (i in 0...bmd1.width)
		{
			for (j in 0...bmd1.height)
			{
				bmdOut.setPixel32(i, j, (bmd1.getPixel32(i, j) ^ bmd2.getPixel32(i, j)));
			}
		}
	}
	
	private function run(e:Event) 
	{
		if ( mousePress )
		{
			progress += 0.1;
			progress = progress > 1.0 ? 1.0 : progress;
		}
		else
		{
			progress -= 0.1;
			progress = progress < 0.0 ? 0.0 : progress;
		}
		
		h.pressedAmount = progress;
	}
	
	private function mouseUp(e:MouseEvent):Void 
	{
		mousePress = false;
		//h.gripped = false;
	}
	
	private function mouseDown(e:MouseEvent):Void 
	{
		mousePress = true;
		//h.gripped = true;
	}
	
	private function move(e:MouseEvent) 
	{
		h.x = e.stageX;
		h.y = e.stageY;
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