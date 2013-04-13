package model
{
	import cadet.components.processes.SoundProcess;
	import cadet.core.CadetScene;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	
	import hungryHero.components.behaviours.HeroBehaviour;
	import hungryHero.components.behaviours.ShakeBehaviour;
	import hungryHero.components.processes.GlobalsProcess;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	public class GameModel_XML implements IGameModel
	{
		private var _parent				:DisplayObjectContainer;
		private var _cadetScene			:CadetScene;
		
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

		}
		
		public function init(parent:starling.display.DisplayObjectContainer):void
		{
			_parent = parent;
			
			// Grab a reference to the Renderer2D and enable it on the existing Starling display list
			var renderer:Renderer2D = ComponentUtil.getChildOfType(_cadetScene, Renderer2D);
			renderer.enableToExisting(parent);
			
			// Grab a reference to the GlobalsProcess and pause the game on first showing
			_globals = ComponentUtil.getChildOfType( _cadetScene, GlobalsProcess, true );
			_globals.paused = true;
			
			// Grab a reference to the SoundProcess so we can toggle "muted" via our custom game UI
			_soundProcess = ComponentUtil.getChildOfType( _cadetScene, SoundProcess, true );
			
			// Grab a reference to Components which need to be rest on subsequent turns
			_shakeBehaviour = ComponentUtil.getChildOfType( _cadetScene, ShakeBehaviour, true );
			_heroBehaviour = ComponentUtil.getChildOfType( _cadetScene, HeroBehaviour, true );
			
			// Store the initial position of the hero so we can reset to it on subsequent turns
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
		public function set cadetScene( value:CadetScene ):void
		{
			_cadetScene = value;
		}
	}
}





