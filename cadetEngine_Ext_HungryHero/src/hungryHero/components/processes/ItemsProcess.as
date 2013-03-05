package hungryHero.components.processes
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cadet.components.sounds.ISound;
	import cadet.core.Component;
	import cadet.core.ComponentContainer;
	import cadet.core.IComponentContainer;
	import cadet.core.ISteppableComponent;
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.transforms.ITransform2D;
	
	import hungryHero.components.behaviours.IMoveBehaviour;
	import hungryHero.components.behaviours.IPowerupBehaviour;
	import hungryHero.pools.Pool;

	public class ItemsProcess extends ComponentContainer implements ISteppableComponent
	{
		private var _initialised			:Boolean = false;
		private var _items					:Vector.<AbstractSkin2D>;
		private var _powerups				:Vector.<AbstractSkin2D>;
		private var _allItems				:Vector.<AbstractSkin2D>;
		private var _activePowerups			:Vector.<IPowerupBehaviour>;
		private var _powerupsTable			:Dictionary;
		
		public var globals					:GlobalsProcess;
		private var _worldBounds			:WorldBounds2D;
		
		public var worldBoundsRect			:Rectangle = new Rectangle(0, 0, 800, 600);
	
		private var _itemsPool				:Pool;
		
		private var _itemsToAnimate			:Vector.<AbstractSkin2D>;
		private var _itemsToAnimateLength	:uint = 0;
		
		// ------------------------------------------------------------------------------------------------------------
		// ITEM GENERATION
		// ------------------------------------------------------------------------------------------------------------

		private var _pattern:int;				// Current pattern of food items - 0 = horizontal, 1 = vertical, 2 = zigzag, 3 = random, 4 = special item.
		private var _patternPosY:int;			// Current y position of the item in the pattern.
		private var _patternStep:int;			// How far away are the patterns created vertically.
		private var _patternDirection:int;		// Direction of the pattern creation - used only for zigzag.
		private var _patternGap:Number;			// Gap between each item in the pattern horizontally.
		private var _patternGapCount:Number;	// Pattern gap counter.
		private var _patternChange:Number;		// How far should the player fly before the pattern changes.
		private var _patternLength:Number;		// How long are patterns created verticaly?
		private var _patternOnce:Boolean; 		// A trigger used if we want to run a one-time command in a pattern.
		private var _patternPosYstart:Number; 	// Y position for the entire pattern - Used for vertical pattern only.
		
		private var _hitTestX:int;
		private var _hitTestY:int;
		
		private var _hitTestSkin			:AbstractSkin2D;
		private var _itemsContainer			:IComponentContainer;
		private var _powerupsContainer		:IComponentContainer;
		
		private var _defaultMoveBehaviour	:IMoveBehaviour;
		private var _moveBehaviour			:IMoveBehaviour;
		
		private var _elapsed					:Number = 0.02;
		private var _playerSpeed				:int = 650;
		
		// SOUNDS
		private var _collectSound			:ISound;
		
		public function ItemsProcess()
		{
			_items = new Vector.<AbstractSkin2D>();
			_powerups = new Vector.<AbstractSkin2D>();
			_allItems = new Vector.<AbstractSkin2D>();
			_powerupsTable = new Dictionary();
			_activePowerups = new Vector.<IPowerupBehaviour>();
			
			// Initialize items-to-animate vector.
			_itemsToAnimate = new Vector.<AbstractSkin2D>();
			_itemsToAnimateLength = 0;
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(WorldBounds2D, "worldBounds");
			addSceneReference(GlobalsProcess, "globals");
			addChildReference(IMoveBehaviour, "defaultMoveBehaviour");
		}
		
		override protected function removedFromScene():void
		{
			
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
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="50" )]
		public function set hitTestSkin( value:AbstractSkin2D ):void
		{
			_hitTestSkin = value;
		}
		public function get hitTestSkin():AbstractSkin2D { return _hitTestSkin; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="51" )]
		public function set itemsContainer( value:IComponentContainer ):void
		{
			_itemsContainer = value;
		}
		public function get itemsContainer():IComponentContainer { return _itemsContainer; }	
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="52" )]
		public function set powerupsContainer( value:IComponentContainer ):void
		{
			_powerupsContainer = value;
		}
		public function get powerupsContainer():IComponentContainer { return _powerupsContainer; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="53" )]
		public function set defaultMoveBehaviour( value:IMoveBehaviour ):void
		{
			_defaultMoveBehaviour = value;
		}
		public function get defaultMoveBehaviour():IMoveBehaviour { return _defaultMoveBehaviour; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="54" )]
		public function set moveBehaviour( value:IMoveBehaviour ):void
		{
			if ( _moveBehaviour ) {
				_moveBehaviour.removeEventListener( Event.COMPLETE, moveBehaviourCompleterHandler );
			}
			_moveBehaviour = value;
			
			if ( _moveBehaviour ) {
				_moveBehaviour.init();
				_moveBehaviour.addEventListener( Event.COMPLETE, moveBehaviourCompleterHandler );
			}
		}
		public function get moveBehaviour():IMoveBehaviour { return _moveBehaviour; }
		
		// SOUNDS
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="55" )]
		public function set collectSound( value:ISound ):void
		{
			_collectSound = value;
		}
		public function get collectSound():ISound { return _collectSound; }
		
		// -------------------------------------------------------------------------------------
		

		
		public function step( dt:Number ):void
		{
			if ( globals ) {
				_playerSpeed = globals.playerSpeed;
				_elapsed = globals.elapsed;
			}
			
//			if (!renderer || !renderer.viewport) return;
			
			if (!_initialised) {
				initialise();
			}
			
			// Create food items.
			setItemsPattern();
			createItemsPattern();
						
			// Store the hero's current x and y positions (needed for animations below).
			if (_hitTestSkin) {
				_hitTestX = _hitTestSkin.x + _hitTestSkin.width/2;//hero.x;
				_hitTestY = _hitTestSkin.y + _hitTestSkin.height/2;//hero.y;
			}
			
			// Animate elements.
			updateItems();
			updatePowerups();
//			animateEatParticles();
//			animateWindParticles();
			
			// Set the background's speed based on hero's speed.
//			bg.speed = playerSpeed * elapsed;
		}
		
		private function initialise():void
		{
			createItemsPool();
			createPowerupsPool();
			
			// Reset item pattern styling.
			_pattern = 1;
			_patternPosY = worldBoundsRect.top;
			_patternStep = 15;
			_patternDirection = 1;
			_patternGap = 20;
			_patternGapCount = 0;
			_patternChange = 100;
			_patternLength = 50;
			_patternOnce = true;
			
			_initialised = true;
			
			if (!moveBehaviour) {
				moveBehaviour = defaultMoveBehaviour;
			}
			
			//scene.children.addItem(_moveItemBehaviour);
		}
		
		private function createItemsPool():void
		{
			if (!_itemsContainer) {
				_itemsContainer = parentComponent;
			}
			
			for ( var i:uint = 0; i < _itemsContainer.children.length; i ++ ) 
			{
				var child:Component = _itemsContainer.children[i];
				//if ( entityIsItem( child ) ) {
				if ( child is AbstractSkin2D ) {	
					_items.push( child );
				}
			}
			
			for ( i = 0; i < _items.length; i ++ ) {
				child = _items[i];
				child.parentComponent.children.removeItem(child);
			}
			
			_itemsPool = new Pool(itemCreate, itemClean);
			
			_allItems = _items;
		}
		
		private function createPowerupsPool():void
		{
			if (!_powerupsContainer) {
				_powerupsContainer = parentComponent;
			}
			
			for ( var i:uint = 0; i < _powerupsContainer.children.length; i ++ ) 
			{
				var child:Component = _powerupsContainer.children[i];
				
				if (child is Entity) {
					var entity:Entity = Entity(child);
					var skin:ImageSkin = ComponentUtil.getChildOfType(entity, ImageSkin);
					var behaviour:IPowerupBehaviour = ComponentUtil.getChildOfType(entity, IPowerupBehaviour);
					if ( skin && behaviour ) {	
						_powerups.push( skin );
						_powerupsTable[skin.texturesPrefix] = behaviour;
					}
				}
			}
			
			for ( i = 0; i < _powerups.length; i ++ ) {
				child = _powerups[i];
				child.parentComponent.children.removeItem(child);
			}
			
			_allItems = _items.concat(_powerups);
			
			//powerupsPool = new Pool(itemCreate, itemClean);
		}
		
		private function itemCreate():AbstractSkin2D
		{			
			var newSkin:MovieClipSkin = new MovieClipSkin();
			_itemsContainer.children.addItem(newSkin);
			
			newSkin.x = worldBoundsRect.right;
			newSkin.y = Math.random() * 400;
			newSkin.validateNow();
			
			return newSkin;
		}
		
		private function itemClean(skin:AbstractSkin2D):void
		{
			
		}
		
		/**
		 * Create food pattern after hero travels for some distance.
		 * 
		 */
		private function createItemsPattern():void
		{
			// Create a food item after we pass some distance (patternGap).
			if (_patternGapCount < _patternGap )
			{
				_patternGapCount += _playerSpeed * _elapsed;
			}
			else if (_pattern != 0)
			{
				// If there is a pattern already set.
				_patternGapCount = 0;
				
				// Reuse and configure food item.
				spawnItems();
			}
		}
		
		private function setItemsPattern():void
		{
			// If hero has not travelled the required distance, don't change the pattern.
			if (_patternChange > 0) {
				_patternChange -= _playerSpeed * _elapsed;
			} else {
				// If hero has travelled the required distance, change the pattern.
				if ( Math.random() < 0.7 ) {
					// If random number is < normal item chance (0.7), decide on a random pattern for items.
					_pattern = Math.ceil(Math.random() * 4); 
				} else {
					// If random number is > normal item chance (0.3), decide on a random special item.
					_pattern = Math.ceil(Math.random() * 2) + 9;
				}
				
				if (_pattern == 1) {
					// Vertical Pattern
					_patternStep = 15;
					_patternChange = Math.random() * 500 + 500;
				} else if (_pattern == 2) {
					// Horizontal Pattern
					_patternOnce = true;
					_patternStep = 40;
					_patternChange = _patternGap * Math.random() * 3 + 5;
				} else if (_pattern == 3) {
					// ZigZag Pattern
					_patternStep = Math.round(Math.random() * 2 + 2) * 10;
					if ( Math.random() > 0.5 ) {
						_patternDirection *= -1;
					}
					_patternChange = Math.random() * 800 + 800;
				} else if (_pattern == 4) {
					// Random Pattern
					_patternStep = Math.round(Math.random() * 3 + 2) * 50;
					_patternChange = Math.random() * 400 + 400;
				} else {
					_patternChange = 0;
				}
			}
		}
		
		private function checkOutItem(randItem:AbstractSkin2D, x:Number, y:Number):AbstractSkin2D
		{
			var itemToTrack:MovieClipSkin = MovieClipSkin(_itemsPool.checkOut());
			
			if (!itemToTrack) return null;
			
			// randItem is either MovieClipSkin or ImageSkin (MovieClipSkin extends ImageSkin)
			var randImgSkin:ImageSkin = ImageSkin(randItem);
			var imgSkin:MovieClipSkin = MovieClipSkin(itemToTrack);
			imgSkin.texture = randImgSkin.texture;
			imgSkin.textureAtlas = randImgSkin.textureAtlas;
			imgSkin.texturesPrefix = randImgSkin.texturesPrefix;
			
			// Reset position of item.
			itemToTrack.x = worldBoundsRect.right;
			itemToTrack.y = _patternPosY;
			
			// Mark the item for animation.
			_itemsToAnimate[_itemsToAnimateLength++] = itemToTrack;
			
			return itemToTrack;
		}
		
		// reuseAndConfigureItem()
		private function spawnItems():void
		{
			var itemToTrack:AbstractSkin2D;
			var skin:AbstractSkin2D;
			// randItem is inputted by user so could be ImageSkin or MovieClipSkin
			var randItem:AbstractSkin2D = _items[Math.round(Math.random() * (_items.length-1))];
			
			if (!randItem) return;
					
			if ( _pattern == 1 ) {
				// Horizontal, creates a single food item, and changes the position of the pattern randomly.
				if (Math.random() > 0.9) {
					// Set a new random position for the item, making sure it's not too close to the edges of the screen.
					_patternPosY = Math.floor(Math.random() * (worldBoundsRect.bottom - worldBoundsRect.top + 1)) + worldBoundsRect.top;
				}

				// Checkout item from pool and set the type of item.
				itemToTrack = checkOutItem(randItem, worldBoundsRect.right, _patternPosY);
			} else if ( _pattern == 2 ) {
				// Vertical, creates a line of food items that could be the height of the entire screen or just a small part of it.
				if (_patternOnce == true) {
					_patternOnce = false;
					
					// Set a random position not further than half the screen.
					_patternPosY = Math.floor(Math.random() * (worldBoundsRect.bottom - worldBoundsRect.top + 1)) + worldBoundsRect.top;
					
					// Set a random length not shorter than 0.4 of the screen, and not longer than 0.8 of the screen.
					_patternLength = (Math.random() * 0.4 + 0.4) * worldBoundsRect.bottom;//stage.stageHeight;
				}
				
				// Set the start position of the food items pattern.
				_patternPosYstart = _patternPosY; 
				
				// Create a line based on the height of patternLength, but not exceeding the height of the screen.
				while (_patternPosYstart + _patternStep < _patternPosY + _patternLength 
					&& _patternPosYstart + _patternStep < worldBoundsRect.bottom * 0.8)
				{
					// Checkout item from pool and set the type of item.
					itemToTrack = checkOutItem(randItem, worldBoundsRect.right, _patternPosY);

					// Increase the position of the next item based on patternStep.
					_patternPosYstart += _patternStep;
				}
			} else if ( _pattern == 3 ) {  
				// ZigZag, creates a single item at a position, and then moves bottom
				// until it hits the edge of the screen, then changes its direction and creates items
				// until it hits the upper edge.
				
				// Switch the direction of the food items pattern if we hit the edge.
				if (_patternDirection == 1 && _patternPosY > worldBoundsRect.bottom - 50) {
					_patternDirection = -1;
				} else if ( _patternDirection == -1 && _patternPosY < worldBoundsRect.top ) {
					_patternDirection = 1;
				}
				
				if (_patternPosY >= worldBoundsRect.top && _patternPosY <= worldBoundsRect.bottom) {
					// Checkout item from pool and set the type of item.
					itemToTrack = checkOutItem(randItem, worldBoundsRect.right, _patternPosY);

					// Increase the position of the next item based on patternStep and patternDirection.
					_patternPosY += _patternStep * _patternDirection;
				} else {
					_patternPosY = worldBoundsRect.top;
				}
			} else if ( _pattern == 4 ) {
				// Random, creates a random number of items along the screen.
				if (Math.random() > 0.3) {
					// Choose a random starting position along the screen.
					_patternPosY = Math.floor(Math.random() * (worldBoundsRect.bottom - worldBoundsRect.top + 1)) + worldBoundsRect.top;
					
					// Place some items on the screen, but don't go past the screen edge
					while (_patternPosY + _patternStep < worldBoundsRect.bottom)
					{
						// Checkout item from pool and set the type of item.
						itemToTrack = checkOutItem(randItem, worldBoundsRect.right, _patternPosY);
						
						// Increase the position of the next item by a random value.
						_patternPosY += Math.round(Math.random() * 100 + 100);
					}
				}
			} else if ( _pattern == 10 || _pattern == 11 ) {
				if ( _powerups.length > 0 ) {
					// Coffee, this item gives you extra speed for a while, and lets you break through obstacles.
					// Mushroom, this item makes all the food items fly towards the hero for a while.
					randItem = _powerups[Math.round(Math.random() * (_powerups.length-1))];
					
					// Set a new random position for the item, making sure it's not too close to the edges of the screen.
					_patternPosY = Math.floor(Math.random() * (worldBoundsRect.bottom - worldBoundsRect.top + 1)) + worldBoundsRect.top;
					
					// Checkout item from pool and set the type of item.
					itemToTrack = checkOutItem(randItem, worldBoundsRect.right, _patternPosY);
				}
			}
		}
		
		// animateFoodItems()
		private function updateItems():void
		{
			var itemToTrack:MovieClipSkin;
			
			for( var i:uint = 0; i < _itemsToAnimateLength; i++ )
			{
				itemToTrack = _itemsToAnimate[i];
				
				if (itemToTrack != null)
				{					
					// If it's a powerup, use the defaultMoveBehaviour
					if ( _powerupsTable[itemToTrack.texturesPrefix] && defaultMoveBehaviour ) {
						defaultMoveBehaviour.transform = ITransform2D(itemToTrack);
						defaultMoveBehaviour.execute();
					} else if (moveBehaviour) {
						moveBehaviour.transform = ITransform2D(itemToTrack);
						moveBehaviour.execute();
					}
					
					// If the item passes outside the screen on the left, remove it (check-in).
					
					// If item
					if (itemToTrack.x < -80)// || gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeItemTemporarily(i, itemToTrack);
					}
					else
					{
						// Collision detection - Check if the hero eats a food item.
						var xDistance:Number = itemToTrack.x - _hitTestX;
						var yDistance:Number = itemToTrack.y - _hitTestY;
						var h:Number = Math.sqrt( xDistance * xDistance + yDistance * yDistance );
						var hitDistance:Number = hitTestSkin ? hitTestSkin.width / 2 : 100;
						
						if ( h < hitDistance )
						{
							var behaviour:IPowerupBehaviour = _powerupsTable[itemToTrack.texturesPrefix];
							if ( behaviour ) {
								if ( behaviour is IMoveBehaviour ) {
									moveBehaviour = IMoveBehaviour(behaviour);
									moveBehaviour.init();
								} else {
									_activePowerups.push(behaviour);
									behaviour.init();
									behaviour.addEventListener(Event.COMPLETE, powerupCompleteHandler);
								}
								
								if ( behaviour.collectSound ) {
									behaviour.collectSound.play();
								}
							} else {
								if ( _collectSound ) {
									_collectSound.play();	
								}
							}
							
							// If hero eats an item, add up the score.
						/*	if (itemToTrack.foodItemType <= GameConstants.ITEM_TYPE_5)
							{
								scoreItems += itemToTrack.foodItemType;
								hud.foodScore = scoreItems;
								if (!Sounds.muted) Sounds.sndEat.play();
							}*/
						/*	else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_COFFEE) 
							{
								// If hero drinks coffee, add up the score.
								scoreItems += 1;
								
								// How long does coffee power last? (in seconds)
								coffee = 5;
								if (isHardwareRendering) particleCoffee.start(coffee);
								
								if (!Sounds.muted) Sounds.sndCoffee.play();
							}
							else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_MUSHROOM) 
							{
								// If hero eats a mushroom, add up the score.
								scoreItems += 1;
								
								// How long does mushroom power last? (in seconds)
								mushroom = 4;
								if (isHardwareRendering) particleMushroom.start(mushroom);
								
								if (!Sounds.muted) Sounds.sndMushroom.play();
							}
							
							// Create an eat particle at the position of the food item that was eaten.
							createEatParticle(itemToTrack);
							*/
							// Dispose the food item.
							disposeItemTemporarily(i, itemToTrack);
						}
					}
				}
			}
		}
		
		private function updatePowerups():void
		{
			for ( var i:uint = 0; i < _activePowerups.length; i ++ ) {
				var powerup:IPowerupBehaviour = _activePowerups[i];
				powerup.execute();
			}
		}
		
		private function powerupCompleteHandler(event:Event):void
		{
			var behaviour:IPowerupBehaviour = IPowerupBehaviour(event.target);
			behaviour.removeEventListener(Event.COMPLETE, powerupCompleteHandler);
			
			var index:int = _activePowerups.indexOf(behaviour);
			_activePowerups.splice(index, 1);
		}
		
		private function moveBehaviourCompleterHandler( event:Event ):void
		{
			moveBehaviour = defaultMoveBehaviour;
		}
		
		private function disposeItemTemporarily(animateId:uint, item:MovieClipSkin):void
		{			
			_itemsToAnimate.splice(animateId, 1);
			_itemsToAnimateLength--;
			
			item.x = worldBoundsRect.right + item.width * 2;
			
			_itemsPool.checkIn(item);
		}
	}
}










