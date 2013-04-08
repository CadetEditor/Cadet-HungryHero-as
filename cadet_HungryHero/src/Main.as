package
{
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	
	import cadet2D.operations.Cadet2DStartUpOperation;
	
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
		
		private var _cadetFileURL		:String = "/HungryHero2.cdt";
		
		public function Main()
		{
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:starling.events.Event):void
		{
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Required when loading data and assets.
			var startUpOperation:Cadet2DStartUpOperation = new Cadet2DStartUpOperation();//_cadetFileURL);
			startUpOperation.addEventListener(flash.events.Event.COMPLETE, startUpCompleteHandler);
			startUpOperation.execute();
		}
		
		private function startUpCompleteHandler( event:flash.events.Event ):void
		{
			var operation:Cadet2DStartUpOperation = Cadet2DStartUpOperation( event.target );
			
			//_cadetScene = CadetScene(operation.getResult());
			
			//dispatchEvent( new flash.events.Event(LOADED) );
			
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
			soundButton.addEventListener(starling.events.Event.TRIGGERED, onSoundButtonClick);
			this.addChild(soundButton);
		}
		
		// On click of the sound/mute button. 
		// @param event
		private function onSoundButtonClick(event:starling.events.Event = null):void
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











