package hungryHero.components.processes
{
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import cadet.core.Component;
	import cadet.core.ComponentContainer;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	
	import hungryHero.components.behaviours.ItemBehaviour;
	import hungryHero.pools.Pool;

	public class ItemSpawner extends Component implements ISteppableComponent
	{
		private var _initialised	:Boolean = false;
		private var items			:Array;
		
		private var timer			:Timer;
		
		public var renderer			:Renderer2D;
		
		private var patternPosY		:int;
		
		private var itemsPool		:Pool;
		
		private var itemsToAnimate:Vector.<AbstractSkin2D>;
		private var itemsToAnimateLength:uint = 0;
		
		private var elapsed			:Number;
		
		public function ItemSpawner()
		{
			items = [];
			
			// Initialize items-to-animate vector.
			itemsToAnimate = new Vector.<AbstractSkin2D>();
			itemsToAnimateLength = 0;
			
			timer = new Timer(50);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
		}
		
		override protected function removedFromScene():void
		{
			timer.stop();
			timer = null;
		}
		
		public function step( dt:Number ):void
		{
			elapsed = dt;
			
			if (!renderer || !renderer.viewport) return;
			
			if (!_initialised) {
				initialise();
			}
			
			//reuseAndConfigureItem();
			
			animateFoodItems();
		}
		
		private function initialise():void
		{
			timer.reset();
			timer.start();
			
			for ( var i:uint = 0; i < parentComponent.children.length; i ++ ) 
			{
				var child:Component = parentComponent.children[i];
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
			
			_initialised = true;
		}
		
		private function itemCreate():AbstractSkin2D
		{
			//var item:Entity = items[0];
			var skin:AbstractSkin2D = items[0];//ComponentUtil.getChildOfType(item, AbstractSkin2D);
			
//			var entity:Entity = new Entity();
//			scene.children.addItem(entity);
			
			var newSkin:ImageSkin = ImageSkin(skin.clone());
			//entity.children.addItem(newSkin);
			scene.children.addItem(newSkin);
			
			newSkin.x = renderer.viewport.stage.stageWidth;
			newSkin.y = Math.random() * 400;
			newSkin.validateNow();			
			
//			var newItemBehaviour:ItemBehaviour = new ItemBehaviour();
//			entity.children.addItem(newItemBehaviour);
			
			//return entity;
			return newSkin;
		}
		
		private function itemClean(skin:AbstractSkin2D):void
		{
			
		}
		
/*		private function entityIsItem( entity:Component ):Boolean
		{
			if ( entity is ComponentContainer ) {
				var container:ComponentContainer = ComponentContainer(entity);
				for ( var i:uint = 0; i < container.children.length; i ++ ) {
					var child:Component = container.children[i];
					if ( child is ItemBehaviour ) {
						return true;
					}
				}
			}
			
			return false;
		}*/
		
		private function timerHandler( event:TimerEvent ):void
		{
			reuseAndConfigureItem();
		}
		
		private function reuseAndConfigureItem():void
		{
			var itemToTrack:AbstractSkin2D;
			var skin:AbstractSkin2D;
			
			var pattern:int = 1;
			
			var gameArea:Rectangle = new Rectangle(0, 0, renderer.viewport.stage.stageWidth, renderer.viewport.stage.stageHeight);
			
			switch (pattern)
			{
				case 1:
					// Horizonatl, creates a single food item, and changes the position of the pattern randomly.
					if (Math.random() > 0.9)
					{
						// Set a new random position for the item, making sure it's not too close to the edges of the screen.
						patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					}
					
					// Checkout item from pool and set the type of item.
					itemToTrack = AbstractSkin2D(itemsPool.checkOut());
				//	itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
					
					//skin = ComponentUtil.getChildOfType(itemToTrack, AbstractSkin2D);
					
					// Reset position of item.
//					itemToTrack.x = stage.stageWidth + itemToTrack.width;
//					itemToTrack.y = patternPosY;
					
					itemToTrack.x = renderer.viewport.stage.stageWidth;
					itemToTrack.y = patternPosY;
					itemToTrack.validateNow();	
					
					// Mark the item for animation.
					itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
					break;
				/*
				case 2:
					// Vertical, creates a line of food items that could be the height of the entire screen or just a small part of it.
					if (patternOnce == true)
					{
						patternOnce = false;
						
						// Set a random position not further than half the screen.
						patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
						
						// Set a random length not shorter than 0.4 of the screen, and not longer than 0.8 of the screen.
						patternLength = (Math.random() * 0.4 + 0.4) * stage.stageHeight;
					}
					
					// Set the start position of the food items pattern.
					patternPosYstart = patternPosY; 
					
					// Create a line based on the height of patternLength, but not exceeding the height of the screen.
					while (patternPosYstart + patternStep < patternPosY + patternLength && patternPosYstart + patternStep < stage.stageHeight * 0.8)
					{
						// Checkout item from pool and set the type of item.
						itemToTrack = itemsPool.checkOut();
						itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
						
						// Reset position of item.
						itemToTrack.x = stage.stageWidth + itemToTrack.width;
						itemToTrack.y = patternPosYstart;
						
						// Mark the item for animation.
						itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
						
						// Increase the position of the next item based on patternStep.
						patternPosYstart += patternStep;
					}
					break;
				
				case 3:
					// ZigZag, creates a single item at a position, and then moves bottom
					// until it hits the edge of the screen, then changes its direction and creates items
					// until it hits the upper edge.
					
					// Switch the direction of the food items pattern if we hit the edge.
					if (patternDirection == 1 && patternPosY > gameArea.bottom - 50)
					{
						patternDirection = -1;
					}
					else if ( patternDirection == -1 && patternPosY < gameArea.top )
					{
						patternDirection = 1;
					}
					
					if (patternPosY >= gameArea.top && patternPosY <= gameArea.bottom)
					{
						// Checkout item from pool and set the type of item.
						itemToTrack = itemsPool.checkOut();
						itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
						
						// Reset position of item.
						itemToTrack.x = stage.stageWidth + itemToTrack.width;
						itemToTrack.y = patternPosY;
						
						// Mark the item for animation.
						itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
						
						// Increase the position of the next item based on patternStep and patternDirection.
						patternPosY += patternStep * patternDirection;
					}
					else
					{
						patternPosY = gameArea.top;
					}
					
					break;
				
				case 4:
					// Random, creates a random number of items along the screen.
					if (Math.random() > 0.3)
					{
						// Choose a random starting position along the screen.
						patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
						
						// Place some items on the screen, but don't go past the screen edge
						while (patternPosY + patternStep < gameArea.bottom)
						{
							// Checkout item from pool and set the type of item.
							itemToTrack = itemsPool.checkOut();
							itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
							
							// Reset position of item.
							itemToTrack.x = stage.stageWidth + itemToTrack.width;
							itemToTrack.y = patternPosY;
							
							// Mark the item for animation.
							itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
							
							// Increase the position of the next item by a random value.
							patternPosY += Math.round(Math.random() * 100 + 100);
						}
					}
					break;
				
				case 10:
					// Coffee, this item gives you extra speed for a while, and lets you break through obstacles.
					
					// Set a new random position for the item, making sure it's not too close to the edges of the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Checkout item from pool and set the type of item.
					itemToTrack = itemsPool.checkOut();
					itemToTrack.foodItemType = Math.ceil(Math.random() * 2) + 5;
					
					// Reset position of item.
					itemToTrack.x = stage.stageWidth + itemToTrack.width;
					itemToTrack.y = patternPosY;
					
					// Mark the item for animation.
					itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
					break;
				
				case 11:
					// Mushroom, this item makes all the food items fly towards the hero for a while.
					
					// Set a new random position for the food item, making sure it's not too close to the edges of the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Checkout item from pool and set the type of item.
					itemToTrack = itemsPool.checkOut();
					itemToTrack.foodItemType = Math.ceil(Math.random() * 2) + 5;
					
					// Reset position of item.
					itemToTrack.x = stage.stageWidth + itemToTrack.width;
					itemToTrack.y = patternPosY;
					
					// Mark the item for animation.
					itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
					
					break;
				*/
			}
		}
		
		private function animateFoodItems():void
		{
			var itemToTrack:AbstractSkin2D;
			
			var playerSpeed:uint = 10;
			
			for(var i:uint = 0;i<itemsToAnimateLength;i++)
			{
				itemToTrack = itemsToAnimate[i];
				
				if (itemToTrack != null)
				{
					// If hero has eaten a mushroom, make all the items move towards him.
/*					if (mushroom > 0 && itemToTrack.foodItemType <= GameConstants.ITEM_TYPE_5)
					{
						// Move the item towards the player.
						itemToTrack.x -= (itemToTrack.x - heroX) * 0.2;
						itemToTrack.y -= (itemToTrack.y - heroY) * 0.2;
					}
					else
					{*/
						// If hero hasn't eaten a mushroom,
						// Move the items normally towards the left.
						itemToTrack.x -= playerSpeed;// * elapsed; 
//					}
					
					// If the item passes outside the screen on the left, remove it (check-in).
					
					if (itemToTrack.x < -80)// || gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeItemTemporarily(i, itemToTrack);
					}
/*					else
					{
						// Collision detection - Check if the hero eats a food item.
						heroItem_xDist = itemToTrack.x - heroX;
						heroItem_yDist = itemToTrack.y - heroY;
						heroItem_sqDist = heroItem_xDist * heroItem_xDist + heroItem_yDist * heroItem_yDist;
						
						if (heroItem_sqDist < 5000)
						{
							// If hero eats an item, add up the score.
							if (itemToTrack.foodItemType <= GameConstants.ITEM_TYPE_5)
							{
								scoreItems += itemToTrack.foodItemType;
								hud.foodScore = scoreItems;
								if (!Sounds.muted) Sounds.sndEat.play();
							}
							else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_COFFEE) 
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
							
							// Dispose the food item.
							disposeItemTemporarily(i, itemToTrack);
						}
					}*/
				}
			}
		}
		
		private function disposeItemTemporarily(animateId:uint, item:AbstractSkin2D):void
		{
			itemsToAnimate.splice(animateId, 1);
			itemsToAnimateLength--;
			
			item.x = renderer.viewport.stage.stageWidth + item.width * 2;
			
			itemsPool.checkIn(item);
		}
	}
}










