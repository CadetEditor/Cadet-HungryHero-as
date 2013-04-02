package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import cadet.core.CadetScene;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.operations.Cadet2DStartUpOperation;
	
	import hungryHero.components.behaviours.ShakeBehaviour;
	import hungryHero.components.processes.GlobalsProcess;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	public class GameModel_XML extends EventDispatcher implements IGameModel
	{
		private const LOADED			:String = "loaded";
		
		private var parent				:DisplayObjectContainer;
		private var _cadetScene			:CadetScene;		
		private var cadetFileURL		:String = "/HungryHero.cdt";
		
		private var heroTransform2D		:Transform2D;
		
		private var heroStartX			:Number;
		private var heroStartY			:Number;
		
		private var globals				:GlobalsProcess;
		
		private var shakeBehaviour		:ShakeBehaviour;
		
		public function GameModel_XML()
		{
			// Required when loading data and assets.
			var startUpOperation:Cadet2DStartUpOperation = new Cadet2DStartUpOperation(cadetFileURL);
			//startUpOperation.addManifest( startUpOperation.baseManifestURL + "Cadet2DBox2D.xml");
			startUpOperation.addEventListener(flash.events.Event.COMPLETE, startUpCompleteHandler);
			startUpOperation.execute();
		}
		
		private function startUpCompleteHandler( event:flash.events.Event ):void
		{
			var operation:Cadet2DStartUpOperation = Cadet2DStartUpOperation( event.target );

			_cadetScene = CadetScene(operation.getResult());
				
			dispatchEvent( new flash.events.Event(LOADED) );
		}
		
		public function init(parent:starling.display.DisplayObjectContainer):void
		{
			this.parent = parent;
			
			var renderer:Renderer2D = ComponentUtil.getChildOfType(_cadetScene, Renderer2D);
			renderer.enableToExisting(parent);
			
			globals = ComponentUtil.getChildOfType( _cadetScene, GlobalsProcess, true );
			shakeBehaviour = ComponentUtil.getChildOfType( _cadetScene, ShakeBehaviour, true );
			
			_cadetScene.validateNow();
			
			parent.addEventListener( starling.events.Event.ENTER_FRAME, enterFrameHandler );
		}
		
		public function reset():void
		{
			globals.reset();
			globals.paused = true;
			
//			heroTransform2D.x = heroStartX;
//			heroTransform2D.y = heroStartY;
			
			shakeBehaviour.shake = 0;
		}
		
		public function dispose():void
		{
			_cadetScene.dispose();
			parent.removeEventListener( starling.events.Event.ENTER_FRAME, enterFrameHandler );		
		}
	
		private function enterFrameHandler( event:starling.events.Event ):void
		{
			_cadetScene.step();
		}
		
		public function get cadetScene():CadetScene
		{
			return _cadetScene;
		}
	}
}