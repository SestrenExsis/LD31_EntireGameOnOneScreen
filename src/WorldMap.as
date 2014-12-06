package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class WorldMap extends FlxSprite
	{
		[Embed(source="../assets/images/Tiles.png")] protected var imgTiles:Class;
		
		public var lens:MagnifyingGlass;
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
			var _odd:uint = 0x003300;
			var _even:uint = 0x006600;
			
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
			_flashPoint.setTo(posX, posY);
			FlxG.camera.buffer.copyPixels(tiles, _flashRect, _flashPoint, null, null, true);
		}
		
		/*override public function draw():void
		{
			var _view:Rectangle = lens.mapRect;
			
			var _corner:Boolean = false;
			var _magnified:Boolean = false;
			if (lens)
			{
				_corner = ((posX == _view.left || posX == _view.right - 1) && (posY == _view.top || posY == _view.bottom - 1));
				_magnified = _view.contains(posX, posY) && !_corner;
			}
			
			if (_magnified)
			{
				var x:Number = posX;
				var y:Number = posY;
				
				posX = lens.lensRect.x + MagnifyingGlass.ZOOM * (x - _view.x);
				posY = lens.lensRect.y + MagnifyingGlass.ZOOM * (y - _view.y);
				
				if(dirty)
					calcFrame();
				
				_flashPoint.x = posX;
				_flashPoint.y = posY;
				
				_flashPointZero.setTo(posX - lens.posX, posY - lens.posY);
				FlxG.camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, lens.lensMask, _flashPointZero, true);
				_flashPointZero.setTo(0, 0);
				
				if(FlxG.visualDebug && !ignoreDrawDebug)
					drawDebug(FlxG.camera);
				
				posX = x;
				posY = y;
			}
			else
				FlxG.camera.buffer.setPixel(map.posX + posX, map.posY + posY, color);
		}*/
	}
}