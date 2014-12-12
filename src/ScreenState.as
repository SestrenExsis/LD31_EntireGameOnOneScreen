package
{
	import org.flixel.*;
		
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/sounds/Die01.mp3")] public static var sfxDie01:Class;
		[Embed(source="../assets/sounds/Die02.mp3")] public static var sfxDie02:Class;
		[Embed(source="../assets/sounds/Die03.mp3")] public static var sfxDie03:Class;
		[Embed(source="../assets/sounds/Die04.mp3")] public static var sfxDie04:Class;
		public static var sfxDie:Array = [sfxDie01, sfxDie02, sfxDie03, sfxDie04];
		
		[Embed(source="../assets/sounds/Hit01.mp3")] public static var sfxHit01:Class;
		[Embed(source="../assets/sounds/Hit02.mp3")] public static var sfxHit02:Class;
		[Embed(source="../assets/sounds/Hit03.mp3")] public static var sfxHit03:Class;
		[Embed(source="../assets/sounds/Hit04.mp3")] public static var sfxHit04:Class;
		public static var sfxHit:Array = [sfxHit01, sfxHit02, sfxHit03, sfxHit04];
		
		[Embed(source="../assets/sounds/Move01.mp3")] public static var sfxMove01:Class;
		[Embed(source="../assets/sounds/Move02.mp3")] public static var sfxMove02:Class;
		[Embed(source="../assets/sounds/Move03.mp3")] public static var sfxMove03:Class;
		public static var sfxMove:Array = [sfxMove01, sfxMove02, sfxMove03];
		
		[Embed(source="../assets/sounds/Smite01.mp3")] public static var sfxSmite01:Class;
		[Embed(source="../assets/sounds/Smite02.mp3")] public static var sfxSmite02:Class;
		[Embed(source="../assets/sounds/Smite03.mp3")] public static var sfxSmite03:Class;
		[Embed(source="../assets/sounds/Smite04.mp3")] public static var sfxSmite04:Class;
		public static var sfxSmite:Array = [sfxSmite01, sfxSmite02, sfxSmite03, sfxSmite04];
		
		public static var soundQueue:Array = new Array();
		
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
			
			playSoundsFromQueue();
		}
		
		public static function addSoundToQueue(SoundArray:Array, Distance:Number):void
		{
			if (Distance > 64)
				return;
			
			var _volume:Number = 0.0;
			if (Distance > 32)
			{
				if (FlxG.random() < 0.1)
					_volume = 0.05;
			}
			else
				_volume = 1.0 - 0.95 * ((Distance * Distance) / (32 * 32));
			
			var _seed:Number = Math.floor(SoundArray.length * Math.random());
			var _sound:Object = {sfx: SoundArray[_seed], volume: _volume};
			soundQueue.push(_sound);
		}
		
		public function playSoundsFromQueue():void
		{
			if (soundQueue.length == 0)
				return;
			
			soundQueue.sortOn("volume", Array.NUMERIC);
			
			var _maxSounds:uint = Math.min(6, soundQueue.length);
			var _soundToPlay:Object;
			for (var i:int = 0; i < soundQueue.length; i++)
			{
				_soundToPlay = soundQueue.pop();
				if (i < _maxSounds)
					FlxG.play(_soundToPlay.sfx, _soundToPlay.volume, false, false);
			}
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