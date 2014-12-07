package
{
	import org.flixel.*;
		
	public class GameScreen extends ScreenState
	{
		[Embed(source="../assets/images/GameScreen.png")] protected var imgGameScreen:Class;
		
		public static const TURN_DURATION:Number = 1.0;
		public static const MAX_ENEMIES_PER_LANE:uint = 10;
		
		protected var background:FlxSprite;
		protected var worldmap:WorldMap;
		protected var redTeam:FlxGroup;
		protected var blueTeam:FlxGroup;
		protected var lens:MagnifyingGlass;
		protected var actionTimer:FlxTimer;
		protected var currentTeam:int = Entity.RED_TEAM;
		protected var lanes:Vector.<Vector.<Entity>>;
		
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
			
			worldmap = new WorldMap();
			lens = new MagnifyingGlass(worldmap);
			
			var _entity:Entity;
			redTeam = new FlxGroup(1000);
			blueTeam = new FlxGroup(1000);
			
			//shuffle up the lanes
			var x:int;
			var lane:Vector.<Entity>;
			lanes = new Vector.<Vector.<Entity>>(worldmap.widthInTiles);
			var _probability:Number = 0.7;
			var _redCount:uint;
			var _success:Boolean;
			for (x = worldmap.worldRect.left; x < worldmap.worldRect.right; x++)
			{
				_redCount = 0;
				_success = true;
				do {
					if (FlxG.random() < _probability)
						_redCount++;
					else
						_success = false;
				} while (_redCount < MAX_ENEMIES_PER_LANE && _success)
				
				lane = new Vector.<Entity>();
				fillLane(lane, x, _redCount);
				lanes[x] = lane;
			}
			
			add(background);
			add(worldmap);
			add(redTeam);
			add(blueTeam);
			add(lens);
			
			actionTimer = new FlxTimer();
			actionTimer.start(TURN_DURATION, 1, updateActions);
		}
		
		protected function fillLane(Lane:Vector.<Entity>, LaneIndex:uint, RedCount:uint = 4, BluePercent:Number = 0.8):uint
		{
			var _blueCount:uint = 0;
			for (var r:int = 0; r < RedCount; r++)
			{
				if (FlxG.random() < BluePercent)
					_blueCount++;
			}
			
			var _maxDistance:uint = Math.ceil(worldmap.worldRect.height / (RedCount + _blueCount + 2));
			var _y:int = worldmap.worldRect.top
				+ Math.max(Math.ceil(_maxDistance * FlxG.random()), Math.ceil(_maxDistance * FlxG.random()));
			var _entity:Entity;
			var _team:int;
			for (var i:int = 0; i < RedCount + _blueCount; i++)
			{
				_y += Math.max(Math.ceil(_maxDistance * FlxG.random()), Math.ceil(_maxDistance * FlxG.random()));
				if (i < RedCount)
					_team = Entity.RED_TEAM;
				else
					_team = Entity.BLUE_TEAM;
				_entity = new Entity(worldmap, lens, LaneIndex, _y, _team);
				Lane.push(_entity);
				
				if (_team == Entity.RED_TEAM)
					redTeam.add(_entity);
				else
					blueTeam.add(_entity);
			}
			
			return RedCount + _blueCount;
		}
		
		public function updateActions(Timer:FlxTimer):void
		{
			actionTimer.stop();
			actionTimer.start(TURN_DURATION, 1, updateActions);
			
			var i:int;
			if (currentTeam == Entity.RED_TEAM)
			{
				redTeam.sort("posY", DESCENDING, false);
				redTeam.callAll("updateAction");
			}
			else if (currentTeam == Entity.BLUE_TEAM)
			{
				blueTeam.sort("posY", ASCENDING, false);
				blueTeam.callAll("updateAction");
			}
			
			FlxG.overlap(redTeam, blueTeam, overlapObjects, testOverlap);
			
			if (currentTeam == Entity.RED_TEAM)
				FlxG.overlap(redTeam, redTeam, overlapObjects, testOverlap);
			else if (currentTeam == Entity.BLUE_TEAM)
				FlxG.overlap(blueTeam, blueTeam, overlapObjects, testOverlap);
			
			currentTeam = (currentTeam == Entity.RED_TEAM) ? Entity.BLUE_TEAM : Entity.RED_TEAM;
		}
		
		public function testOverlap(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			return (Object1.alive && Object2.alive && Object1.exists && Object2.exists);
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
				else 
				{
					if (Entity1.last.y < Entity2.last.y && Entity1.team == Entity.RED_TEAM)
						Entity1.taunt();
					else if (Entity1.last.y > Entity2.last.y && Entity1.team == Entity.BLUE_TEAM)
						Entity1.taunt();
				}
			}
			if (Entity2.team == currentTeam)
			{
				Entity2.undoLastMove();
				if (Entity1.team != currentTeam)
					Entity2.attack(Entity1);
				else 
				{
					if (Entity2.last.y < Entity1.last.y && Entity2.team == Entity.RED_TEAM)
						Entity2.taunt();
					else if (Entity2.last.y > Entity1.last.y && Entity2.team == Entity.BLUE_TEAM)
						Entity2.taunt();
				}
			}
		}
		
		public function randomEntity(Reds:Boolean = true, Blues:Boolean = true):Entity
		{
			var i:int;
			var _lane:Vector.<Entity>;
			var _entity:Entity;
			var _array:Array = new Array();
			var _left:uint = Math.max(lens.mapRect.left, 0);
			var _right:uint = Math.min(lens.mapRect.right, worldmap.widthInTiles - 1);
			var _distance:Number;
			for (i = _left; i < _right; i++)
			{
				_lane = lanes[i];
				for (var j:int = 0; j < _lane.length; j++)
				{
					_entity = _lane[j];
					_distance = _entity.distanceFromCenter();
					if (_distance < 31 && _entity.magnified && _entity.alive && _entity.exists)
					{
						if ((Reds && _entity.team == Entity.RED_TEAM) || (Blues && _entity.team == Entity.BLUE_TEAM))
							_array.push(_entity);
					}
				}
			}
			
			if (_array.length == 0)
				return null;
			
			var _seed:uint = Math.floor(_array.length * FlxG.random());
			return _array[_seed];
		}
		
		override public function update():void
		{	
			super.update();
			
			if (FlxG.mouse.justPressed())
			{
				var _randomEntity:Entity
				if (lens.frame == MagnifyingGlass.SPELL_BLESS)
				{
					if (lens.blessLevel > 0)
					{
						_randomEntity = randomEntity(false, true);
						if (_randomEntity)
						{
							_randomEntity.bless();
							lens.blessCharge -= MagnifyingGlass.BLESS_COOLDOWN;
							lens.blessLevel--;
						}
					}
				}
				else if (lens.frame == MagnifyingGlass.SPELL_SMITE)
				{
					if (lens.smiteLevel > 0)
					{
						_randomEntity = randomEntity(true, false);
						if (_randomEntity)
						{
							_randomEntity.smite();
							lens.smiteCharge -= MagnifyingGlass.SMITE_COOLDOWN;
							lens.smiteLevel--;
						}
					}
				}
			}
		}
		
		override public function draw():void
		{	
			super.draw();
		}
	}
}