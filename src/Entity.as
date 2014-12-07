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
		
		public static const BLUE_TEAM:int = -1;
		public static const NEUTRAL_TEAM:int = 0;
		public static const RED_TEAM:int = 1;
		
		public var map:WorldMap;
		public var lens:MagnifyingGlass;
		public var magnified:Boolean = false;
		
		protected var _team:int = 0;
		protected var _offsetRemaining:FlxPoint;
		protected var timer:FlxTimer;
		
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
			
			_offsetRemaining = new FlxPoint();
			width = height = 1;
			health = 2;
			
			team = Team;
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
				color = 0x0088ff;
				play("good_idle", true);
			}
			else if (_team == RED_TEAM)
			{
				color = 0xff0000;
				play("bad_idle", true);
			}
		}
		
		public function moveForward():void
		{
			play(((team == RED_TEAM) ? "bad_move" : "good_move"));
			last.y = posY;
			posY += team;
			_offsetRemaining.y -= 8 * team;
			ScreenState.addSoundToQueue(ScreenState.sfxMove, distanceFromCenter());
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
			var _hit:Boolean = FlxG.random() < 0.5;
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
				play(((team == RED_TEAM) ? "bad_die" : "good_die"));
				timer.stop();
				timer.start(10 / ANIMATION_SPEED, 1, onTimerKill);
				alive = false;
				ScreenState.addSoundToQueue(ScreenState.sfxDie, distanceFromCenter());
			}
			else
			{
				play(((team == RED_TEAM) ? "bad_hurt" : "good_hurt"));
				ScreenState.addSoundToQueue(ScreenState.sfxHit, distanceFromCenter());
			}
		}
		
		public function smite():void
		{
			alive = false;
			
			play((team == RED_TEAM) ? "bad_lightning" : "good_lightning", true);
			timer.start(5 / (0.5 * ANIMATION_SPEED), 1, onTimerKill);
			ScreenState.addSoundToQueue(ScreenState.sfxSmite, distanceFromCenter());
		}
		
		public function onTimerKill(Timer:FlxTimer):void
		{
			timer.stop();
			kill();
		}
		
		public function distanceFromCenter():Number
		{
			var dx:Number = FlxG.mouse.x - 34 - posX;
			var dy:Number = FlxG.mouse.y - 34 - posY;
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
		}
		
		override public function draw():void
		{
			var x:Number = posX + _offsetRemaining.x / FRAME_WIDTH;
			var y:Number = posY + _offsetRemaining.y / FRAME_WIDTH;
			var _view:Rectangle = lens.mapRect;
			var _corner:Boolean = ((x == _view.left || x == _view.right - 1) && (y == _view.top || y == _view.bottom - 1));
			magnified = !_corner && _view.left <= x && _view.right >= x && _view.top - 1 < y && _view.bottom >= y;
			
			if (magnified)
			{
				x = posX;
				y = posY;
				
				posX = lens.lensRect.x + FRAME_WIDTH * (x - _view.x);
				posY = lens.lensRect.y + FRAME_WIDTH * (y - _view.y);
				
				if(dirty)
					calcFrame();
				
				_flashPoint.x = posX + _offsetRemaining.x;
				_flashPoint.y = posY + _offsetRemaining.y - FRAME_OFFSET;
				
				_flashPointZero.setTo(_flashPoint.x - lens.posX, _flashPoint.y - lens.posY);
				FlxG.camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, lens.lensMask, _flashPointZero, true);
				_flashPointZero.setTo(0, 0);
				
				if(FlxG.visualDebug && !ignoreDrawDebug)
					drawDebug(FlxG.camera);
				
				posX = x;
				posY = y;
			}
			else if (alive)
			{
				var _distance:Number = distanceFromCenter();
				
				var _offsetX:uint = 0;
				var _offsetY:uint = 0;
				if (_distance < 31)
				{
					_offsetX = 274 + posX - lens.lensRect.x;
					_offsetY = 48 + posY - lens.lensRect.y;
					FlxG.camera.buffer.setPixel(_offsetX, _offsetY, color);
				}
				else if (_distance >= 33)
				{
					_offsetX = map.posX + posX;
					_offsetY = map.posY + posY;
					FlxG.camera.buffer.setPixel(_offsetX, _offsetY, color);
				}
			}
		}
	}
}