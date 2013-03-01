package controller
{
	import flash.media.SoundMixer;
	
	import events.NavigationEvent;
	
	import model.GameModel_Code;
	
	import sound.Sounds;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	import view.GameView;

	public class GameViewController implements IController
	{
		private var _view			:GameView;
		
		/** Is game currently in paused state? */
		private var gamePaused:Boolean = false;
		
		/** Tween object for game over container. */
		private var tween_gameOverContainer:Tween;
		
		private var gameModel		:GameModel_Code;
		
		public function GameViewController()
		{
		}
		
		public function init(view:DisplayObjectContainer):void
		{
			_view	= GameView(view);
			
			gameModel = new GameModel_Code();
			
			enable();
		}
		
		public function reInit():void
		{
			enable();
		}
		
		public function dispose():void
		{
			disable();
		}
		
		public function enable():void
		{
			_view.visible = true;
			
			_view.initialize();
			
			_view.pauseButton.addEventListener(Event.TRIGGERED, onPauseButtonClick);
			_view.startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			_view.gameOverContainer.addEventListener(NavigationEvent.CHANGE_SCREEN, playAgain);
		}
		
		public function disable():void
		{
			SoundMixer.stopAll();
			
			_view.visible = false;
			
			_view.disposeTemporarily();
			
			_view.pauseButton.removeEventListener(Event.TRIGGERED, onPauseButtonClick);
			_view.startButton.removeEventListener(Event.TRIGGERED, onStartButtonClick);
			_view.gameOverContainer.removeEventListener(NavigationEvent.CHANGE_SCREEN, playAgain);
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
		 * Play again, when clicked on play again button in Game Over screen. 
		 * 
		 */
		private function playAgain(event:NavigationEvent):void
		{
			if (event.params.id == "playAgain") 
			{
				tween_gameOverContainer = new Tween(_view.gameOverContainer, 1);
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
			_view.gameOverContainer.visible = false;
			_view.initialize();
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
			_view.startButton.visible = false;
			
			// Show pause button since the game is started.
			_view.pauseButton.visible = true;
			
			// Launch hero.
			//launchHero();
			gameModel.init(_view.gameWindow);
		}
	}
}







