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
			
			if (Y > 0.5 * map.heightInTiles)
				color = 0x00ffff;
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
				FlxG.camera.buffer.setPixel(map.posX + posX, map.posY + posY, color);
		}
	}
}