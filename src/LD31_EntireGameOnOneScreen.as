package
{
	import org.flixel.FlxGame;
	
	[SWF(width="640", height="360", backgroundColor="#666666")]
	
	public class LD31_EntireGameOnOneScreen extends FlxGame
	{
		public function LD31_EntireGameOnOneScreen()
		{
			super(320, 180, GameScreen, 2.0, 60, 60, false);
			forceDebugger = true;
		}
	}
}