package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import hungryHero.Main;
	
	import starling.core.Starling;
	
	[SWF( width="1024", height="768", backgroundColor="0x389cd1", frameRate="60" )]
	public class C2D_HungryHero_Web extends Sprite
	{
		// Starling object.
		private var myStarling:Starling;
		
		public static var instance:Sprite;
		
		public function C2D_HungryHero_Web()
		{
			super();
			
			Main.originalStageWidth = stage.stageWidth;
			Main.originalStageHeight = stage.stageHeight;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Comment out cadetFileURL to switch IGameModels. URL = GameModel_XML, null = GameModel_Code
			//Main.cadetFileURL = "/HungryHero.cdt2d";
			
			instance = this;
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