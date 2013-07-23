package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.events.ResizeEvent;
	import hungryHero.Main;
	
	[SWF( width="1024", height="768", backgroundColor="0x389cd1", frameRate="60" )]
	public class CadetHungryHero extends Sprite
	{
		// Starling object.
		private var myStarling:Starling;
		
		public static var instance:Sprite;
		
		public function CadetHungryHero()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
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
			
			// assign the new stage width and height:
			//myStarling.stage.stageWidth = viewPortRectangle.width;
			//myStarling.stage.stageHeight = viewPortRectangle.height;
			
			//Starling.current.viewPort.width = e.width;
			//Starling.current.viewPort.height = e.height;
						
			trace("Resize w "+e.width+" h "+e.height+" vP.w "+Starling.current.viewPort.width+" vP.h "+Starling.current.viewPort.height);//+" renderer "+renderer);

		}
	}
}