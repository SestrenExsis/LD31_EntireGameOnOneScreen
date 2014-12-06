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
					tiles.setPixel(x, y, assignColor(x, y));
				}
			}
		}
		
		protected function assignColor(X:int, Y:int):uint
		{
			var _x:int = Math.floor(X / 8);
			var _y:int = Math.floor(Y / 8);
			var _odd:uint = 0x9cc98e;
			var _even:uint = 0x81ba28;
			
			if (((_x + _y) % 2) == 0)
				return _even;
			else
				return _odd;
		}
		
		protected function getMapTile(X:int, Y:int):void
		{
			_flashRect.setTo(0, 0, 8, 8);
			if (X >= 0 && X < widthInTiles && Y >= 0 && Y < heightInTiles)
			{
				var _pixel:uint = tiles.getPixel(X, Y);
				switch (_pixel)
				{
					case 0x9cc98e: _flashRect.x = 16; break;
					case 0x81ba28: _flashRect.x = 24; break;
				}
			}
			else
				_flashRect.x = 0;
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
			
			if (lens)
			{
				var _view:Rectangle = lens.mapRect;
				var _magnified:Boolean = false;
				for (var y:int = _view.top; y < _view.bottom; y++)
				{
					for (var x:int = _view.left; x < _view.right; x++)
					{
						_magnified = !((posX == _view.left || posX == _view.right - 1) 
							&& (posY == _view.top || posY == _view.bottom - 1));
						
						if (_magnified)
						{
							getMapTile(x, y);
							_flashPoint.x = lens.lensRect.x + MagnifyingGlass.ZOOM * (x - _view.x);
							_flashPoint.y = lens.lensRect.y + MagnifyingGlass.ZOOM * (y - _view.y);
							_flashPointZero.setTo(_flashPoint.x - lens.posX, _flashPoint.y - lens.posY);
							FlxG.camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, lens.lensMask, _flashPointZero, true);
						}
					}
				}
				_flashPointZero.setTo(0, 0);
			}
		}
	}
}