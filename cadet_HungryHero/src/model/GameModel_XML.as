package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import cadet.components.processes.SoundProcess;
	import cadet.core.CadetScene;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.operations.Cadet2DStartUpOperation;
	
	import hungryHero.components.behaviours.HeroBehaviour;
	import hungryHero.components.behaviours.ShakeBehaviour;
	import hungryHero.components.processes.GlobalsProcess;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	public class GameModel_XML extends EventDispatcher implements IGameModel
	{
		private const LOADED			:String = "loaded";
		
		private var _parent				:DisplayObjectContainer;
		private var _cadetScene			:CadetScene;		
		private var _cadetFileURL		:String = "/HungryHero.cdt";
		
		private var _heroBehaviour		:HeroBehaviour;
		
		private var _heroStartX			:Number;
		private var _heroStartY			:Number;
		
		private var _globals			:GlobalsProcess;
		private var _soundProcess		:SoundProcess;
		
		private var _shakeBehaviour		:ShakeBehaviour;
		
		private var _initialised		:Boolean;
		private var _muted				:Boolean;
		
		public function GameModel_XML()
		{
			// Required when loading data and assets.
			var startUpOperation:Cadet2DStartUpOperation = new Cadet2DStartUpOperation(_cadetFileURL);
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
			_parent = parent;
			
			var renderer:Renderer2D = ComponentUtil.getChildOfType(_cadetScene, Renderer2D);
			renderer.enableToExisting(parent);
			
			_globals = ComponentUtil.getChildOfType( _cadetScene, GlobalsProcess, true );
			_globals.paused = true;
			
			_soundProcess = ComponentUtil.getChildOfType( _cadetScene, SoundProcess, true );
			
			_shakeBehaviour = ComponentUtil.getChildOfType( _cadetScene, ShakeBehaviour, true );
			_heroBehaviour = ComponentUtil.getChildOfType( _cadetScene, HeroBehaviour, true );
			
			if (!_initialised) {
				_heroStartX = _heroBehaviour.transform.x;
				_heroStartY = _heroBehaviour.transform.y;
			}
			
			_cadetScene.validateNow();
			
			reset();
			
			parent.addEventListener( starling.events.Event.ENTER_FRAME, enterFrameHandler );
			
			_initialised = true;
		}
		
		public function reset():void
		{
			_globals.reset();
			_globals.paused = true;
			
			_heroBehaviour.transform.x = _heroStartX;
			_heroBehaviour.transform.y = _heroStartY;
			
			if ( _shakeBehaviour ) {
				_shakeBehaviour.shake = 0;
			}
		}
		
		public function get muted():Boolean
		{
			return _muted;
		}
		public function set muted( value:Boolean ):void
		{
			_muted = value;
			if ( _soundProcess ) {
				_soundProcess.muted = _muted;
			}
		}
		
		public function dispose():void
		{
			//_cadetScene.dispose();
			_parent.removeEventListener( starling.events.Event.ENTER_FRAME, enterFrameHandler );		
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