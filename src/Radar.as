package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class Radar extends FlxSprite
	{
		[Embed(source="../assets/images/Radar.png")] protected var imgRadar:Class;
		[Embed(source="../assets/images/RadarMask.png")] protected var imgRadarMask:Class;
		
		public var radarMask:BitmapData;
		public var focalPoint:FlxPoint;
		public var redTeam:FlxGroup;
		public var blueTeam:FlxGroup;
		
		protected var lens:MagnifyingGlass;
		
		public function Radar(PosX:Number, PosY:Number, Lens:MagnifyingGlass, RedTeam:FlxGroup = null, BlueTeam:FlxGroup = null)
		{
			super(PosX, PosY);
			
			loadGraphic(imgRadar);
			radarMask = FlxG.addBitmap(imgRadarMask);
			focalPoint = new FlxPoint();
			
			lens = Lens;
			redTeam = RedTeam;
			blueTeam = BlueTeam;
		}
		
		public function renderEntities():void
		{
			var i:int;
			var dx:Number;
			var dy:Number;
			var _distance:Number;
			var _entity:Entity;
			var x:int;
			var y:int;
			if (redTeam)
			{
				for (i = 0; i < redTeam.length; i++)
				{
					_entity = redTeam.members[i];
					if (_entity.alive)
					{
						dx = _entity.posX - focalPoint.x;
						dy = _entity.posY - focalPoint.y;
						_distance = Math.sqrt(dx * dx + dy * dy);
						if (_distance <= 0.5 * frameWidth)
						{
							x = 0.5 * frameWidth + (int)(dx);
							y = 0.5 * frameHeight + (int)(dy);
							framePixels.setPixel32(x, y, 255 << 24 | _entity.color);
						}
					}
				}
			}
			
			if (blueTeam)
			{
				for (i = 0; i < blueTeam.length; i++)
				{
					_entity = blueTeam.members[i];
					if (_entity.alive)
					{
						dx = _entity.posX - focalPoint.x;
						dy = _entity.posY - focalPoint.y;
						_distance = Math.sqrt(dx * dx + dy * dy);
						if (_distance <= 0.5 * frameWidth)
						{
							x = 0.5 * frameWidth + (int)(dx);
							y = 0.5 * frameHeight + (int)(dy);
							framePixels.setPixel32(x, y, 255 << 24 | _entity.color);
						}
					}
				}
			}
		}
		
		override public function update():void
		{	
			super.update();
			
			focalPoint.make(Math.floor(lens.currentPos.x / 8) - 1, Math.floor(lens.currentPos.y / 8) - 1);
		}
		
		override public function draw():void
		{
			if(_flickerTimer != 0)
			{
				_flicker = !_flicker;
				if(_flicker)
					return;
			}
			
			if(!onScreen(FlxG.camera))
				return;
			
			_intersect.x = posX - int(FlxG.camera.scroll.x * scrollFactor.x) - offset.x;
			_intersect.y = posY - int(FlxG.camera.scroll.y * scrollFactor.y) - offset.y;
			_intersect.x += (_intersect.x > 0)?0.0000001:-0.0000001;
			_intersect.y += (_intersect.y > 0)?0.0000001:-0.0000001;
			
			_flashPoint.x = _intersect.x;
			_flashPoint.y = _intersect.y;
			
			// Draw the radar backdrop
			FlxG.camera.buffer.copyPixels(pixels, _flashRect, _flashPoint, null, null, true);
			
			// Draw the dots
			renderEntities();
			FlxG.camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, radarMask, _flashPointZero, true);
			
			if(FlxG.visualDebug && !ignoreDrawDebug)
				drawDebug(FlxG.camera);
			
			// Clear all the dots
			framePixels.fillRect(_flashRect, 0x00000000);
		}
	}
}