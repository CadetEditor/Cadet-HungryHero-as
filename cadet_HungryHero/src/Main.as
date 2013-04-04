package
{
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
		public static var viewManager		:ViewManager;
		
		private var viewContainer:Sprite;		 	// All views are added in here.
		private var soundButton:SoundButton;		// Sound / Mute button.
		
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
			viewContainer = new Sprite();
			this.addChild( viewContainer );
			
			viewManager	= new ViewManager( viewContainer );
			
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
		
		// On click of the sound/mute button. 
		// @param event
		private function onSoundButtonClick(event:Event = null):void
		{
			if (Sounds.muted) {
				Sounds.muted = false;
				soundButton.showUnmuteState();
			} else {
				Sounds.muted = true;;
				soundButton.showMuteState();
			}
		}
		
		// On change of screen. 
		//  @param event
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











