package
{
	import flash.display.BitmapData;
	
	import org.flixel.*;
		
	public class WorldMap extends FlxSprite
	{
		[Embed(source="../assets/images/Tiles.png")] protected var imgTiles:Class;
		
		public var widthInTiles:uint;
		public var heightInTiles:uint;
		public var tiles:BitmapData;
		
		public function WorldMap(X:Number, Y:Number, WidthInTiles:uint, HeightInTiles:uint)
		{
			super(X, Y);
			
			loadGraphic(imgTiles);
			
			widthInTiles = WidthInTiles;
			heightInTiles = HeightInTiles;
			
			tiles = FlxG.createBitmap(widthInTiles, heightInTiles, 0xffff0000);
			
			for (var y:int = 0; y < heightInTiles; y++)
			{
				for (var x:int = 0; x < widthInTiles; x++)
				{
					tiles.setPixel(x, y, randomColor(x, y));
				}
			}
		}
		
		protected function randomColor(X:int, Y:int):uint
		{
			var _odd:uint = 0xffffff;
			var _even:uint = 0xffffff;
			
			if (((X + Y) % 2) == 0)
				return _even;
			else
				return _odd;
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		override public function draw():void
		{
			
			_flashRect.setTo(0, 0, widthInTiles, heightInTiles);
			_flashPoint.setTo(0, 0);
			FlxG.camera.buffer.fillRect(_flashRect, 0xffffffff);
			FlxG.camera.buffer.copyPixels(tiles, _flashRect, _flashPoint, null, null, true);
		}
	}
}