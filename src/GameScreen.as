package
{
	import org.flixel.*;
		
	public class GameScreen extends FlxState
	{
		[Embed(source="../assets/images/GameScreen.png")] protected var imgGameScreen:Class;
		
		protected var background:FlxSprite;
		protected var worldmap:WorldMap;
		protected var redTeam:FlxGroup;
		protected var blueTeam:FlxGroup;
		protected var lens:MagnifyingGlass;
		protected var actionTimer:FlxTimer;
		protected var currentTeam:int = Entity.RED_TEAM;
		
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
			redTeam = new FlxGroup(250);
			blueTeam = new FlxGroup(250);
			for (var i:int = 0; i < 250; i++)
			{
				_x = Math.floor(worldmap.widthInTiles * FlxG.random());
				_y = Math.floor((0.5 * worldmap.heightInTiles - 2) * FlxG.random());
				_entity = new Entity(worldmap, lens, _x, _y);
				redTeam.add(_entity);
				
				_x = Math.floor(worldmap.widthInTiles * FlxG.random());
				_y = 0.5 * worldmap.heightInTiles + 2 + Math.floor((0.5 * worldmap.heightInTiles - 2) * FlxG.random());
				_entity = new Entity(worldmap, lens, _x, _y);
				blueTeam.add(_entity);
			}
			
			add(background);
			add(worldmap);
			add(redTeam);
			add(blueTeam);
			add(lens);
			
			actionTimer = new FlxTimer();
			actionTimer.start(2, 1, updateActions);
		}
		
		public function updateActions(Timer:FlxTimer):void
		{
			actionTimer.stop();
			actionTimer.start(1, 1, updateActions);
			
			if (currentTeam == Entity.RED_TEAM)
			{
				redTeam.sort("posY", ASCENDING, false);
				redTeam.callAll("updateAction");
			}
			else if (currentTeam == Entity.BLUE_TEAM)
			{
				blueTeam.sort("posY", ASCENDING, false);
				blueTeam.callAll("updateAction");
			}
			
			FlxG.overlap(redTeam, blueTeam, null, overlapObjects);
			
			if (currentTeam == Entity.RED_TEAM)
				FlxG.overlap(redTeam, redTeam, null, overlapObjects);
			else if (currentTeam == Entity.BLUE_TEAM)
				FlxG.overlap(blueTeam, blueTeam, null, overlapObjects);
			
			currentTeam = (currentTeam == Entity.RED_TEAM) ? Entity.BLUE_TEAM : Entity.RED_TEAM;
		}
		
		public function overlapObjects(Object1:FlxObject, Object2:FlxObject):void
		{
			if (Object1 is Entity && Object2 is Entity)
				return overlapEntities(Object1 as Entity, Object2 as Entity);
		}
		
		public function overlapEntities(Entity1:Entity, Entity2:Entity):void
		{
			if (Entity1.posX != Entity2.posX || Entity1.posY != Entity2.posY)
				return;
			
			if (Entity1.team == currentTeam)
			{
				Entity1.undoLastMove();
				if (Entity2.team != currentTeam)
					Entity1.attack(Entity2);
			}
			if (Entity2.team == currentTeam)
			{
				Entity2.undoLastMove();
				if (Entity1.team != currentTeam)
					Entity2.attack(Entity1);
			}
			
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		override public function draw():void
		{	
			super.draw();
		}
	}
}