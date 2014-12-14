package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class MagnifyingGlass extends FlxSprite
	{
		[Embed(source="../assets/images/MagnifyingGlass.png")] protected var imgMagnifyingGlass:Class;
		[Embed(source="../assets/images/LensMask.png")] protected var imgLensMask:Class;
		
		public static const ZOOM:Number = 8;
		
		public static const SPELL_BLESS:uint = 0;
		public static const SPELL_SMITE:uint = 1;
		
		public static const BLESS_COOLDOWN:Number = 1.5;
		public static const SMITE_COOLDOWN:Number = 1.5;
		
		public var blessLevel:Number = 0;
		public var blessCharge:Number = 0;
		public var smiteLevel:Number = 0;
		public var smiteCharge:Number = 0;
		
		public var map:WorldMap;
		public var mapRect:Rectangle;
		public var lensRect:Rectangle;
		public var lensMask:BitmapData;
		public var magnifyOffset:FlxPoint;
		public var currentPos:FlxPoint;
		
		public var blessInfo:FlxText;
		public var smiteInfo:FlxText;
		
		protected var fillHeightA:Number;
		protected var fillHeightB:Number;
		protected var targetPos:FlxPoint;
		protected var targetVelocity:FlxPoint;
		
		public function MagnifyingGlass(Map:WorldMap = null)
		{
			super(0, 0);
			
			loadGraphic(imgMagnifyingGlass, true, false, 86, 120);
			lensMask = FlxG.addBitmap(imgLensMask);
			mapRect = new Rectangle(0, 0, 10, 10);
			lensRect = new Rectangle(0, 0, 64, 64);
			blessInfo = new FlxText(0, 0, 128, "");
			blessInfo.alignment = "left";
			smiteInfo = new FlxText(0, 0, 128, "");
			smiteInfo.alignment = "left";
			
			if (Map)
			{
				map = Map;
				map.lens = this;
			}
			
			currentPos = new FlxPoint(ZOOM * FlxG.mouse.x, ZOOM * FlxG.mouse.y);
			targetPos = new FlxPoint();
			targetVelocity = new FlxPoint();
			magnifyOffset = new FlxPoint();
		}
		
		private function updateTarget(Mass:Number, Stiffness:Number, Damping:Number):void
		{
			targetPos.x = ZOOM * FlxG.mouse.x;
			targetPos.y = ZOOM * FlxG.mouse.y;
			
			var _force:Number = (targetPos.x - currentPos.x) * Stiffness;
			var _factor:Number = _force / Mass;
			targetVelocity.x = Damping * (targetVelocity.x + _factor);
			currentPos.x += targetVelocity.x;
			
			_force = (targetPos.y - currentPos.y) * Stiffness;
			_factor = _force / Mass;
			targetVelocity.y = Damping * (targetVelocity.y + _factor);
			currentPos.y += targetVelocity.y;
			
			posX = Math.floor(currentPos.x / ZOOM);
			magnifyOffset.x = posX * ZOOM - currentPos.x;
			posY = Math.floor(currentPos.y / ZOOM);
			magnifyOffset.y = posY * ZOOM - currentPos.y;
			
			if (map)
			{
				mapRect.x = posX - 0.5 * mapRect.width - map.posX;
				mapRect.y = posY - 0.5 * mapRect.height - map.posY;
			}
			
			posX -= 34;
			posY -= 34;
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			
			if (FlxG.keys.justPressed("SPACE"))
				frame = (frame == SPELL_BLESS) ? SPELL_SMITE : SPELL_BLESS;
		}
		
		override public function update():void
		{	
			super.update();
			
			updateTarget(3.0, 0.4, 0.4);
			
			lensRect.x = posX + 2;
			lensRect.y = posY + 2;
		}
		
		override public function draw():void
		{
			super.draw();
			
			blessInfo.posX = 89 + posX;
			blessInfo.posY = 46 + posY;
			blessInfo.text = blessLevel.toString();
			blessInfo.draw();
			
			fillHeightA = Math.round(16 * (blessCharge / (BLESS_COOLDOWN - 0.1 * FlxG.level)));
			_flashRect.setTo(posX + 87, posY + 46 + 16 - fillHeightA, 1, fillHeightA);
			FlxG.camera.buffer.fillRect(_flashRect, 0xffffffff);
			
			smiteInfo.posX = 89 + posX;
			smiteInfo.posY = 64 + posY;
			smiteInfo.text = smiteLevel.toString();
			smiteInfo.draw();
			
			fillHeightB = Math.round(16 * (smiteCharge / (SMITE_COOLDOWN - 0.1 * FlxG.level)));
			_flashRect.setTo(posX + 87, posY + 64 + 16 - fillHeightB, 1, fillHeightB);
			FlxG.camera.buffer.fillRect(_flashRect, 0xffffffff);
			
			_flashRect.setTo(0, 0, frameWidth, frameHeight);
		}
	}
}