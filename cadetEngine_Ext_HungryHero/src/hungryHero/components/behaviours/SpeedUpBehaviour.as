package hungryHero.components.behaviours
{
	import flash.events.Event;
	
	import cadet.components.processes.SoundProcess;
	import cadet.components.sounds.ISound;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.particles.PDParticleSystemComponent;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.transforms.ITransform2D;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	public class SpeedUpBehaviour extends Component implements IPowerupBehaviour, ISteppableComponent
	{
		public var globals					:GlobalsProcess;
		public var renderer					:Renderer2D;
		
		private var _targetTransform		:ITransform2D;
		
		public var _effectLength			:Number = 5; // How long does coffee power last? (in seconds)
		
		private var power					:Number;
		
		private var notifyComplete			:Boolean;
		
		// SOUNDS
		public var soundProcess				:SoundProcess;
		private var _collectSound			:ISound;
		// PARTICLES
		private var _particleEffect			:PDParticleSystemComponent;
		
		public function SpeedUpBehaviour( name:String = "SpeedUpBehaviour" )
		{
			super( name );
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
			addSceneReference(Renderer2D, "renderer");
			addSceneReference(SoundProcess, "soundProcess");
			addSiblingReference(ISound, "collectSound");
		}
		
		public function step( dt:Number ):void
		{
			if (!globals) return;
			
			// If drank coffee, fly faster for a while.
			if (power > 0)
			{				
				// If we have a coffee, reduce the value of the power.
				power -= globals.elapsed;
			//	trace("COFFEE power "+power+" elapsed "+globals.elapsed);
			} else if (!notifyComplete) {
				notifyComplete = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------

		[Serializable][Inspectable( priority="50" )]
		public function set effectLength( value:Number ):void
		{
			_effectLength = value;
		}
		public function get effectLength():Number { return _effectLength; }
	
		[Serializable][Inspectable( priority="51", editor="ComponentList", scope="scene"  )]
		public function set targetTransform( value:ITransform2D ):void
		{
			_targetTransform = value;
		}
		public function get targetTransform():ITransform2D { return _targetTransform; }
		
		// SOUNDS
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="55" )]
		public function set collectSound( value:ISound ):void
		{
			_collectSound = value;
		}
		public function get collectSound():ISound { return _collectSound; }
		
		// PARTICLES
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="56" )]
		public function set particleEffect( value:PDParticleSystemComponent ):void
		{
			_particleEffect = value;
		}
		public function get particleEffect():PDParticleSystemComponent
		{
			return _particleEffect;
		}
		
		// -------------------------------------------------------------------------------------
		
		public function init():void
		{
			power = effectLength;
			notifyComplete = false;
			
			if ( soundProcess && _collectSound ) {
				soundProcess.playSound(_collectSound);
			}
			
			if ( _particleEffect ) {
				_particleEffect.start(_effectLength);
			}
		}
		
		public function execute():void
		{
			if (!globals) return;
			
			if ( _particleEffect && _targetTransform ) {//&& renderer && renderer.viewport ) {
//				var point:Point = new Point(_targetTransform.x, _targetTransform.y);
//				//point = renderer.viewport.localToGlobal(point);
//				point.x -= renderer.viewportX;
//				point.y -= renderer.viewportY;
				_particleEffect.emitterX = _targetTransform.x;
				_particleEffect.emitterY = _targetTransform.y;
			}
			
			globals.playerSpeed += (globals.playerMaxSpeed - globals.playerSpeed) * 0.2;
		}		
	}
}