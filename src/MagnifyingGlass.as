package
{
	import org.flixel.*;
		
	public class MagnifyingGlass extends FlxSprite
	{
		[Embed(source="../assets/images/MagnifyingGlass.png")] protected var imgMagnifyingGlass:Class;
		
		public function MagnifyingGlass()
		{
			super(0, 0);
			
			loadGraphic(imgMagnifyingGlass);
		}
		
		override public function update():void
		{	
			super.update();
			
			posX = FlxG.mouse.x - 67;
			posY = FlxG.mouse.y - 67;
		}
	}
}