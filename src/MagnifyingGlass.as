package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class MagnifyingGlass extends FlxSprite
	{
		[Embed(source="../assets/images/MagnifyingGlass.png")] protected var imgMagnifyingGlass:Class;
		[Embed(source="../assets/images/LensMask.png")] protected var imgLensMask:Class;
		
		public static const ZOOM:int = 8;
		
		public var map:WorldMap;
		
		public var mapRect:Rectangle;
		public var lensRect:Rectangle;
		public var lensMask:BitmapData;
		
		public function MagnifyingGlass(Map:WorldMap = null)
		{
			super(0, 0);
			
			loadGraphic(imgMagnifyingGlass);
			lensMask = FlxG.addBitmap(imgLensMask);
			mapRect = new Rectangle(0, 0, 8, 8);
			lensRect = new Rectangle(0, 0, 128, 128);
			
			if (Map)
			{
				map = Map;
				map.lens = this;
			}
		}
		
		override public function update():void
		{	
			super.update();
			
			posX = FlxG.mouse.x - 34;
			posY = FlxG.mouse.y - 34;
			
			if (map)
			{
				mapRect.x = FlxG.mouse.x - 0.5 * mapRect.width - map.posX;
				mapRect.y = FlxG.mouse.y - 0.5 * mapRect.height - map.posY;
			}
			
			lensRect.x = posX + 2;
			lensRect.y = posY + 2;
		}
	}
}