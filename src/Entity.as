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
			loadGraphic(imgTiles, true, false, 16, 16);
			
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
			var _viewRect:Rectangle = lens.mapRect;
			var _magnified:Boolean = _viewRect.contains(posX, posY) 
				&& (posX != _viewRect.left || posX != _viewRect.right) && (posY != _viewRect.top || posY != _viewRect.bottom);
			
			if (_magnified)
			{
				var x:Number = posX;
				var y:Number = posY;
				
				posX = lens.lensRect.x + 16 * (x - _viewRect.x);
				posY = lens.lensRect.y + 16 * (y - _viewRect.y);
				
				super.draw();
				
				posX = x;
				posY = y;
			}
			else
			{
				_flashRect.setTo(posX * 2, posY * 2, 2, 2);
				var _argb:uint = (255 << 24) | color;
				FlxG.camera.buffer.fillRect(_flashRect, _argb);
				_flashRect.setTo(0, 0, 16, 16);
			}
		}
	}
}