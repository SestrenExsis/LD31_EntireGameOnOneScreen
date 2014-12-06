package
{
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class MagnifyingGlass extends FlxSprite
	{
		[Embed(source="../assets/images/MagnifyingGlass.png")] protected var imgMagnifyingGlass:Class;
		
		public var mapRect:Rectangle;
		public var lensRect:Rectangle;
		public var zoom:int;
		
		public function MagnifyingGlass()
		{
			super(0, 0);
			
			loadGraphic(imgMagnifyingGlass);
			mapRect = new Rectangle(0, 0, 8, 8);
			lensRect = new Rectangle(0, 0, 128, 128);
			zoom = 8;
			
			FlxG.watch(mapRect, "x");
			FlxG.watch(mapRect, "y");
			FlxG.watch(lensRect, "x");
			FlxG.watch(lensRect, "y");
		}
		
		override public function update():void
		{	
			super.update();
			
			var x:int = Math.floor(0.5 * (FlxG.mouse.x - 67));
			var y:int = Math.floor(0.5 * (FlxG.mouse.y - 67));
			posX = 2 * x;
			posY = 2 * y;
			
			mapRect.x = 0.5 * FlxG.mouse.x - 0.5 * zoom;
			mapRect.y = 0.5 * FlxG.mouse.y - 0.5 * zoom;
			lensRect.x = posX + 3;
			lensRect.y = posY + 3;
		}
	}
}