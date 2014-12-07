package
{
	import org.flixel.FlxGame;
	
	[SWF(width="480", height="480", backgroundColor="#666666")]
	
	public class LD31_EntireGameOnOneScreen extends FlxGame
	{
		public function LD31_EntireGameOnOneScreen()
		{
			super(240, 240, GameScreen, 2.0, 60, 60, false);
			forceDebugger = true;
		}
	}
}