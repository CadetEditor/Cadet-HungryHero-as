package controller
{
	import flash.media.SoundMixer;
	
	import cadet.util.ComponentUtil;
	
	import events.NavigationEvent;
	
	import hungryHero.components.processes.GlobalsProcess;
	
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
		
		/** Tween object for game over container. */
		private var tween_gameOverContainer:Tween;
		
		private var gameModel		:GameModel_Code;
		
		private var globals			:GlobalsProcess;
		
		public function GameViewController()
		{
		}
		
		public function init(view:DisplayObjectContainer):void
		{
			_view	= GameView(view);
			
			gameModel = new GameModel_Code();
			gameModel.init(_view.gameWindow);
			
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
			
			globals.paused = !globals.paused;
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
			globals = ComponentUtil.getChildOfType( gameModel.cadetScene, GlobalsProcess );
			globals.paused = false;
		}
	}
}







