package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import core.app.util.FileSystemTypes;
	
	import hungryHero.Main;
	
	import starling.core.Starling;
	
	[SWF( width="1024", height="768", backgroundColor="0x389cd1", frameRate="60" )]
	public class C2D_HungryHero_AIR extends Sprite
	{
		private var myStarling:Starling;
		
		public static var instance:Sprite;
		
		public function C2D_HungryHero_AIR()
		{
			super();
			
			Main.originalStageWidth = stage.stageWidth;
			Main.originalStageHeight = stage.stageHeight;
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Comment out cadetFileURL to switch IGameModels. URL = GameModel_XML, null = GameModel_Code
			//Main.cadetFileURL = "/HungryHero.cdt2d";
			Main.cadetFileURL = "/SpaceshipGame.cdt2d";
			Main.fileSystemType = FileSystemTypes.LOCAL;
			
			instance = this;
			
			Starling.handleLostContext = true;
			
		//	trace("app dir "+File.applicationDirectory.nativePath+" storageDir "+File.applicationStorageDirectory.nativePath+" cacheDir "+File.cacheDirectory.nativePath+" desktopDir "+File.desktopDirectory.nativePath+" docs "+File.documentsDirectory.nativePath); 
		}
		
		// On added to stage. 
		// @param event
		protected function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Initialize Starling object.
			myStarling = new Starling(Main, stage);
			
			// Define basic anti aliasing.
			myStarling.antiAliasing = 1;
			
			// Show statistics for memory usage and fps.
			myStarling.showStats = true;
			
			// Position stats.
			myStarling.showStatsAt("left", "bottom");
			
			// Start Starling Framework.
			myStarling.start();
		}
	}
}