package
{	
	import flash.media.SoundMixer;
	
	import controller.GameViewController;
	import controller.WelcomeViewController;
	
	import events.NavigationEvent;
	
	import managers.ViewManager;
	
	import sound.Sounds;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	import ui.SoundButton;
	
	import view.GameView;
	import view.WelcomeView;

	public class Main extends Sprite
	{
//		private var gameView		:GameView;
//		private var welcomeView		:WelcomeView;
		
		private var viewManager		:ViewManager;
		
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
			viewManager				= new ViewManager( this );
			
			viewManager.registerView( GameView, GameViewController );
			viewManager.registerView( WelcomeView, WelcomeViewController );
			
			viewManager.changeView( WelcomeView );
			
			this.addEventListener(NavigationEvent.CHANGE_SCREEN, onChangeScreen);
			
			// Create and add Sound/Mute button.
			soundButton = new SoundButton();
			soundButton.x = int(soundButton.width * 0.5);
			soundButton.y = int(soundButton.height * 0.5);
			soundButton.addEventListener(Event.TRIGGERED, onSoundButtonClick);
			this.addChild(soundButton);
		}
		
		/**
		 * On navigation from different screens. 
		 * @param event
		 * 
		 */
		private function onInGameNavigation(event:NavigationEvent):void	
		{
/*			switch (event.params.id)
			{
				case "mainMenu":
					welcomeView.initialize();
					break;
				case "about":
					welcomeView.initialize();
					welcomeView.showAbout();
					break;
			}*/
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
				
				if (viewManager.currentView is WelcomeView ) {
					Sounds.sndBgMain.play(0, 999);
				}
			//	if (welcomeView.visible) Sounds.sndBgMain.play(0, 999);
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
					viewManager.changeView( GameView );
					break;
			}
		}
	}
}











