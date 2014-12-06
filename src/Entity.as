package
{
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class Entity extends FlxSprite
	{
		[Embed(source="../assets/images/Entity.png")] protected var imgEntity:Class;
		
		public static const BLUE_TEAM:int = -1;
		public static const NEUTRAL_TEAM:int = 0;
		public static const RED_TEAM:int = 1;
		
		public var map:WorldMap;
		public var lens:MagnifyingGlass;
		
		protected var _team:int = 0;
		protected var _offsetRemaining:FlxPoint;
		
		public function Entity(Map:WorldMap, Lens:MagnifyingGlass, X:int, Y:int)
		{
			super(X, Y);
			
			moves = false;
			
			map = Map;
			lens = Lens;
			loadGraphic(imgEntity, true, false, MagnifyingGlass.ZOOM, MagnifyingGlass.ZOOM);
			addAnimation("bad_idle", [0]);
			addAnimation("bad_angry", [1, 0, 2, 0, 0, 0, 0, 0], 2, true);
			addAnimation("good_idle", [3]);
			addAnimation("good_angry", [4, 3, 5, 3, 3, 3, 3, 3], 2, true);
			
			_offsetRemaining = new FlxPoint();
			width = height = 1;
			
			if (Y > 0.5 * map.heightInTiles)
				team = BLUE_TEAM;
			else
				team = RED_TEAM;
		}
		
		public function get team():int
		{
			return _team;
		}
		
		public function set team(Value:int):void
		{
			if (_team == Value)
				return;
			
			_team = Value;
			
			if (_team == BLUE_TEAM)
			{
				color = 0x0088ff;
				play("good_angry", true);
			}
			else if (_team == RED_TEAM)
			{
				color = 0xff0000;
				play("bad_angry", true);
			}
			
			_curFrame += Math.floor(8 * FlxG.random());
		}
		
		public function updateAction():void
		{
			last.y = posY;
			posY += team;
			_offsetRemaining.y -= 8 * team;
		}
		
		public function undoLastMove():void
		{
			posY = last.y;
			_offsetRemaining.y = 0;
		}
		
		public function attack(Target:Entity):Boolean
		{
			return false;
		}
		
		override public function update():void
		{	
			super.update();
			
			if (_offsetRemaining.x != 0)
				_offsetRemaining.x += (_offsetRemaining.x < 0) ? 1 : -1;
			if (_offsetRemaining.y != 0)
				_offsetRemaining.y += (_offsetRemaining.y < 0) ? 1 : -1;
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
				
				_flashPoint.x = posX + _offsetRemaining.x;
				_flashPoint.y = posY + _offsetRemaining.y;
				
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