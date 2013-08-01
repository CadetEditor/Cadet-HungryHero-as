package hungryHero 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import cadet.core.CadetScene;
	
	import cadet2D.operations.Cadet2DStartUpOperation;
	import cadet2D.resources.ExternalXMLResourceParser;
	
	import core.app.CoreApp;
	import core.app.resources.ExternalResourceParserFactory;
	import core.app.util.SerializationUtil;
	
	import hungryHero.controller.GameViewController;
	import hungryHero.controller.WelcomeViewController;
	import hungryHero.events.NavigationEvent;
	import hungryHero.managers.ViewManager;
	import hungryHero.model.GameModel_Code;
	import hungryHero.model.GameModel_XML;
	import hungryHero.model.IGameModel;
	import hungryHero.sound.Sounds;
	import hungryHero.ui.SoundButton;
	import hungryHero.view.GameView;
	import hungryHero.view.WelcomeView;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;

	public class Main extends Sprite
	{
		public static var viewManager		:ViewManager;
		public static var gameModel			:IGameModel;
		
		private var viewContainer:Sprite;		 	// All views are added in here.
		private var soundButton:SoundButton;		// Sound / Mute button.

		public static var cadetFileURL		:String = null;
		public static var fileSystemType	:String = "url";
		
		public static var originalStageWidth:Number;
		public static var originalStageHeight:Number;
		
		public function Main()
		{
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:starling.events.Event):void
		{
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			var star:Starling = Starling.current;
			var xScalar:Number = star.stage.stageWidth / originalStageWidth;
			var yScalar:Number = star.stage.stageHeight / originalStageHeight;
			
			star.stage.stageWidth /= xScalar;
			star.stage.stageHeight /= yScalar;
			
			// Required when loading data and assets.
			var startUpOperation:Cadet2DStartUpOperation = new Cadet2DStartUpOperation(cadetFileURL, fileSystemType);
			startUpOperation.addResource( new ExternalResourceParserFactory( ExternalXMLResourceParser, "External XML Resource Parser", ["pex"] ) );
			startUpOperation.addEventListener(flash.events.Event.COMPLETE, startUpCompleteHandler);
			startUpOperation.execute();
		}
		
		private function startUpCompleteHandler( event:flash.events.Event ):void
		{
			var operation:Cadet2DStartUpOperation = Cadet2DStartUpOperation( event.target );
			
			// If a _cadetFileURL is specified, load the external CadetScene from XML
			// Otherwise, revert to the coded version of the CadetScene.
			if ( cadetFileURL ) {
				gameModel = new GameModel_XML();
				gameModel.cadetScene = CadetScene(operation.getResult());
			} else {
				gameModel = new GameModel_Code( CoreApp.resourceManager );
				
				// Need to wait for the next frame to serialize, otherwise the manifests aren't ready
				//AsynchronousUtil.callLater(serialize);
			}

			// Initialize screens.
			init();
		}
		
		private function serialize():void
		{
			var eventDispatcher:EventDispatcher = SerializationUtil.serialize(gameModel.cadetScene);
			eventDispatcher.addEventListener(flash.events.Event.COMPLETE, serializationCompleteHandler);
		}
		
		private function serializationCompleteHandler( event:flash.events.Event ):void
		{
			trace(SerializationUtil.getResult().toXMLString());
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











