package
{
	import org.flixel.*;
		
	public class ScreenState extends FlxState
	{
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			FlxG.flash(0xff000000, 1.0);
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		public static function playSound(SoundArray:Array, Volume:Number = 1.0):void
		{
			var _seed:Number = Math.floor(SoundArray.length * Math.random());
			FlxG.play(SoundArray[_seed], Volume, false, false);
		}
		
		public function onButtonGame():void
		{
			fadeToGame();
		}
		
		public function fadeToGame(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 1.0, goToGame);
		}
		
		public function goToGame():void
		{
			FlxG.switchState(new GameScreen);
		}
	}
}