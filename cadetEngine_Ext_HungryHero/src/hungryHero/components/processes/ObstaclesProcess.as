package hungryHero.components.processes
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	
	import hungryHero.components.behaviours.ObstacleBehaviour;
	import hungryHero.pools.Pool;
	
	public class ObstaclesProcess extends Component implements ISteppableComponent
	{
		private var _initialised				:Boolean;
		private var obstacles					:Array;
		private var obstaclesTable				:Dictionary;
		
		public var globals						:GlobalsProcess;
		
		[Serializable][Inspectable(priority="50") ]
		public var obstacleGap				:Number = 1200;		
		[Serializable][Inspectable(priority="51") ]
		public var obstacleSpeed			:Number = 300;
		
		/** Obstacles pool with a maximum cap for reuse of items. */		
		private var obstaclesPool			:Pool;
		
		/** Obstacle count - to track the frequency of obstacles. */
		private var obstacleGapCount:Number = 0;
		
		/** The power of obstacle after it is hit. */
		private var hitObstacle:Number = 0;
		
		/** Obstacles to animate. */
		private var obstaclesToAnimate:Vector.<AbstractSkin2D>;
		
		/** Obstacles to animate - array length. */		
		private var obstaclesToAnimateLength:uint = 0;
		
		private var hitTestX:int;
		private var hitTestY:int;
		
		private var _hitTestSkin			:AbstractSkin2D;
		private var _obstaclesContainer		:IComponentContainer;
		
		private var elapsed					:Number = 0.02;;
		private var playerSpeed				:int = 650;
		public var defaultGameArea			:Rectangle = new Rectangle(0, 0, 800, 600);
		
		public function ObstaclesProcess()
		{
			obstacles = [];
			obstaclesTable = new Dictionary();
			
			// Initialize items-to-animate vector.
			obstaclesToAnimate = new Vector.<AbstractSkin2D>();
			obstaclesToAnimateLength = 0;
		}
		
		override protected function addedToScene():void
		{
//			addSceneReference(Renderer2D, "renderer");
			addSceneReference(GlobalsProcess, "globals");
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="50" )]
		public function set hitTestSkin( value:AbstractSkin2D ):void
		{
			_hitTestSkin = value;
		}
		public function get hitTestSkin():AbstractSkin2D
		{
			return _hitTestSkin;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="51" )]
		public function set obstaclesContainer( value:IComponentContainer ):void
		{
			_obstaclesContainer = value;
		}
		public function get obstaclesContainer():IComponentContainer
		{
			return _obstaclesContainer;
		}
		
		public function step( dt:Number ):void
		{
			if (!_initialised) {
				initialise();
			}
			
			if ( globals ) {
				playerSpeed = globals.playerSpeed;
				elapsed = globals.elapsed;
			}
			
			// Create obstacles.
			initObstacle();

			// Store the hero's current x and y positions (needed for animations below).
			if (_hitTestSkin) {
				hitTestX = _hitTestSkin.x + _hitTestSkin.width/2;//hero.x;
				hitTestY = _hitTestSkin.y + _hitTestSkin.height/2;//hero.y;
			}
			
			animateObstacles();
		}
		
		private function initialise():void
		{
			createObstaclesPool();
			
			_initialised = true;
		}
		
		/**
		 * Create obstacles pool by passing the create and clean methods/functions to the Pool.  
		 * 
		 */
		private function createObstaclesPool():void
		{
			if (!_obstaclesContainer) {
				_obstaclesContainer = parentComponent;
			}
			
			for ( var i:uint = 0; i < _obstaclesContainer.children.length; i ++ ) 
			{
				var child:Component = _obstaclesContainer.children[i];
				
				if (!child is Entity) continue;
				
				var entity:Entity = Entity(child);
				var skin:ImageSkin = ComponentUtil.getChildOfType(entity, ImageSkin);
				var behaviour:ObstacleBehaviour = ComponentUtil.getChildOfType(entity, ObstacleBehaviour);
				if ( skin && behaviour ) {	
					obstacles.push( skin );
					obstaclesTable[skin.texturesPrefix] = behaviour;
				}
			}
			
			for ( i = 0; i < obstacles.length; i ++ ) {
				child = obstacles[i];
				child.parentComponent.children.removeItem(child);
			}
			
			obstaclesPool = new Pool(obstacleCreate, obstacleClean, 4, 10);
		}
		
		private function obstacleCreate():AbstractSkin2D
		{
			var gameArea:Rectangle = globals ? globals.gameArea : defaultGameArea;
			var skin:MovieClipSkin = new MovieClipSkin();
			
			if (!skin) return null;
			
			var newSkin:MovieClipSkin = MovieClipSkin(skin.clone());
			_obstaclesContainer.children.addItem(newSkin);
			
			newSkin.x = gameArea.right;
			newSkin.y = Math.random() * 400;
			newSkin.validateNow();
			
			return newSkin;
		}
		
		private function obstacleClean(skin:AbstractSkin2D):void
		{
			
		}
		
		private function checkOutItem(randItem:AbstractSkin2D, distance:Number):AbstractSkin2D
		{
			var gameArea:Rectangle = globals ? globals.gameArea : defaultGameArea;
			var itemToTrack:MovieClipSkin = MovieClipSkin(obstaclesPool.checkOut());
			
			if (!itemToTrack) return null;
			
			// randItem is either MovieClipSkin or ImageSkin (MovieClipSkin extends ImageSkin)
			var randImgSkin:ImageSkin = ImageSkin(randItem);
			var imgSkin:MovieClipSkin = MovieClipSkin(itemToTrack);
			imgSkin.texture = randImgSkin.texture;
			imgSkin.textureAtlas = randImgSkin.textureAtlas;
			imgSkin.texturesPrefix = randImgSkin.texturesPrefix;			
			
			// Possible that texturesPrefix could be the same for different TextureAtlases... Though unlikely.
			var behaviour:ObstacleBehaviour = obstaclesTable[imgSkin.texturesPrefix];
			
			behaviour.distance = distance;
			itemToTrack.x = gameArea.right;
			
			// For only one of the obstacles, make it appear in either the top or bottom of the screen.
/*			if (_type <= GameConstants.OBSTACLE_TYPE_3)
			{*/
				// Place it on the top of the screen.
				if (Math.random() > 0.5)
				{
					itemToTrack.y = gameArea.top;
					behaviour.position = "top";
				}
				else
				{
					// Or place it in the bottom of the screen.
					itemToTrack.y = gameArea.bottom - itemToTrack.height;
					behaviour.position = "bottom";
				}
/*			}
			else
			{
				// Otherwise, if it's any other obstacle type, put it somewhere in the middle of the screen.
				itemToTrack.y = Math.floor(Math.random() * (gameArea.bottom-itemToTrack.height - gameArea.top + 1)) + gameArea.top;
				itemToTrack.position = "middle";
			}*/
			
			// Set the obstacle's speed.
			behaviour.speed = obstacleSpeed;
			
			// Set look out mode to true, during which, a look out text appears.
			behaviour.lookOut = true;
			
			// Animate the obstacle.
			obstaclesToAnimate[obstaclesToAnimateLength++] = itemToTrack;
			
			return itemToTrack;
		}
		
		/**
		 * Create an obstacle after hero has travelled a certain distance.
		 * 
		 */
		private function initObstacle():void
		{
			// Create an obstacle after hero travels some distance (obstacleGap).
			if (obstacleGapCount < obstacleGap)
			{
				obstacleGapCount += playerSpeed * elapsed;
			}
			else if (obstacleGapCount != 0)
			{
				var randObstacle:AbstractSkin2D = obstacles[Math.round(Math.random() * (obstacles.length-1))];
				obstacleGapCount = 0;
				
				// Create any one of the obstacles.
				checkOutItem(randObstacle, Math.random() * 1000 + 1000);
			}
		}
		
		/**
		 * Create the obstacle object based on the type indicated and make it appear based on the distance passed. 
		 * @param _type
		 * @param _distance
		 * 
		 */
		private function createObstacle(_type:int = 1, _distance:Number = 0):void
		{

		}
		
		/**
		 * Animate obstacles marked for animation. 
		 * 
		 */
		private function animateObstacles():void
		{
/*			if (!gamePaused)
			{*/
				var obstacleToTrack:ImageSkin;
				var heroRect:Rectangle;
				var obstacleRect:Rectangle;
				
				for (var i:uint = 0; i < obstaclesToAnimateLength ; i ++)
				{
					obstacleToTrack = obstaclesToAnimate[i];
					var behaviour:ObstacleBehaviour = obstaclesTable[obstacleToTrack.texturesPrefix];
					
					// If the distance is still more than 0, keep reducing its value, without moving the obstacle.
					if (behaviour.distance > 0 ) 
					{
						behaviour.distance -= playerSpeed * elapsed;  
					}
					else  
					{
						// Otherwise, move the obstacle based on hero's speed, and check if he hits it. 
						
						// Remove the look out sign.
						if (behaviour.lookOut == true )
						{
							behaviour.lookOut = false;
						}
						
						// Move the obstacle based on hero's speed.
						obstacleToTrack.x -= (playerSpeed + behaviour.speed) * elapsed; 
					}
					
					// If the obstacle passes beyond the screen, remove it.
					if (obstacleToTrack.x < -obstacleToTrack.width)// || gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeObstacleTemporarily(i, obstacleToTrack);
					}
					
					// Collision detection - Check if hero collides with any obstacle.
					var xDistance:Number = obstacleToTrack.x - hitTestX;
					var yDistance:Number = obstacleToTrack.y - hitTestY;
					var h:Number = Math.sqrt( xDistance * xDistance + yDistance * yDistance );
					var hitDistance:Number = hitTestSkin ? hitTestSkin.width / 2 : 100;
					
					if ( h < hitDistance  && !behaviour.alreadyHit )
					//if (heroObstacle_sqDist < 5000 && !obstacleToTrack.alreadyHit)
					{
						behaviour.alreadyHit = true;
						
						/*if (!Sounds.muted) Sounds.sndHit.play();*/
						
/*						if (coffee > 0) 
						{
							// If hero has a coffee item, break through the obstacle.
							if (behaviour.position == "bottom") obstacleToTrack.rotation = deg2rad(100);
							else obstacleToTrack.rotation = deg2rad(-100);
							
							// Set hit obstacle value.
							hitObstacle = 30;
							
							// Reduce hero's speed
							playerSpeed *= 0.8; 
						}
						else 
						{*/
							if (behaviour.position == "bottom") obstacleToTrack.rotation = deg2rad(70);
							else obstacleToTrack.rotation = deg2rad(-70);
							
							// Otherwise, if hero doesn't have a coffee item, set hit obstacle value.
							hitObstacle = 30; 
							
							// Reduce hero's speed.
							playerSpeed *= 0.5; 
/*							
							// Play hurt sound.
							if (!Sounds.muted) Sounds.sndHurt.play();
							
							// Update lives.
							lives--;
							
							if (lives <= 0)
							{
								lives = 0;
								endGame();
							}
							
							hud.lives = lives;*/
						//}
					}
					
					// If the game has ended, remove the obstacle.
/*					if (gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeObstacleTemporarily(i, obstacleToTrack);
					}*/
				}
/*			}*/
		}		
		
		private function disposeObstacleTemporarily(animateId:uint, obstacle:AbstractSkin2D):void
		{
			obstaclesToAnimate.splice(animateId, 1);
			obstaclesToAnimateLength--;
			obstaclesPool.checkIn(obstacle);
		}
		
		public function deg2rad(deg:Number):Number
		{
			return deg / 180.0 * Math.PI;   
		}
	}
}













