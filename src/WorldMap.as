package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class WorldMap extends FlxSprite
	{
		[Embed(source="../assets/images/Tiles.png")] protected var imgTiles:Class;
		[Embed(source="../assets/images/WorldMap.png")] protected var imgMap:Class;
		
		public static const COLOR_BACKGROUND:uint = 0x105c68;
		public static const COLOR_LIGHT:uint = 0x9cc98e;
		public static const COLOR_DARK:uint = 0x81ba28;
		public static const COLOR_EDGE_LIGHT:uint = 0x999999;
		public static const COLOR_EDGE_DARK:uint = 0x808080;
		public static const COLOR_RADAR_LIGHT:uint = 0xfeffff;
		public static const COLOR_RADAR_DARK:uint = 0x00262d;
		
		public var lens:MagnifyingGlass;
		public var widthInTiles:uint;
		public var heightInTiles:uint;
		public var tiles:BitmapData;
		public var worldRect:FlxRect;
		public var instructionPos:FlxPoint;
		public var radarPos:FlxPoint;
		
		public function WorldMap()
		{
			super(0, 0);
			
			loadGraphic(imgTiles);
			
			tiles = FlxG.addBitmap(imgMap);
			widthInTiles = tiles.width;
			heightInTiles = tiles.height;
			worldRect = new FlxRect(64, 64, 112, 112);
			instructionPos = new FlxPoint(48, 64);
			radarPos = new FlxPoint(176, 2);
		}
		
		protected function getMapTile(X:int, Y:int):void
		{
			_flashRect.setTo(0, 0, 8, 8);
			if (X >= 0 && X < widthInTiles && Y >= 0 && Y < heightInTiles)
			{
				var _pixel:uint = tiles.getPixel(X, Y);
				switch (_pixel)
				{
					case COLOR_BACKGROUND: _flashRect.x = 0; break;
					case COLOR_LIGHT: _flashRect.x = 8; break;
					case COLOR_DARK: _flashRect.x = 16; break;
					case COLOR_EDGE_LIGHT: _flashRect.x = 24; break;
					case COLOR_EDGE_DARK: _flashRect.x = 32; break;
					case COLOR_RADAR_LIGHT: _flashRect.x = 40; break;
					case COLOR_RADAR_DARK: _flashRect.x = 48; break;
					default: getInstructionTile(X, Y); break;
				}
			}
			else
				_flashRect.x = 0;
		}
		
		protected function getInstructionTile(X:int, Y:int):void
		{
			_flashRect.x = 8 * (X - instructionPos.x);
			_flashRect.y = 8 + 8 * (Y - instructionPos.y);
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
							_flashPoint.x = lens.lensRect.x + lens.magnifyOffset.x + MagnifyingGlass.ZOOM * (x - _view.x);
							_flashPoint.y = lens.lensRect.y + lens.magnifyOffset.y + MagnifyingGlass.ZOOM * (y - _view.y);
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