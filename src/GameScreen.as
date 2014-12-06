package
{
	import org.flixel.*;
		
	public class GameScreen extends FlxState
	{
		protected var player:MagnifyingGlass;
		
		public function GameScreen()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			FlxG.bgColor = 0xffff0000;
			FlxG.mouse.hide();
			
			player = new MagnifyingGlass();
			add(player);
		}
		
		override public function update():void
		{	
			super.update();
		}
	}
}