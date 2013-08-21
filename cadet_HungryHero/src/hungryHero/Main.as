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
		
		public static var gameWindow		:Sprite;	
		
		public function Main()
		{
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:starling.events.Event):void
		{
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			/* 	Starling stage scaling:
			*	If star.stage.stageWidth & star.stage.stageHeight are equal to
			*	star.viewPort.width & star.viewPort.height, the stage content is not scaled.
			*	Else, stage is scaled, e.g.
			*
			*	originalStageWidth = 1024
			*	originalStageHeight = 768
			*	stageWidth (onAdded - Nexus 10) = 2560
			*	stageHeight (onAdded - Nexus 10) = 1454
			*	xScalar = 0.4
			*	yScalar = 0.52
			*	minScalar = xScalar
			*	stageWidth (final) = 1024		
			*	stageHeight (final)  = 581.6
			*	
			*	(Larger numbers = scaled down more)
			*/
			
			var star:Starling = Starling.current;
			var xScalar:Number = originalStageWidth / star.stage.stageWidth;
			var yScalar:Number = originalStageHeight / star.stage.stageHeight;
			var scalar:Number = Math.min(xScalar, yScalar);
			trace("Original sW "+originalStageWidth+" sH "+originalStageHeight);
			trace("Current sW "+star.stage.stageWidth+" sH "+star.stage.stageHeight);
			trace("xScalar "+xScalar+" yScalar "+yScalar);
			
			star.stage.stageWidth *= scalar;
			star.stage.stageHeight *= scalar;
			
			trace("Final sW "+star.stage.stageWidth+" sH "+star.stage.stageHeight);
			
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
			
			gameWindow	= new Sprite();
			viewContainer.addChild(gameWindow);
			
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
			
			gameModel.init(gameWindow);
			gameModel.enable();
			
			gameModel.globalsProcess.paused = true;
			gameModel.soundProcess.muted = true;
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











