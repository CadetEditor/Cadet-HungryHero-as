package hungryHero.components.behaviours
{
	import flash.events.Event;
	
	import cadet.components.sounds.ISound;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.particles.PDParticleSystemComponent;
	import cadet2D.components.transforms.ITransform2D;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	public class MagnetBehaviour extends Component implements IMoveBehaviour, ISteppableComponent
	{
		public var globals					:GlobalsProcess;
		
		private var _transform				:ITransform2D;
		private var _targetTransform		:ITransform2D;
		
		private var _pcDistance				:Number = 0.2;
		private var _effectLength			:Number = 4; // How long does mushroom power last? (in seconds)
		
		private var power					:Number;
		
		private var notifyComplete			:Boolean;
		
		// SOUNDS
		private var _collectSound			:ISound;
		// PARTICLES
		private var _particleEffect			:PDParticleSystemComponent;
		
		public function MagnetBehaviour()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
			addSiblingReference(ISound, "collectSound");
		}
		
		public function step( dt:Number ):void
		{
			if (!globals) return;
			
			if (power > 0)
			{
				// If we have a mushroom, reduce the value of the power.
				power -= globals.elapsed;
				
				//trace("MAGNET power "+power+" elapsed "+globals.elapsed);
			} else if (!notifyComplete) {
				notifyComplete = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}	
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		//[Serializable][Inspectable( priority="50", editor="ComponentList", scope="scene" )]
		public function set transform( value:ITransform2D ):void
		{
			_transform = value;
		}
		public function get transform():ITransform2D
		{
			return _transform;
		}
		
		[Serializable][Inspectable( priority="51", editor="ComponentList", scope="scene"  )]
		public function set targetTransform( value:ITransform2D ):void
		{
			_targetTransform = value;
		}
		public function get targetTransform():ITransform2D { return _targetTransform; }
		
		[Serializable][Inspectable(priority="52", editor="Slider", min="0", max="1", snapInterval="0.02") ]
		public function set pcDistance( value:Number ):void
		{
			_pcDistance = value;
		}
		public function get pcDistance():Number { return _pcDistance; }
		
		// How long does mushroom power last? (in seconds)
		[Serializable][Inspectable( priority="53" )]
		public function set effectLength( value:Number ):void
		{
			_effectLength = value;
		}
		public function get effectLength():Number { return _effectLength; }
		
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
			
			if ( _collectSound ) {
				_collectSound.play();
			}
			
			if ( _particleEffect ) {
				_particleEffect.start(_effectLength);
			}
		}
		
		public function execute():void
		{
			if ( _particleEffect && _targetTransform ) {
				_particleEffect.emitterX = _targetTransform.x;
				_particleEffect.emitterY = _targetTransform.y;
			}
			
			movePercentageDistanceToTarget(_transform, _pcDistance);
		}
		
		private function movePercentageDistanceToTarget(transform:ITransform2D, percentage:Number):void
		{
			if (!targetTransform) return;
			
			var a:Number = targetTransform.x - transform.x; 
			var b:Number = targetTransform.y - transform.y;
			//var h:Number = Math.sqrt(a*a+b*b);
			
			/*var angleRadians:Number = Math.atan2(a, b); 
			angle = angleRadians * 180/Math.PI;
			
			var distance:Number = h * percentage;
			
			return moveFixedDistanceAtAngle(point, angleRadians, distance);*/
			
			var xStep:Number = a * percentage;
			var yStep:Number = b * percentage;
			
			transform.x += xStep;
			transform.y += yStep;
		}
	}
}