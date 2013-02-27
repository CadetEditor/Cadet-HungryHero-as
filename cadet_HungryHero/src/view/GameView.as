package view
{
	import flash.media.SoundMixer;
	
	import assets.Assets;
	
	import events.NavigationEvent;
	
	import sound.Sounds;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import ui.GameOverContainer;
	import ui.HUD;
	import ui.PauseButton;
	
	public class GameView extends Sprite
	{
		/** Is game currently in paused state? */
		private var gamePaused:Boolean = false;
		
		// ------------------------------------------------------------------------------------------------------------
		// HUD
		// ------------------------------------------------------------------------------------------------------------
		
		/** HUD Container. */		
		private var hud:HUD;
		
		// ------------------------------------------------------------------------------------------------------------
		// INTERFACE OBJECTS
		// ------------------------------------------------------------------------------------------------------------
		
		/** GameOver Container. */
		private var gameOverContainer:GameOverContainer;
		
		/** Pause button. */
		private var pauseButton:PauseButton;
		
		/** Kick Off button in the beginning of the game .*/
		private var startButton:Button;
		
		/** Tween object for game over container. */
		private var tween_gameOverContainer:Tween;
		
		public function GameView()
		{
			// Is hardware rendering?
			//isHardwareRendering = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
			
			this.visible = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * On added to stage.  
		 * @param event
		 * 
		 */
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			drawSceen();
			drawHUD();
			drawGameOverScreen();
		}
		
		/**
		 * Initialize the game. 
		 * 
		 */
		public function initialize():void
		{
			// Dispose screen temporarily.
			disposeTemporarily();
			
			this.visible = true;
			
			// Play screen background music.
			//if (!Sounds.muted) Sounds.sndBgGame.play(0, 999);
			
			// Define lives.
			//lives = GameConstants.HERO_LIVES;

			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
			hud.lives = 0;//lives;
			
			// Hide the pause button since the game isn't started yet.
			pauseButton.visible = false;
			
			// Show start button.
			startButton.visible = true;
		}
		
		/**
		 * Dispose screen temporarily. 
		 * 
		 */
		private function disposeTemporarily():void
		{
			SoundMixer.stopAll();
			
			gameOverContainer.visible = false;
		}
		
		/**
		 * On start button click. 
		 * @param event
		 * 
		 */
		private function onStartButtonClick(event:Event):void
		{
			// Play coffee sound for button click.
			if (!Sounds.muted) Sounds.sndCoffee.play();
			
			// Hide start button.
			startButton.visible = false;
			
			// Show pause button since the game is started.
			pauseButton.visible = true;
			
			// Launch hero.
			//launchHero();
		}
		
		/**
		 * Draw game elements - background, hero, particles, pause button, start button and items (in pool). 
		 * 
		 */
		private function drawSceen():void
		{			
			// Pause button.
			pauseButton = new PauseButton();
			pauseButton.x = pauseButton.width * 2;
			pauseButton.y = pauseButton.height * 0.5;
			pauseButton.addEventListener(Event.TRIGGERED, onPauseButtonClick);
			this.addChild(pauseButton);
			
			// Start button.
			startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			startButton.fontColor = 0xffffff;
			startButton.x = stage.stageWidth/2 - startButton.width/2;
			startButton.y = stage.stageHeight/2 - startButton.height/2;
			startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			this.addChild(startButton);
		}
		
		/**
		 * On click of pause button. 
		 * @param event
		 * 
		 */
		private function onPauseButtonClick(event:Event):void
		{
			event.stopImmediatePropagation();
			
			// Pause or unpause the game.
			if (gamePaused) gamePaused = false;
			else gamePaused = true;
			
			// PAUSE GAME
		}
		
		/**
		 * Draw Heads Up Display. 
		 * 
		 */
		private function drawHUD():void
		{
			hud = new HUD();
			this.addChild(hud);
		}
		
		/**
		 * Draw game over screen. 
		 * 
		 */
		private function drawGameOverScreen():void
		{
			gameOverContainer = new GameOverContainer();
			gameOverContainer.addEventListener(NavigationEvent.CHANGE_SCREEN, playAgain);
			this.addChild(gameOverContainer);
		}
		
		/**
		 * Play again, when clicked on play again button in Game Over screen. 
		 * 
		 */
		private function playAgain(event:NavigationEvent):void
		{
			if (event.params.id == "playAgain") 
			{
				tween_gameOverContainer = new Tween(gameOverContainer, 1);
				tween_gameOverContainer.fadeTo(0);
				tween_gameOverContainer.onComplete = gameOverFadedOut;
				Starling.juggler.add(tween_gameOverContainer);
			}
		}
		
		/**
		 * On game over screen faded out. 
		 * 
		 */
		private function gameOverFadedOut():void
		{
			gameOverContainer.visible = false;
			initialize();
		}
	}
}