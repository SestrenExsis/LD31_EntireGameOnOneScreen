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
		
		protected var lens:MagnifyingGlass;
		protected var entities:FlxGroup;
		
		public function Radar(Lens:MagnifyingGlass, Entities:FlxGroup)
		{
			super(0, 0);
			
			loadGraphic(imgRadar);
			radarMask = FlxG.addBitmap(imgRadarMask);
			focalPoint = new FlxPoint();
			
			lens = Lens;
			entities = Entities;
		}
		
		public function renderEntities():void
		{
			if (entities)
			{
				var dx:Number = focalPoint.x - posX;
				var dy:Number = focalPoint.y - posY;
				var _distance:Number = Math.sqrt(dx * dx + dy * dy);
				var _entity:Entity;
				for (var i:int = 0; i < entities.length; i++)
				{
					
					if (_entity.
				}
			}
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		override public function draw():void
		{
			if(_flickerTimer != 0)
			{
				_flicker = !_flicker;
				if(_flicker)
					return;
			}
			
			if(dirty)	//rarely 
				calcFrame();
			
			if(cameras == null)
				cameras = FlxG.cameras;
			var camera:FlxCamera;
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
			{
				camera = cameras[i++];
				if(!onScreen(camera))
					continue;
				_intersect.x = posX - int(camera.scroll.x*scrollFactor.x) - offset.x;
				_intersect.y = posY - int(camera.scroll.y*scrollFactor.y) - offset.y;
				_intersect.x += (_intersect.x > 0)?0.0000001:-0.0000001;
				_intersect.y += (_intersect.y > 0)?0.0000001:-0.0000001;
				
				_flashPoint.x = _intersect.x;
				_flashPoint.y = _intersect.y;
				
				camera.buffer.copyPixels(pixels, _flashRect, _flashPoint, null, null, true); // Draw the radar backdrop
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, radarMask, _flashPointZero, true); // Draw the dots
				
				if(FlxG.visualDebug && !ignoreDrawDebug)
					drawDebug(camera);
			}
			framePixels.fillRect(_flashRect, 0x00000000); // Clear all the dots
		}
	}
}