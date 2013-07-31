package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import cadet.util.deg2rad;
	import cadet.util.rad2deg;
	
	import core.app.util.FileSystemTypes;
	
	import hungryHero.Main;
	
	import starling.core.Starling;
	import starling.events.ResizeEvent;
	
	[SWF( width="1024", height="768", backgroundColor="0x389cd1", frameRate="60" )]
	public class C2D_HungryHero_Mobile extends Sprite
	{
		private var myStarling:Starling;
		
		public static var instance:Sprite;
		
		public function C2D_HungryHero_Mobile()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Comment out cadetFileURL to switch IGameModels.
			// URL = GameModel_XML, null = GameModel_Code
			Main.cadetFileURL = "/HungryHero.cdt2d";
			//Main.fileSystemType = FileSystemTypes.LOCAL;
			
			instance = this;
			
			Starling.handleLostContext = true;
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
			
			myStarling.stage.addEventListener(ResizeEvent.RESIZE, onResize);
		}
	
		private function onResize(e:ResizeEvent):void
		{
			// set rectangle dimensions for viewPort:
			var viewPortRectangle:Rectangle = new Rectangle();
			viewPortRectangle.width = e.width; 
			viewPortRectangle.height = e.height;
			
			// resize the viewport:
			myStarling.viewPort = viewPortRectangle;
			
			// no scale
//			myStarling.stage.stageWidth = e.width;
//			myStarling.stage.stageHeight = e.height;
			
			if ( myStarling.root ) {
				if ( e.height > e.width ) {
					// sideways
					myStarling.root.rotation = deg2rad(90);
					myStarling.root.x = e.width;
				} else {
					// normal
					myStarling.root.rotation = deg2rad(0);
					myStarling.root.x = 0;
				}
				
				trace("root x "+myStarling.root.x+" y "+myStarling.root.y+" r "+rad2deg(myStarling.root.rotation));
			}
			
			trace("Resize w "+e.width+" h "+e.height+" vP.w "+Starling.current.viewPort.width+" vP.h "+Starling.current.viewPort.height);//+" renderer "+renderer);
			
		}
	}
}