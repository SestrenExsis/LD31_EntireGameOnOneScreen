package
{
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class Entity extends FlxSprite
	{
		[Embed(source="../assets/images/Tiles.png")] protected var imgTiles:Class;
		
		public var map:WorldMap;
		public var lens:MagnifyingGlass;
		
		public function Entity(Map:WorldMap, Lens:MagnifyingGlass, X:int, Y:int)
		{
			super(X, Y);
			
			map = Map;
			lens = Lens;
			loadGraphic(imgTiles, true, false, MagnifyingGlass.ZOOM, MagnifyingGlass.ZOOM);
			frame = 1;
			
			if (Y > 0.5 * map.heightInTiles)
				color = 0x0088ff;
			else
				color = 0xff0000;
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		override public function draw():void
		{
			var _view:Rectangle = lens.mapRect;
			var _corner:Boolean = ((posX == _view.left || posX == _view.right - 1) && (posY == _view.top || posY == _view.bottom - 1));
			var _magnified:Boolean = _view.contains(posX, posY) && !_corner;
			
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
			{
				var dx:Number = FlxG.mouse.x - 34 - posX;
				var dy:Number = FlxG.mouse.y - 34 - posY;
				var _distance:Number = Math.sqrt(dx * dx + dy * dy);
				
				var _offsetX:uint = 0;
				var _offsetY:uint = 0;
				if (_distance < 31)
				{
					_offsetX = 274 + posX - lens.lensRect.x;
					_offsetY = 48 + posY - lens.lensRect.y;
					FlxG.camera.buffer.setPixel(_offsetX, _offsetY, color);
				}
				else if (_distance >= 33)
				{
					_offsetX = map.posX + posX;
					_offsetY = map.posY + posY;
					FlxG.camera.buffer.setPixel(_offsetX, _offsetY, color);
				}
			}
		}
	}
}