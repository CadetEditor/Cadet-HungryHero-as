package hungryHero.components.processes
{
	import flash.geom.Rectangle;
	
	import cadet.components.processes.SoundProcess;
	import cadet.components.sounds.ISound;
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.core.IInitialisableComponent;
	import cadet.core.ISteppableComponent;
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentUtil;
	import cadet.util.deg2rad;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.transforms.Transform2D;
	
	import hungryHero.components.behaviours.ObstacleBehaviour;
	import hungryHero.pools.Pool;
	
	public class ObstaclesProcess extends Component implements ISteppableComponent, IInitialisableComponent
	{
		private var _obstacles					:Vector.<ObstacleBehaviour>;
		
		public var globals						:GlobalsProcess;
		private var _worldBounds				:WorldBounds2D;
		
		public var worldBoundsRect				:Rectangle = new Rectangle(0, 0, 800, 600);
		
		[Serializable][Inspectable(priority="50") ]
		public var obstacleGap				:Number = 1200;		
		[Serializable][Inspectable(priority="51") ]
		public var obstacleSpeed			:Number = 300;
			
		private var _obstaclesPool				:Pool; 				// Obstacles pool with a maximum cap for reuse of items.
		private var _obstacleGapCount			:Number = 0; 		// Obstacle count - to track the frequency of obstacles.
		private var _obstaclesToAnimate			:Vector.<Entity>;	// Obstacles to animate.
		private var _obstaclesToAnimateLength	:uint = 0;			// Obstacles to animate - array length.
		
		private var _hitTestX:int;
		private var _hitTestY:int;
		
		private var _hitTestSkin				:AbstractSkin2D;
		private var _obstaclesContainer			:IComponentContainer;

		//SOUNDS
		public var soundProcess					:SoundProcess;				
		private var _hitSound					:ISound;
		private var _hurtSound					:ISound;
	
		public function ObstaclesProcess()
		{
			_obstacles = new Vector.<ObstacleBehaviour>();
			
			// Initialize items-to-animate vector.
			_obstaclesToAnimate = new Vector.<Entity>();
			_obstaclesToAnimateLength = 0;
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(WorldBounds2D, "worldBounds");
			addSceneReference(GlobalsProcess, "globals");
			addSceneReference(SoundProcess, "soundProcess");
		}
		
		// IInitialisableComponent
		public function init():void
		{
			createObstaclesPool();
		}
		
		// ISteppableComponent
		public function step( dt:Number ):void
		{
			if (!globals || globals.paused) return;
			
			if ( globals.gameState == GlobalsProcess.GAME_STATE_FLYING ) 
			{
				// Create obstacles.
				initObstacle();
				
				// Store the hero's current x and y positions (needed for animations below).
				if (_hitTestSkin) {
					_hitTestX = _hitTestSkin.x;
					_hitTestY = _hitTestSkin.y;
				}
				
				animateObstacles();
			}
			else if ( globals.gameState == GlobalsProcess.GAME_STATE_OVER ) 
			{
				for(var j:uint = 0; j < _obstaclesToAnimateLength; j++)
				{
					if (_obstaclesToAnimate[j] != null)
					{
						// Dispose the obstacle temporarily.
						disposeObstacleTemporarily(j, _obstaclesToAnimate[j]);
					}
				}
			}			
		}
		
		public function set worldBounds( value:WorldBounds2D ):void
		{
			if ( _worldBounds ) {
				_worldBounds.removeEventListener( InvalidationEvent.INVALIDATE, invalidateWorldBoundsHandler );
			}
			
			_worldBounds = value;
			
			if ( _worldBounds ) {
				worldBoundsRect = _worldBounds.getRect();
				_worldBounds.addEventListener( InvalidationEvent.INVALIDATE, invalidateWorldBoundsHandler );
			}
		}
		public function get worldBounds():WorldBounds2D { return _worldBounds; }
		
		private function invalidateWorldBoundsHandler( event:InvalidationEvent ):void
		{
			worldBoundsRect = _worldBounds.getRect();
		}
		
		// -------------------------------------------------------------------------------------
		// PUBLIC API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="50" )]
		public function set hitTestSkin( value:AbstractSkin2D ):void
		{
			_hitTestSkin = value;
		}
		public function get hitTestSkin():AbstractSkin2D { return _hitTestSkin; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="51" )]
		public function set obstaclesContainer( value:IComponentContainer ):void
		{
			_obstaclesContainer = value;
		}
		public function get obstaclesContainer():IComponentContainer { return _obstaclesContainer; }
		
		// SOUNDS
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="53" )]
		public function set hitSound( value:ISound ):void
		{
			_hitSound = value;
		}
		public function get hitSound():ISound { return _hitSound; }

		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="54" )]
		public function set hurtSound( value:ISound ):void
		{
			_hurtSound = value;
		}
		public function get hurtSound():ISound { return _hurtSound; }		
		
		// -------------------------------------------------------------------------------------
		
		/**
		 * Create obstacles pool by passing the create and clean methods/functions to the Pool.  
		 * 
		 */
		private function createObstaclesPool():void
		{
			if (!_obstaclesContainer) {
				_obstaclesContainer = parentComponent;
			}
			
			var behaviour:ObstacleBehaviour;
			
			for ( var i:uint = 0; i < _obstaclesContainer.children.length; i ++ ) 
			{
				var child:Component = _obstaclesContainer.children[i];
				
				if (child is Entity) {
					var entity:Entity = Entity(child);
					behaviour = ComponentUtil.getChildOfType(entity, ObstacleBehaviour);
					if ( behaviour ) {	
						_obstacles.push( behaviour );
					}
				}
			}
			
			// Remove skins
			for ( i = 0; i < _obstacles.length; i ++ ) {
				behaviour = _obstacles[i];
				var defaultSkin:ImageSkin = behaviour.defaultSkin;
				var crashSkin:ImageSkin = behaviour.crashSkin;
				behaviour.parentComponent.children.removeItem(defaultSkin);
				behaviour.parentComponent.children.removeItem(crashSkin);
			}
			
			_obstaclesPool = new Pool(obstacleCreate, obstacleClean, 4, 10);
		}
		
		private function obstacleCreate():Entity
		{
			var obstacle:Entity = new Entity();
			_obstaclesContainer.children.addItem(obstacle);
			// Add the default ImageSkin to the obstacle entity
			var defaultSkin:MovieClipSkin = new MovieClipSkin();
			obstacle.children.addItem(defaultSkin);
			// Add the crash ImageSkin to the obstacle entity
			var crashSkin:MovieClipSkin = new MovieClipSkin();
			obstacle.children.addItem(crashSkin);
			// Add the lookOut! Skin to the scene (not to the obstacle entity, as we need
			// it to be independent of the obstacle's Transform2D)
			var warningSkin:MovieClipSkin = new MovieClipSkin();
			scene.children.addItem(warningSkin);
			// Add the Transform2D to the obstacle entity
			var transform:Transform2D = new Transform2D();
			obstacle.children.addItem(transform);
			// Add the ObstacleBehaviour to the obstacle entity
			var behaviour:ObstacleBehaviour = new ObstacleBehaviour();
			obstacle.children.addItem(behaviour);
			behaviour.defaultSkin = defaultSkin;
			behaviour.crashSkin = crashSkin;
			behaviour.warningSkin = warningSkin;
			behaviour.transform = transform;
			
			return obstacle;
		}
		
		private function obstacleClean(obstacle:Entity):void
		{
			var transform2D:Transform2D = ComponentUtil.getChildOfType(obstacle, Transform2D);
			//transform2D.x = stage.stageWidth + obstacle.width * 2;
			transform2D.x = worldBoundsRect.width * 2;
		}
		
		private function checkOutItem(distance:Number):Entity
		{
			var itemToTrack:Entity = Entity(_obstaclesPool.checkOut());
			
			if (!itemToTrack || _obstacles.length == 0) return null;
			
			// Get random obstacle
			var randBehaviour:ObstacleBehaviour = _obstacles[Math.round(Math.random() * (_obstacles.length-1))];
			
			var behaviour:ObstacleBehaviour = ComponentUtil.getChildOfType(itemToTrack, ObstacleBehaviour);
			// Apply skins
			behaviour.defaultSkin.textureAtlas = randBehaviour.defaultSkin.textureAtlas;
			behaviour.defaultSkin.texturesPrefix = randBehaviour.defaultSkin.texturesPrefix;
			
			if ( randBehaviour.defaultSkin is MovieClipSkin ) {
				MovieClipSkin(behaviour.defaultSkin).loop = MovieClipSkin(randBehaviour.defaultSkin).loop;
			}
			
			if ( randBehaviour.crashSkin is MovieClipSkin ) {
				MovieClipSkin(behaviour.crashSkin).loop = MovieClipSkin(randBehaviour.crashSkin).loop;
			}
			
			behaviour.crashSkin.textureAtlas = randBehaviour.crashSkin.textureAtlas;
			behaviour.crashSkin.texturesPrefix = randBehaviour.crashSkin.texturesPrefix;
			behaviour.warningSkin.textureAtlas = randBehaviour.warningSkin.textureAtlas;
			behaviour.warningSkin.texturesPrefix = randBehaviour.warningSkin.texturesPrefix;
			behaviour.warningSkin.loop = randBehaviour.warningSkin.loop;
			behaviour.init();
			behaviour.distance = distance;
			behaviour.transform.x = worldBoundsRect.right;
			
			// For only one of the obstacles, make it appear in either the top or bottom of the screen.
			if ( Math.random() > 0.5 )
			{
				// Place it on the top of the screen.
				if (Math.random() > 0.5)
				{
					behaviour.transform.y = worldBoundsRect.top;
					behaviour.position = "top";
				}
				else
				{
					// Or place it in the bottom of the screen.
					behaviour.transform.y = worldBoundsRect.bottom - behaviour.defaultSkin.height;
					behaviour.position = "bottom";
				}
			}
			else
			{
				// Otherwise, if it's any other obstacle type, put it somewhere in the middle of the screen.
				behaviour.transform.y = Math.floor(Math.random() * (worldBoundsRect.bottom-behaviour.defaultSkin.height - worldBoundsRect.top + 1)) + worldBoundsRect.top;
				behaviour.position = "middle";
			}
			
			// Set the obstacle's speed.
			behaviour.speed = obstacleSpeed;
			
			// Set look out mode to true, during which, a look out text appears.
			behaviour.lookOut = true;
			
			var xpos:Number = behaviour.transform.x - behaviour.warningSkin.width;
			if ( behaviour.warningSkin.width ) xpos -= 20;
			
			behaviour.warningSkin.x = xpos;
			behaviour.warningSkin.y = behaviour.transform.y + (behaviour.defaultSkin.height * 0.5);

			// Animate the obstacle.
			_obstaclesToAnimate[_obstaclesToAnimateLength++] = itemToTrack;
			
			return itemToTrack;
		}
		
		/**
		 * Create an obstacle after hero has travelled a certain distance.
		 * 
		 */
		private function initObstacle():void
		{
			if (!globals) return;
			
			// Create an obstacle after hero travels some distance (obstacleGap).
			if (_obstacleGapCount < obstacleGap)
			{
				_obstacleGapCount += globals.playerSpeed * globals.elapsed;
			}
			else if (_obstacleGapCount != 0)
			{
				//var randObstacle:AbstractSkin2D = obstacles[Math.round(Math.random() * (obstacles.length-1))];
				_obstacleGapCount = 0;
				
				// Create any one of the obstacles.
				checkOutItem(Math.random() * 1000 + 1000);
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
			if (!globals || globals.paused) return;

			var heroRect:Rectangle;
			var obstacleRect:Rectangle;
			
			for (var i:uint = 0; i < _obstaclesToAnimateLength; i ++)
			{
				var obstacleToTrack:Entity = _obstaclesToAnimate[i];
				var behaviour:ObstacleBehaviour = ComponentUtil.getChildOfType(obstacleToTrack, ObstacleBehaviour); 
				
				// If the distance is still more than 0, keep reducing its value, without moving the obstacle.
				if (behaviour.distance > 0 ) 
				{
					behaviour.distance -= globals.playerSpeed * globals.elapsed;  
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
					behaviour.transform.x -= (globals.playerSpeed + behaviour.speed) * globals.elapsed; 
				}
				
				// If the obstacle passes beyond the screen, remove it.
				if (behaviour.transform.x < -behaviour.defaultSkin.width || globals.gameState == GlobalsProcess.GAME_STATE_OVER)
				{
					behaviour.lookOut = false;
					disposeObstacleTemporarily(i, obstacleToTrack);
				}
				
				// Collision detection - Check if hero collides with any obstacle.
				var xDistance:Number = behaviour.transform.x - _hitTestX;
				var yDistance:Number = behaviour.transform.y - _hitTestY;
				var h:Number = Math.sqrt( xDistance * xDistance + yDistance * yDistance );
				var hitDistance:Number = hitTestSkin ? hitTestSkin.width / 2 : 100;
				
				if ( h < hitDistance  && !behaviour.alreadyHit )
				{
					behaviour.alreadyHit = true;
					
					if ( soundProcess && _hitSound ) soundProcess.playSound(_hitSound);
					
					//if (coffee > 0) 
					if ( globals.playerSpeed > globals.playerMinSpeed )
					{
						// If hero has a coffee item, break through the obstacle.
						if (behaviour.position == "bottom") behaviour.transform.rotation = deg2rad(100);
						else behaviour.transform.rotation = deg2rad(-100);
						
						// Set hit obstacle value.
						globals.hitObstacle = 30;
						
						// Reduce hero's speed
						globals.playerSpeed *= 0.8; 
					}
					else 
					{
						if (behaviour.position == "bottom") {
							behaviour.transform.rotation = deg2rad(70);
						} else {
							behaviour.transform.rotation = deg2rad(-70);
						}
						
						// Otherwise, if hero doesn't have a coffee item, set hit obstacle value.
						globals.hitObstacle = 30; 
						
						// Reduce hero's speed.
						globals.playerSpeed *= 0.5; 
										
						// Play hurt sound.
						if ( soundProcess && _hurtSound ) soundProcess.playSound(hurtSound);
					
						// Update lives.
						globals.currentLives--;
					}
				}
			}
		}		
		
		private function disposeObstacleTemporarily(animateId:uint, obstacle:Entity):void
		{
			_obstaclesToAnimate.splice(animateId, 1);
			_obstaclesToAnimateLength--;
			_obstaclesPool.checkIn(obstacle);
		}
	}
}













