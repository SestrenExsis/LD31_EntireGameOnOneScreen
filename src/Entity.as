package
{
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		[Embed(source="../assets/images/Entity.png")] protected var imgEntity:Class;
		
		public static const FRAME_WIDTH:Number = 8;
		public static const FRAME_HEIGHT:Number = 40;
		public static const FRAME_OFFSET:Number = 24;
		public static const ANIMATION_SPEED:Number = 8;
		
		public static const BLUE:uint = 0x0066ff;
		public static const BLUE_HURT:uint = 0x0000cc;
		public static const RED:uint = 0xff0000;
		public static const RED_HURT:uint = 0xaa0000;
		public static const BLESSED:uint = 0xffffff;
		
		public static const BLUE_TEAM:int = -1;
		public static const NEUTRAL_TEAM:int = 0;
		public static const RED_TEAM:int = 1;
		
		public static var blueCount:uint = 0;
		public static var redCount:uint = 0;
		
		public var map:WorldMap;
		public var lens:MagnifyingGlass;
		public var magnified:Boolean = false;
		public var blessed:Boolean = false;
		public var distanceFromCenter:Number = 0;
		
		protected var _team:int = 0;
		protected var _offsetRemaining:FlxPoint;
		protected var timer:FlxTimer;
		protected var blessTimer:FlxTimer;
		
		public function Entity(Map:WorldMap, Lens:MagnifyingGlass, X:int, Y:int, Team:int)
		{
			super(X, Y);
			
			moves = false;
			
			map = Map;
			lens = Lens;
			loadGraphic(imgEntity, true, false, FRAME_WIDTH, FRAME_HEIGHT);
			addAnimation("none", [0]);
			addAnimation("bad_idle", [1]);
			addAnimation("bad_move", [2, 1, 3, 1], ANIMATION_SPEED, false);
			addAnimation("bad_lightning", [20, 21, 22, 23, 0], 0.5 * ANIMATION_SPEED, false);
			addAnimation("bad_attack_miss", [4, 5, 6, 1], ANIMATION_SPEED, false);
			addAnimation("bad_attack_hit", [4, 5, 7, 1], ANIMATION_SPEED, false);
			addAnimation("bad_dodge", [8, 9, 9, 1], ANIMATION_SPEED, false);
			addAnimation("bad_hurt", [24, 25, 26, 1], ANIMATION_SPEED, false);
			addAnimation("bad_die", [24, 25, 27, 28, 29, 0, 29, 0, 29, 0], ANIMATION_SPEED, false);
			addAnimation("bad_yell", [40, 41, 40, 41, 1], 0.5 * ANIMATION_SPEED, false);
			addAnimation("bad_dance", [44, 43, 42, 43, 44, 43, 42, 43, 44, 43, 1], ANIMATION_SPEED, false);
			addAnimation("bad_jump", [45, 46, 47, 48, 49, 1], ANIMATION_SPEED, false);
			
			addAnimation("good_idle", [11]);
			addAnimation("good_move", [12, 11, 13, 11], ANIMATION_SPEED, false);
			addAnimation("good_lightning", [30, 31, 32, 33, 0], 0.5 * ANIMATION_SPEED, false);
			addAnimation("good_attack_miss", [14, 15, 16, 11], ANIMATION_SPEED, false);
			addAnimation("good_attack_hit", [14, 15, 17, 11], ANIMATION_SPEED, false);
			addAnimation("good_dodge", [18, 19, 19, 11], ANIMATION_SPEED, false);
			addAnimation("good_hurt", [34, 35, 36, 11], ANIMATION_SPEED, false);
			addAnimation("good_die", [34, 35, 37, 38, 39, 0, 39, 0, 39, 0], ANIMATION_SPEED, false);
			addAnimation("good_yell", [50, 51, 50, 51, 11], 0.5 * ANIMATION_SPEED, false);
			addAnimation("good_dance", [54, 53, 52, 53, 54, 53, 52, 53, 54, 53, 11], ANIMATION_SPEED, false);
			addAnimation("good_jump", [55, 56, 57, 58, 59, 11], ANIMATION_SPEED, false);
			
			timer = new FlxTimer();
			timer.start(0.01);
			blessTimer = new FlxTimer();
			blessTimer.start(0.01);
			
			_offsetRemaining = new FlxPoint();
			width = height = 1;
			health = 3;
			
			team = Team;
			distanceFromCenter = getDistanceFromCenter();
			
			ID = Entity.redCount + Entity.blueCount;
			
			if (team == RED_TEAM)
				Entity.redCount++;
			else if (team == BLUE_TEAM)
				Entity.blueCount++;
		}
		
		public function get team():int
		{
			return _team;
		}
		
		public function set team(Value:int):void
		{
			if (_team == Value)
				return;
			
			_team = Value;
			
			if (_team == BLUE_TEAM)
			{
				color = BLUE;
				play("good_idle", true);
			}
			else if (_team == RED_TEAM)
			{
				color = RED;
				play("bad_idle", true);
			}
		}
		
		public function taunt():void
		{
			var _seed:Number = Math.floor(12 * FlxG.random());
			switch (_seed)
			{
				case 0: play(((team == RED_TEAM) ? "bad_yell" : "good_yell")); break;
				case 1: play(((team == RED_TEAM) ? "bad_dance" : "good_dance")); break;
				case 2: play(((team == RED_TEAM) ? "bad_jump" : "good_jump")); break;
			}
		}
		
		public function updateAction():void
		{
			if (!alive || !exists)
				return;
			
			moveForward()
		}
		
		public function moveForward():void
		{
			if (team == RED_TEAM && posY == map.worldRect.bottom - 1)
				GameScreen.LOSS_TRIGGERED = true;
			if (team == BLUE_TEAM && posY == map.worldRect.top)
				return;
			
			play(((team == RED_TEAM) ? "bad_move" : "good_move"));
			last.y = posY;
			posY += team;
			_offsetRemaining.y -= 8 * team;
			
			ScreenState.addSoundToQueue(ScreenState.sfxMove, distanceFromCenter);
		}
		
		public function undoLastMove():void
		{
			if (_curAnim.name == "bad_move" || _curAnim.name == "good_move")
				play(((team == RED_TEAM) ? "bad_idle" : "good_idle"));
			posY = last.y;
			_offsetRemaining.y = 0;
		}
		
		public function attack(Target:Entity):Boolean
		{
			last.y = posY;
			var _chanceToHit:Number = (blessed) ? 0.75 : 0.5;
			var _hit:Boolean = FlxG.random() < _chanceToHit;
			if (_hit)
			{
				play(((team == RED_TEAM) ? "bad_attack_hit" : "good_attack_hit"));
				Target.hurt(1);
			}
			else
			{
				play(((team == RED_TEAM) ? "bad_attack_miss" : "good_attack_miss"));
				Target.play(((Target.team == RED_TEAM) ? "bad_dodge" : "good_dodge"));
			}
			return _hit;
		}
		
		override public function hurt(Damage:Number):void
		{
			health -= Damage;
			
			if(health <= 0)
			{
				if (team == RED_TEAM)
					Entity.redCount--;
				else if (team == BLUE_TEAM)
					Entity.blueCount--;
				
				play(((team == RED_TEAM) ? "bad_die" : "good_die"));
				timer.stop();
				timer.start(10 / ANIMATION_SPEED, 1, onTimerKill);
				alive = false;
				ScreenState.addSoundToQueue(ScreenState.sfxDie, distanceFromCenter);
			}
			else
			{
				color = (team == RED_TEAM) ? RED_HURT : BLUE_HURT;
				play(((team == RED_TEAM) ? "bad_hurt" : "good_hurt"));
				ScreenState.addSoundToQueue(ScreenState.sfxHit, distanceFromCenter);
			}
			
			blessed = false;
		}
		
		public function smite():void
		{
			alive = false;
			
			if (team == RED_TEAM)
				Entity.redCount--;
			else if (team == BLUE_TEAM)
				Entity.blueCount--;
			
			play((team == RED_TEAM) ? "bad_lightning" : "good_lightning", true);
			timer.start(5 / (0.5 * ANIMATION_SPEED), 1, onTimerKill);
			ScreenState.addSoundToQueue(ScreenState.sfxSmite, distanceFromCenter);
		}
		
		public function bless():void
		{
			color = BLESSED;
			blessed = true;
			health = 3;
			timer.start(0.25, 1, onTimerBless);
			ScreenState.addSoundToQueue(ScreenState.sfxSmite, getDistanceFromCenter());
		}
		
		public function onTimerBless(Timer:FlxTimer):void
		{
			blessTimer.stop();
			if (!blessed && color != BLESSED)
				return;
			
			blessTimer.start(0.25, 1, onTimerBless);
			if (color == BLESSED)
				color = (team == RED_TEAM) ? RED : BLUE;
			else
				color = BLESSED;
		}
		
		public function onTimerKill(Timer:FlxTimer):void
		{
			timer.stop();
			kill();
		}
		
		public function getDistanceFromCenter(ZoomedOut:Boolean = true):Number
		{
			var dx:Number = lens.currentPos.x - (MagnifyingGlass.ZOOM * posX - _offsetRemaining.x);
			var dy:Number = lens.currentPos.y - (MagnifyingGlass.ZOOM * posY - _offsetRemaining.y);
			
			if (ZoomedOut)
			{
				dx /= MagnifyingGlass.ZOOM;
				dy /= MagnifyingGlass.ZOOM;
			}
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		override public function update():void
		{	
			super.update();
			
			if (!alive)
				return;
			
			if (_offsetRemaining.x != 0)
				_offsetRemaining.x += (_offsetRemaining.x < 0) ? 1 : -1;
			if (_offsetRemaining.y != 0)
				_offsetRemaining.y += (_offsetRemaining.y < 0) ? 1 : -1;
			
			distanceFromCenter = getDistanceFromCenter();
		}
		
		override public function draw():void
		{
			var _offsetX:uint = 0;
			var _offsetY:uint = 0;
			if (distanceFromCenter >= 33 && alive)
			{
				_offsetX = map.posX + posX;
				_offsetY = map.posY + posY;
				FlxG.camera.buffer.setPixel(_offsetX, _offsetY, color);
			}
			
			var x:Number = posX + _offsetRemaining.x / FRAME_WIDTH;
			var y:Number = posY + _offsetRemaining.y / FRAME_WIDTH;
			var _view:Rectangle = lens.mapRect;
			magnified = _view.left <= x && (_view.right + 1 >= x) && (_view.top - 1 < y) && (_view.bottom + 1 >= y);
			if (magnified)
			{
				x = posX;
				y = posY;
				
				posX = lens.lensRect.x + FRAME_WIDTH * (x - _view.x);
				posY = lens.lensRect.y + FRAME_WIDTH * (y - _view.y);
				
				if(dirty)
					calcFrame();
				
				_flashPoint.x = posX + lens.magnifyOffset.x + _offsetRemaining.x;
				_flashPoint.y = posY + lens.magnifyOffset.y + _offsetRemaining.y - FRAME_OFFSET;
				
				_flashPointZero.setTo(_flashPoint.x - lens.posX, _flashPoint.y - lens.posY);
				FlxG.camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, lens.lensMask, _flashPointZero, true);
				_flashPointZero.setTo(0, 0);
				
				if(FlxG.visualDebug && !ignoreDrawDebug)
					drawDebug(FlxG.camera);
				
				posX = x;
				posY = y;
			}
		}
	}
}