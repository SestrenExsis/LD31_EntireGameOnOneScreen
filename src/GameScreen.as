package
{
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class GameScreen extends ScreenState
	{
		[Embed(source="../assets/images/GameScreen.png")] protected var imgGameScreen:Class;
		[Embed(source="../assets/images/TinyLens.png")] protected var imgTinyLens:Class;
		
		public static const MODE_INSTRUCTIONS:int = 0;
		public static const MODE_PLAY:int = 1;
		public static const MODE_WIN:int = 2;
		public static const MODE_LOSE:int = 3;
		
		public static var LOSS_TRIGGERED:Boolean = false;
		
		protected var _gameMode:int = -1;
		
		public static const DIFFICULTY_TEXT:String = "Difficulty: ";
		public static const INSTRUCTION_TEXT:String = 
			" Press 1-5 to change the difficulty.\n Click on the instructions when you have\nthe magnifying lens to begin playing.";
		public static const WIN_TEXT:String = "You win!\nThank you for playing.\nClick on the instructions to play again.";
		public static const LOSE_TEXT:String = "An enemy unit escaped! You lose!\nClick on the instructions to try again.";
		
		protected var background:FlxSprite;
		protected var worldmap:WorldMap;
		protected var tinyLens:FlxSprite;
		protected var redTeam:FlxGroup;
		protected var blueTeam:FlxGroup;
		protected var lens:MagnifyingGlass;
		protected var radar:Radar;
		protected var actionTimer:FlxTimer;
		protected var currentTeam:int = Entity.RED_TEAM;
		protected var lanes:Vector.<Vector.<Entity>>;
		protected var infoText:FlxText;
		protected var difficultyText:FlxText;
		protected var clickRect:Rectangle;
		
		public var turnDuration:Number = 2.0;
		public var probabilityOfRed:Number = 0.2;
		public var maxRedPerLane:Number = 5;
		public var probabilityOfBlue:Number = 0.9;
		
		public function GameScreen()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			FlxG.mouse.show();
			FlxG.level = 2;
			clickRect = new Rectangle(48, 64, 16, 20);
			actionTimer = new FlxTimer();
			
			worldmap = new WorldMap();
			
			background = new FlxSprite();
			background.loadGraphic(imgGameScreen);
			
			var x:Number = worldmap.worldRect.left + Math.floor(FlxG.random() * 0.25 * worldmap.width);
			var y:Number = worldmap.worldRect.top + Math.floor(FlxG.random() * 0.25 * worldmap.height);
			tinyLens = new FlxSprite(x, y);
			tinyLens.loadGraphic(imgTinyLens);
			
			lens = new MagnifyingGlass(worldmap);
			radar = new Radar(174, 0, lens);
			
			infoText = new FlxText(0, 0.75 * FlxG.height, FlxG.width, INSTRUCTION_TEXT);
			infoText.setFormat(null, 8, 0xffffff, "center", 0x000000);
			
			difficultyText = new FlxText(8, FlxG.height - 16, 100, DIFFICULTY_TEXT);
			difficultyText.setFormat(null, 8, 0xffffff, "left", 0x000000);
			
			add(background);
			add(worldmap);
			add(tinyLens);
			add(radar);
			add(infoText);
			add(difficultyText);
			
			background.ID = 0;
			worldmap.ID = 1;
			radar.ID = 4;
			tinyLens.ID = 4;
			lens.ID = 5;
			infoText.ID = 6;
			difficultyText.ID = 7;
			
			FlxG.paused = true;
			gameMode = MODE_INSTRUCTIONS;
		}
		
		protected function pickUpLens():void
		{
			tinyLens.kill();
			remove(tinyLens);
			add(lens);
			FlxG.mouse.hide();
		}
		
		protected function startGame():void
		{
			if (radar)
				remove(radar);
			if (redTeam)
				remove(redTeam);
			if (blueTeam)
				remove(blueTeam);
			
			Entity.redCount = 0;
			Entity.blueCount = 0;
			lens.smiteCharge = 0;
			lens.smiteLevel = 0;
			lens.blessCharge = 0;
			lens.blessLevel = 0;
			
			var _entity:Entity;
			redTeam = new FlxGroup(1000);
			redTeam.ID = 2;
			blueTeam = new FlxGroup(1000);
			blueTeam.ID = 3;
			
			//shuffle up the lanes
			var x:int;
			var lane:Vector.<Entity>;
			lanes = new Vector.<Vector.<Entity>>(worldmap.widthInTiles);
			var _redCount:uint;
			var _success:Boolean;
			for (x = worldmap.worldRect.left; x < worldmap.worldRect.right; x++)
			{
				_redCount = 0;
				_success = true;
				do {
					if (FlxG.random() < (probabilityOfRed + 0.1 * FlxG.level))
						_redCount++;
					else
						_success = false;
				} while (_redCount < (maxRedPerLane + FlxG.level) && _success)
				
				lane = new Vector.<Entity>();
				fillLane(lane, x, _redCount);
				lanes[x] = lane;
			}
			
			add(redTeam);
			add(blueTeam);
			
			radar = new Radar(174, 0, lens, redTeam, blueTeam);
			radar.ID = 4;
			add(radar);
			
			sort("ID");
		}
		
		public function get gameMode():int
		{
			return _gameMode;
		}
		
		public function set gameMode(Value:int):void
		{
			if (Value == _gameMode)
				return;
			
			_gameMode = Value;
			
			if (Value == MODE_INSTRUCTIONS)
			{ // Point out the instructions
				FlxG.paused = true;
				infoText.visible = true;
			}
			else if (Value == MODE_PLAY)
			{ // Start the game
				startGame();
				LOSS_TRIGGERED = false;
				FlxG.paused = false;
				infoText.visible = false;
				actionTimer.stop();
				//actionTimer.start(turnDuration - 0.2 * FlxG.level, 1, updateActions);
			}
			else if (Value == MODE_WIN)
			{
				FlxG.paused = true;
				infoText.text = WIN_TEXT;
				infoText.visible = true;
				actionTimer.stop();
			}
			else if (Value == MODE_LOSE)
			{
				FlxG.paused = true;
				infoText.text = LOSE_TEXT;
				infoText.visible = true;
				actionTimer.stop();
			}
		}
		
		protected function fillLane(Lane:Vector.<Entity>, LaneIndex:uint, RedCount:uint = 4):uint
		{
			var _blueCount:uint = 0;
			for (var r:int = 0; r < RedCount; r++)
			{
				if (FlxG.random() < (probabilityOfBlue - 0.05 * FlxG.level))
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
			
			if (FlxG.paused)
				return;
			
			actionTimer.start(turnDuration - 0.2 * FlxG.level, 1, updateActions);
			
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
			var _left:uint = Math.max(lens.mapRect.left, worldmap.worldRect.left);
			var _right:uint = Math.min(lens.mapRect.right, worldmap.worldRect.right);
			var _distance:Number;
			for (i = _left; i < _right; i++)
			{
				_lane = lanes[i];
				for (var j:int = 0; j < _lane.length; j++)
				{
					_entity = _lane[j];
					_distance = _entity.distanceFromCenter;
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
			if (gameMode == MODE_PLAY)
			{
				if (Entity.redCount == 0)
					gameMode = MODE_WIN;
				else if (LOSS_TRIGGERED)
					gameMode = MODE_LOSE;
			}
			else
			{
				if (FlxG.keys.justPressed("ONE") || FlxG.keys.justPressed("NUMPADONE"))
					FlxG.level = 0;
				else if (FlxG.keys.justPressed("TWO") || FlxG.keys.justPressed("NUMPADTWO"))
					FlxG.level = 1;
				else if (FlxG.keys.justPressed("THREE") || FlxG.keys.justPressed("NUMPADTHREE"))
					FlxG.level = 2;
				else if (FlxG.keys.justPressed("FOUR") || FlxG.keys.justPressed("NUMPADFOUR"))
					FlxG.level = 3;
				else if (FlxG.keys.justPressed("FIVE") || FlxG.keys.justPressed("NUMPADFIVE"))
					FlxG.level = 4;
				difficultyText.text = DIFFICULTY_TEXT + (FlxG.level + 1).toString();
				
				if (FlxG.mouse.justPressed())
				{
					if (tinyLens.alive)
					{
						if (tinyLens.overlapsPoint(FlxG.mouse))
							pickUpLens();
					}
					else if (clickRect.contains(FlxG.mouse.x, FlxG.mouse.y))
						gameMode = MODE_PLAY;
				}
			}
			
			super.update();
			
			if (FlxG.paused)
				return;
			
			lens.blessCharge += FlxG.elapsed * Math.max(0, (1 - 0.2 * lens.blessLevel));
			if (lens.blessCharge > (MagnifyingGlass.BLESS_COOLDOWN - 0.1 * FlxG.level))
			{
				lens.blessCharge -= MagnifyingGlass.BLESS_COOLDOWN - 0.1 * FlxG.level;
				lens.blessLevel++;
			}
			lens.smiteCharge += FlxG.elapsed * Math.max(0, (1 - 0.2 * lens.smiteLevel))
			if (lens.smiteCharge > MagnifyingGlass.SMITE_COOLDOWN - 0.1 * FlxG.level)
			{
				lens.smiteCharge -= MagnifyingGlass.SMITE_COOLDOWN - 0.1 * FlxG.level;
				lens.smiteLevel++;
			}
			
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