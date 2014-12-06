package
{
	import org.flixel.*;
		
	public class GameScreen extends FlxState
	{
		[Embed(source="../assets/images/GameScreen.png")] protected var imgGameScreen:Class;
		
		protected var background:FlxSprite;
		protected var worldmap:WorldMap;
		protected var entities:FlxGroup;
		protected var lens:MagnifyingGlass;
		
		public function GameScreen()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			FlxG.mouse.hide();
			
			background = new FlxSprite();
			background.loadGraphic(imgGameScreen);
			
			worldmap = new WorldMap(34, 34, 112, 112);
			lens = new MagnifyingGlass(worldmap);
			
			var _entity:Entity;
			var _x:int;
			var _y:int;
			entities = new FlxGroup(500);
			for (var i:int = 0; i < 500; i++)
			{
				_x = Math.floor(worldmap.widthInTiles * FlxG.random());
				_y = Math.floor(worldmap.heightInTiles * FlxG.random());
				_entity = new Entity(worldmap, lens, _x, _y);
				entities.add(_entity);
			}
			
			add(background);
			add(worldmap);
			add(entities);
			add(lens);
		}
		
		override public function update():void
		{	
			super.update();
		}
	}
}