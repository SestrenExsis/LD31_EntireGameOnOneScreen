package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
		
	public class MagnifyingGlass extends FlxSprite
	{
		[Embed(source="../assets/images/MagnifyingGlass.png")] protected var imgMagnifyingGlass:Class;
		[Embed(source="../assets/images/LensMask.png")] protected var imgLensMask:Class;
		
		public static const ZOOM:int = 8;
		
		public static const SPELL_BLESS:uint = 0;
		public static const SPELL_SMITE:uint = 1;
		
		public static const BLESS_COOLDOWN:Number = 4;
		public static const SMITE_COOLDOWN:Number = 4;
		
		public var blessLevel:uint = 0;
		public var blessCharge:Number = 0;
		public var smiteLevel:uint = 0;
		public var smiteCharge:Number = 0;
		
		public var map:WorldMap;
		public var mapRect:Rectangle;
		public var lensRect:Rectangle;
		public var lensMask:BitmapData;
		
		public var blessInfo:FlxText;
		public var smiteInfo:FlxText;
		
		public function MagnifyingGlass(Map:WorldMap = null)
		{
			super(0, 0);
			
			loadGraphic(imgMagnifyingGlass, true, false, 86, 120);
			lensMask = FlxG.addBitmap(imgLensMask);
			mapRect = new Rectangle(0, 0, 8, 8);
			lensRect = new Rectangle(0, 0, 128, 128);
			blessInfo = new FlxText(0, 0, 128, "");
			blessInfo.alignment = "left";
			smiteInfo = new FlxText(0, 0, 128, "");
			smiteInfo.alignment = "left";
			
			if (Map)
			{
				map = Map;
				map.lens = this;
			}
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			
			blessCharge += FlxG.elapsed * Math.max(0, (1 - 0.1 * blessLevel));
			if (blessCharge > BLESS_COOLDOWN * blessLevel)
				blessLevel++;
			smiteCharge += FlxG.elapsed * Math.max(0, (1 - 0.1 * smiteLevel))
			if (smiteCharge > SMITE_COOLDOWN * smiteLevel)
				smiteLevel++;
			
			if (FlxG.keys.justPressed("SPACE"))
				frame = (frame == SPELL_BLESS) ? SPELL_SMITE : SPELL_BLESS;
		}
		
		override public function update():void
		{	
			super.update();
			
			posX = FlxG.mouse.x - 34;
			posY = FlxG.mouse.y - 34;
			
			if (map)
			{
				mapRect.x = FlxG.mouse.x - 0.5 * mapRect.width - map.posX;
				mapRect.y = FlxG.mouse.y - 0.5 * mapRect.height - map.posY;
			}
			
			lensRect.x = posX + 2;
			lensRect.y = posY + 2;
		}
		
		override public function draw():void
		{
			super.draw();
			
			blessInfo.posX = 86 + posX;
			blessInfo.posY = 46 + posY;
			blessInfo.text = blessLevel.toString();
			blessInfo.draw();
			
			smiteInfo.posX = 86 + posX;
			smiteInfo.posY = 64 + posY;
			smiteInfo.text = smiteLevel.toString();
			smiteInfo.draw();
		}
	}
}