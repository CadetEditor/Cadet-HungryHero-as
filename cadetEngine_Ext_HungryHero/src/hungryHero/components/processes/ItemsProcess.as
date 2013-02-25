package hungryHero.components.processes
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import cadet.core.Component;
	import cadet.core.ComponentContainer;
	import cadet.core.IComponentContainer;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	
	import hungryHero.components.behaviours.IMoveBehaviour;
	import hungryHero.components.behaviours.IPowerupBehaviour;
	import hungryHero.pools.Pool;

	public class ItemsProcess extends ComponentContainer implements ISteppableComponent
	{
		private var _initialised	:Boolean = false;
		private var items			:Array;
		private var powerups		:Array;
		private var allItems		:Array;
		private var powerupsTable	:Dictionary;
		private var activePowerups	:Array;
		
		public var renderer			:Renderer2D;
		public var globals			:GlobalsProcess;
	
		private var itemsPool		:Pool;
		//private var powerupsPool	:Pool;
		
		private var itemsToAnimate:Vector.<AbstractSkin2D>;
		private var itemsToAnimateLength:uint = 0;

		private var gameArea		:Rectangle;
		
		/** Time calculation for animation. */
		private var timePrevious:Number;
		private var timeCurrent:Number;
		private var elapsed:Number;
		
		// ------------------------------------------------------------------------------------------------------------
		// ITEM GENERATION
		// ------------------------------------------------------------------------------------------------------------
		
		/** Current pattern of food items - 0 = horizontal, 1 = vertical, 2 = zigzag, 3 = random, 4 = special item. */
		private var pattern:int;
		
		/** Current y position of the item in the pattern. */
		private var patternPosY:int;
		
		/** How far away are the patterns created vertically. */
		private var patternStep:int;
		
		/** Direction of the pattern creation - used only for zigzag. */
		private var patternDirection:int;
		
		/** Gap between each item in the pattern horizontally. */
		private var patternGap:Number;
		
		/** Pattern gap counter. */
		private var patternGapCount:Number;
		
		/** How far should the player fly before the pattern changes. */
		private var patternChange:Number;
		
		/** How long are patterns created verticaly? */
		private var patternLength:Number;
		
		/** A trigger used if we want to run a one-time command in a pattern. */
		private var patternOnce:Boolean;
		
		/** Y position for the entire pattern - Used for vertical pattern only. */
		private var patternPosYstart:Number;
		
		/** Hero's current X position. */
		private var heroX:int;
		
		/** Hero's current Y position. */
		private var heroY:int;
		
		/** Collision detection for hero vs items. */
		private var heroItem_xDist:Number;
		private var heroItem_yDist:Number;
		private var heroItem_sqDist:Number;
		
		/** Collision detection for hero vs obstacles. */
		private var heroObstacle_xDist:Number;
		private var heroObstacle_yDist:Number;
		private var heroObstacle_sqDist:Number;
		
		private var playerSpeed		:int = 650;
		
		private var _hitTestSkin			:AbstractSkin2D;
		private var _itemsContainer			:IComponentContainer;
		private var _powerupsContainer		:IComponentContainer;
		
		private var _moveBehaviour			:IMoveBehaviour;
		
		[Serializable][Inspectable( priority="52" )]
		public var defaultMoveBehaviour		:IMoveBehaviour;
		
		public function ItemsProcess()
		{
			items = [];
			powerups = [];
			allItems = [];
			powerupsTable = new Dictionary();
			activePowerups = [];
			
			// Initialize items-to-animate vector.
			itemsToAnimate = new Vector.<AbstractSkin2D>();
			itemsToAnimateLength = 0;
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
			addSceneReference(GlobalsProcess, "globals");
			addChildReference(IMoveBehaviour, "defaultMoveBehaviour");
		}
		
		override protected function removedFromScene():void
		{
			
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
		public function set itemsContainer( value:IComponentContainer ):void
		{
			_itemsContainer = value;
		}
		public function get itemsContainer():IComponentContainer
		{
			return _itemsContainer;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="52" )]
		public function set powerupsContainer( value:IComponentContainer ):void
		{
			_powerupsContainer = value;
		}
		public function get powerupsContainer():IComponentContainer
		{
			return _powerupsContainer;
		}
		
		private function calculateElapsed():void
		{
			// Set the current time as the previous time.
			timePrevious = timeCurrent;
			
			// Get teh new current time.
			timeCurrent = getTimer(); 
			
			// Calcualte the time it takes for a frame to pass, in milliseconds.
			elapsed = (timeCurrent - timePrevious) * 0.001; 
		}
		
		public function step( dt:Number ):void
		{
			if ( globals ) {
				playerSpeed = globals.playerSpeed;
			}
			
			
			calculateElapsed();
			
			if (!renderer || !renderer.viewport) return;
			
			if (!_initialised) {
				initialise();
			}
			
			// Create food items.
			setItemsPattern();
			createItemsPattern();
			
			// Create obstacles.
//			initObstacle();
			
			// Store the hero's current x and y positions (needed for animations below).
			if (_hitTestSkin) {
				heroX = _hitTestSkin.x;//hero.x;
				heroY = _hitTestSkin.y;//hero.y;
			}
			
			// Animate elements.
			updateItems();
			updatePowerups();
//			animateObstacles();
//			animateEatParticles();
//			animateWindParticles();
			
			// Set the background's speed based on hero's speed.
//			bg.speed = playerSpeed * elapsed;
		}
		
		private function initialise():void
		{
			createItemsPool();
			createPowerupsPool();
			
			gameArea = new Rectangle(0, 0, renderer.viewport.stage.stageWidth, renderer.viewport.stage.stageHeight);
			
			// Reset item pattern styling.
			pattern = 1;
			patternPosY = gameArea.top;
			patternStep = 15;
			patternDirection = 1;
			patternGap = 20;
			patternGapCount = 0;
			patternChange = 100;
			patternLength = 50;
			patternOnce = true;
			
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
					items.push( child );
				}
			}
			
			for ( i = 0; i < items.length; i ++ ) {
				child = items[i];
				child.parentComponent.children.removeItem(child);
			}
			
			itemsPool = new Pool(itemCreate, itemClean);
			
			allItems = items;
		}
		
		private function createPowerupsPool():void
		{
			if (!_powerupsContainer) {
				_powerupsContainer = parentComponent;
			}
			
			for ( var i:uint = 0; i < _powerupsContainer.children.length; i ++ ) 
			{
				var child:Component = _powerupsContainer.children[i];
				
				if (!child is Entity) continue;
				
				var entity:Entity = Entity(child);
				var skin:ImageSkin = ComponentUtil.getChildOfType(entity, ImageSkin);
				var behaviour:IPowerupBehaviour = ComponentUtil.getChildOfType(entity, IPowerupBehaviour);
				if ( skin && behaviour ) {	
					powerups.push( skin );
					powerupsTable[skin.texturesPrefix] = behaviour;
				}
			}
			
			for ( i = 0; i < powerups.length; i ++ ) {
				child = powerups[i];
				child.parentComponent.children.removeItem(child);
			}
			
			allItems = items.concat(powerups);
			
			//powerupsPool = new Pool(itemCreate, itemClean);
		}
		
		private function itemCreate():AbstractSkin2D
		{
			var skin:MovieClipSkin = new MovieClipSkin();
			
			if (!skin) return null;
			
			var newSkin:MovieClipSkin = MovieClipSkin(skin.clone());
			_itemsContainer.children.addItem(newSkin);
			
			newSkin.x = renderer.viewport.stage.stageWidth;
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
			if (patternGapCount < patternGap )
			{
				patternGapCount += playerSpeed * elapsed;
			}
			else if (pattern != 0)
			{
				// If there is a pattern already set.
				patternGapCount = 0;
				
				// Reuse and configure food item.
				spawnItems();
			}
		}
		
		private function setItemsPattern():void
		{
			// If hero has not travelled the required distance, don't change the pattern.
			if (patternChange > 0) {
				patternChange -= playerSpeed * elapsed;
			} else {
				// If hero has travelled the required distance, change the pattern.
				if ( Math.random() < 0.7 ) {
					// If random number is < normal item chance (0.7), decide on a random pattern for items.
					pattern = Math.ceil(Math.random() * 4); 
				} else {
					// If random number is > normal item chance (0.3), decide on a random special item.
					pattern = Math.ceil(Math.random() * 2) + 9;
				}
				
				if (pattern == 1) {
					// Vertical Pattern
					patternStep = 15;
					patternChange = Math.random() * 500 + 500;
				} else if (pattern == 2) {
					// Horizontal Pattern
					patternOnce = true;
					patternStep = 40;
					patternChange = patternGap * Math.random() * 3 + 5;
				} else if (pattern == 3) {
					// ZigZag Pattern
					patternStep = Math.round(Math.random() * 2 + 2) * 10;
					if ( Math.random() > 0.5 ) {
						patternDirection *= -1;
					}
					patternChange = Math.random() * 800 + 800;
				} else if (pattern == 4) {
					// Random Pattern
					patternStep = Math.round(Math.random() * 3 + 2) * 50;
					patternChange = Math.random() * 400 + 400;
				} else {
					patternChange = 0;
				}
			}
		}
		
		private function checkOutItem(randItem:AbstractSkin2D, x:Number, y:Number):AbstractSkin2D
		{
			var itemToTrack:MovieClipSkin = MovieClipSkin(itemsPool.checkOut());
			
			if (!itemToTrack) return null;
			
			// randItem is either MovieClipSkin or ImageSkin (MovieClipSkin extends ImageSkin)
			var randImgSkin:ImageSkin = ImageSkin(randItem);
			var imgSkin:MovieClipSkin = MovieClipSkin(itemToTrack);
			imgSkin.texture = randImgSkin.texture;
			imgSkin.textureAtlas = randImgSkin.textureAtlas;
			imgSkin.texturesPrefix = randImgSkin.texturesPrefix;
			
			// Reset position of item.
			itemToTrack.x = renderer.viewport.stage.stageWidth;
			itemToTrack.y = patternPosY;
			
			// Mark the item for animation.
			itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
			
			return itemToTrack;
		}
		
		// reuseAndConfigureItem()
		private function spawnItems():void
		{
			var itemToTrack:AbstractSkin2D;
			var skin:AbstractSkin2D;
			// randItem is inputted by user so could be ImageSkin or MovieClipSkin
			var randItem:AbstractSkin2D = items[Math.round(Math.random() * (items.length-1))];
			
			if (!randItem) return;
					
			if ( pattern == 1 ) {
				// Horizontal, creates a single food item, and changes the position of the pattern randomly.
				if (Math.random() > 0.9) {
					// Set a new random position for the item, making sure it's not too close to the edges of the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
				}

				// Checkout item from pool and set the type of item.
				itemToTrack = checkOutItem(randItem, renderer.viewport.stage.stageWidth, patternPosY);
			} else if ( pattern == 2 ) {
				// Vertical, creates a line of food items that could be the height of the entire screen or just a small part of it.
				if (patternOnce == true) {
					patternOnce = false;
					
					// Set a random position not further than half the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Set a random length not shorter than 0.4 of the screen, and not longer than 0.8 of the screen.
					patternLength = (Math.random() * 0.4 + 0.4) * renderer.viewport.stage.stageHeight;//stage.stageHeight;
				}
				
				// Set the start position of the food items pattern.
				patternPosYstart = patternPosY; 
				
				// Create a line based on the height of patternLength, but not exceeding the height of the screen.
				while (patternPosYstart + patternStep < patternPosY + patternLength 
					&& patternPosYstart + patternStep < renderer.viewport.stage.stageHeight * 0.8)
				{
					// Checkout item from pool and set the type of item.
					itemToTrack = checkOutItem(randItem, renderer.viewport.stage.stageWidth, patternPosY);

					// Increase the position of the next item based on patternStep.
					patternPosYstart += patternStep;
				}
			} else if ( pattern == 3 ) {  
				// ZigZag, creates a single item at a position, and then moves bottom
				// until it hits the edge of the screen, then changes its direction and creates items
				// until it hits the upper edge.
				
				// Switch the direction of the food items pattern if we hit the edge.
				if (patternDirection == 1 && patternPosY > gameArea.bottom - 50) {
					patternDirection = -1;
				} else if ( patternDirection == -1 && patternPosY < gameArea.top ) {
					patternDirection = 1;
				}
				
				if (patternPosY >= gameArea.top && patternPosY <= gameArea.bottom) {
					// Checkout item from pool and set the type of item.
					itemToTrack = checkOutItem(randItem, renderer.viewport.stage.stageWidth, patternPosY);

					// Increase the position of the next item based on patternStep and patternDirection.
					patternPosY += patternStep * patternDirection;
				} else {
					patternPosY = gameArea.top;
				}
			} else if ( pattern == 4 ) {
				// Random, creates a random number of items along the screen.
				if (Math.random() > 0.3) {
					// Choose a random starting position along the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Place some items on the screen, but don't go past the screen edge
					while (patternPosY + patternStep < gameArea.bottom)
					{
						// Checkout item from pool and set the type of item.
						itemToTrack = checkOutItem(randItem, renderer.viewport.stage.stageWidth, patternPosY);
						
						// Increase the position of the next item by a random value.
						patternPosY += Math.round(Math.random() * 100 + 100);
					}
				}
			} else if ( pattern == 10 || pattern == 11 ) {
				if ( powerups.length > 0 ) {
					// Coffee, this item gives you extra speed for a while, and lets you break through obstacles.
					// Mushroom, this item makes all the food items fly towards the hero for a while.
					randItem = powerups[Math.round(Math.random() * (powerups.length-1))];
					
					// Set a new random position for the item, making sure it's not too close to the edges of the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Checkout item from pool and set the type of item.
					itemToTrack = checkOutItem(randItem, renderer.viewport.stage.stageWidth, patternPosY);
				}
			}
		}
		
		// animateFoodItems()
		private function updateItems():void
		{
			var itemToTrack:MovieClipSkin;
			
			for(var i:uint = 0;i<itemsToAnimateLength;i++)
			{
				itemToTrack = itemsToAnimate[i];
				
				if (itemToTrack != null)
				{					
					// If it's a powerup, use the defaultMoveBehaviour
					if ( powerupsTable[itemToTrack.texturesPrefix] && defaultMoveBehaviour ) {
						defaultMoveBehaviour.transform = itemToTrack;
						defaultMoveBehaviour.execute();
					} else if (moveBehaviour) {
						moveBehaviour.transform = itemToTrack;
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
						heroItem_xDist = itemToTrack.x - heroX;
						heroItem_yDist = itemToTrack.y - heroY;
						heroItem_sqDist = heroItem_xDist * heroItem_xDist + heroItem_yDist * heroItem_yDist;
						
						if (heroItem_sqDist < 5000)
						{
							var behaviour:IPowerupBehaviour = powerupsTable[itemToTrack.texturesPrefix];
							if ( behaviour ) {
								if ( behaviour is IMoveBehaviour ) {
									moveBehaviour = IMoveBehaviour(behaviour);
									moveBehaviour.init();
								} else {
									activePowerups.push(behaviour);
									behaviour.init();
									behaviour.addEventListener(Event.COMPLETE, powerupCompleteHandler);
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
			for ( var i:uint = 0; i < activePowerups.length; i ++ ) {
				var powerup:IPowerupBehaviour = activePowerups[i];
				powerup.execute();
			}
		}
		
		private function powerupCompleteHandler(event:Event):void
		{
			var behaviour:IPowerupBehaviour = IPowerupBehaviour(event.target);
			behaviour.removeEventListener(Event.COMPLETE, powerupCompleteHandler);
			
			var index:int = activePowerups.indexOf(behaviour);
			activePowerups.splice(index, 1);
		}
		
		[Serializable][Inspectable( priority="51" )]
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
		public function get moveBehaviour():IMoveBehaviour
		{
			return _moveBehaviour;
		}
		
		private function moveBehaviourCompleterHandler( event:Event ):void
		{
			moveBehaviour = defaultMoveBehaviour;
		}
		
		private function disposeItemTemporarily(animateId:uint, item:MovieClipSkin):void
		{
			itemsToAnimate.splice(animateId, 1);
			itemsToAnimateLength--;
			
			item.x = renderer.viewport.stage.stageWidth + item.width * 2;
			
			itemsPool.checkIn(item);
		}
	}
}










