package
{	
	import flash.media.SoundMixer;
	
	import events.NavigationEvent;
	
	import sound.Sounds;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	import ui.SoundButton;
	
	import view.GameView;
	import view.WelcomeView;
	
	public class Main extends Sprite
	{
		private var gameView		:GameView;
		private var welcomeView		:WelcomeView;
		
		/** Sound / Mute button. */
		private var soundButton:SoundButton;
		
		public function Main()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Initialize screens.
			init();
		}
		
		private function init():void
		{
			this.addEventListener(NavigationEvent.CHANGE_SCREEN, onChangeScreen);
			
			// InGame screen.
			gameView = new GameView();
			gameView.addEventListener(NavigationEvent.CHANGE_SCREEN, onInGameNavigation);
			this.addChild(gameView);
			
			// Welcome screen.
			welcomeView = new WelcomeView();
			addChild(welcomeView);
			
			// Create and add Sound/Mute button.
			soundButton = new SoundButton();
			soundButton.x = int(soundButton.width * 0.5);
			soundButton.y = int(soundButton.height * 0.5);
			soundButton.addEventListener(Event.TRIGGERED, onSoundButtonClick);
			this.addChild(soundButton)
			
			// Initialize the Welcome screen by default. 
			welcomeView.initialize();
		}
		
		/**
		 * On navigation from different screens. 
		 * @param event
		 * 
		 */
		private function onInGameNavigation(event:NavigationEvent):void	
		{
			switch (event.params.id)
			{
				case "mainMenu":
					welcomeView.initialize();
					break;
				case "about":
					welcomeView.initialize();
					welcomeView.showAbout();
					break;
			}
		}
		
		/**
		 * On click of the sound/mute button. 
		 * @param event
		 * 
		 */
		private function onSoundButtonClick(event:Event = null):void
		{
			if (Sounds.muted) {
				Sounds.muted = false;
				
				if (welcomeView.visible) Sounds.sndBgMain.play(0, 999);
			//	else if (screenInGame.visible) Sounds.sndBgGame.play(0, 999);
				// If in game, communicate with Cadet scene.
				
				
				soundButton.showUnmuteState();
			} else {
				Sounds.muted = true;
				SoundMixer.stopAll();
				
				soundButton.showMuteState();
			}
		}
		
		/**
		 * On change of screen. 
		 * @param event
		 * 
		 */	
		private function onChangeScreen(event:NavigationEvent):void	
		{
			switch (event.params.id)
			{
				case "play":
					welcomeView.disposeTemporarily();
					gameView.initialize();
					break;
			}
		}
	}
}











