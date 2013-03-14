package hungryHero.components.processes
{
	import flash.utils.Dictionary;
	
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.core.IInitOnRunComponent;
	import cadet.core.ISteppableComponent;
	import cadet.util.deg2rad;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.transforms.ITransform2D;
	
	import hungryHero.components.behaviours.ParticleBehaviour;
	import hungryHero.pools.Pool;
	
	public class EatParticlesProcess extends Component implements ISteppableComponent, IInitOnRunComponent
	{
		public var globals						:GlobalsProcess;
		public var renderer						:Renderer2D;
		
		private var _particlesToAnimate			:Vector.<AbstractSkin2D>//Particle>;
		private var _particlesToAnimateLength	:uint;
		
		private var _particlesPool				:Pool;
		
		private var _particles					:Vector.<AbstractSkin2D>;
		private var _particlesContainer			:IComponentContainer;
		private var _behaviours					:Dictionary;
		
		public function EatParticlesProcess()
		{
			// Initialize particles-to-animate vectors.
			_particlesToAnimate = new Vector.<AbstractSkin2D>()//Particle>();
			_particlesToAnimateLength = 0;
			
			_behaviours = new Dictionary();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
			addSceneReference(GlobalsProcess, "globals");
		}

		// IInitOnRunComponent
		public function init():void
		{
			// Create Eat Particle pool and place it outside the stage area.
			createParticlePool();
		}
		
		// ISteppableComponent
		public function step(dt:Number):void
		{
			if (!renderer || !globals) return;
			
			if ( globals.gameState == GlobalsProcess.GAME_STATE_FLYING )
			{
				// Animate elements.
				animateParticles();
				
//				if ( collectedAnything ) {
//					createParticle(itemToTrack);
//				}
			}
			else if ( globals.gameState == GlobalsProcess.GAME_STATE_OVER )
			{
				for(var m:uint = 0; m < _particlesToAnimateLength; m++)
				{
					if (_particlesToAnimate[m] != null)
					{
						// Dispose the eat particle temporarily.
						disposeParticleTemporarily(m, _particlesToAnimate[m]);
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="51" )]
		public function set particlesContainer( value:IComponentContainer ):void
		{
			_particlesContainer = value;
		}
		public function get particlesContainer():IComponentContainer { return _particlesContainer; }	
		
		// -------------------------------------------------------------------------------------
		
		/**
		 * Create Eat Particle Pool. 
		 * 
		 */
		private function createParticlePool():void
		{
			_particles = new Vector.<AbstractSkin2D>();
			
			if (!_particlesContainer) {
				_particlesContainer = parentComponent;
			}
			
			// Add Skins from itemsContainer to items list
			for ( var i:uint = 0; i < _particlesContainer.children.length; i ++ ) 
			{
				var child:Component = _particlesContainer.children[i];
				if ( child is AbstractSkin2D ) {	
					_particles.push( child );
				}
			}
			
			// Remove Skins from scene
			for ( i = 0; i < _particles.length; i ++ ) {
				child = _particles[i];
				child.parentComponent.children.removeItem(child);
			}
			
			_particlesPool = new Pool(particleCreate, particleClean, 20, 30);
		}
		
		/**
		 * Create eat particle objects and add to display list.
		 * Also called from the Pool class while creating minimum number of objects & run-time objects < maximum number.
		 * @return Eat particle that was created.
		 * 
		 */
		private function particleCreate():AbstractSkin2D//Particle
		{
			var newSkin:MovieClipSkin = new MovieClipSkin();
			_particlesContainer.children.addItem(newSkin);
			
			newSkin.x = renderer.viewport.stage.stageWidth + newSkin.width * 2;
			newSkin.validateNow();
			
			var behaviour:ParticleBehaviour = new ParticleBehaviour();
			_behaviours[newSkin] = behaviour;
			
			
			return newSkin;
			
//			var particle:Particle = new Particle(GameConstants.PARTICLE_TYPE_1);
//			particle.x = stage.stageWidth + particle.width * 2;
//			this.addChild(particle);
//			
//			return particle;
		}
		
		/**
		 * Clean the eat particles before reusing from the pool. Called from the pool. 
		 * @param particle
		 * 
		 */
		private function particleClean(particle:AbstractSkin2D):void//Particle):void
		{
			particle.x = renderer.viewport.stage.stageWidth + particle.width * 2;
		}
		
		/**
		 * Dispose the eat particle temporarily. Check-in into pool (will get cleaned) and reduce the vector length by 1. 
		 * @param animateId
		 * @param particle
		 * 
		 */
		private function disposeParticleTemporarily(animateId:uint, particle:AbstractSkin2D):void//Particle):void
		{
			_particlesToAnimate.splice(animateId, 1);
			_particlesToAnimateLength--;
			_particlesPool.checkIn(particle);
		}
		
		/**
		 * Create an eat particle when an item is collected. 
		 * @param itemToTrack
		 * @param count
		 * 
		 */
		public function createParticle(itemToTrack:ITransform2D, count:int = 2):void
		{
			var particleToTrack:MovieClipSkin;//Particle;
			
			var randItem:AbstractSkin2D = _particles[Math.round(Math.random() * (_particles.length-1))];
			var randImgSkin:ImageSkin = ImageSkin(randItem);
			
			while (count > 0)
			{
				count--;
				
				// Create eat particle object.
				particleToTrack = MovieClipSkin(_particlesPool.checkOut());
				var behaviour:ParticleBehaviour = _behaviours[particleToTrack];
				
				if (particleToTrack)
				{
					particleToTrack.texture = randImgSkin.texture;
					particleToTrack.textureAtlas = randImgSkin.textureAtlas;
					particleToTrack.texturesPrefix = randImgSkin.texturesPrefix;
					
					// Set the position of the particle object with a random offset.
					particleToTrack.x = itemToTrack.x + Math.random() * 40 - 20;
					particleToTrack.y = itemToTrack.y - Math.random() * 40;
					
					// Set the speed of a particle object. 
					behaviour.speedY = Math.random() * 10 - 5;
					behaviour.speedX = Math.random() * 2 + 1;
					
					// Set the spinning speed of the particle object.
					behaviour.spin = Math.random() * 20 - 5;
					
					// Set the scale of the eat particle.
					particleToTrack.scaleX = particleToTrack.scaleY = Math.random() * 0.3 + 0.3;
					
					// Animate the eat particle.
					_particlesToAnimate[_particlesToAnimateLength++] = particleToTrack;
				}
			}
		}
		
		/**
		 * Animate the eat particles that are marked animatable. 
		 * 
		 */
		private function animateParticles():void
		{
			var particleToTrack:AbstractSkin2D;//Particle;
			
			for(var i:uint = 0;i < _particlesToAnimateLength;i++)
			{
				particleToTrack = _particlesToAnimate[i];
				var behaviour:ParticleBehaviour = _behaviours[particleToTrack];
				
				if (particleToTrack)
				{
					particleToTrack.scaleX -= 0.03;
					
					// Make the eat particle get smaller.
					particleToTrack.scaleY = particleToTrack.scaleX;
					// Move it horizontally based on speedX.
					particleToTrack.y -= behaviour.speedY; 
					// Reduce the horizontal speed.
					behaviour.speedY -= behaviour.speedY * 0.2;
					// Move it vertically based on speedY.
					particleToTrack.x += behaviour.speedX;
					// Reduce the vertical speed.
					behaviour.speedX--; 
					
					// Rotate the eat particle based on spin.
					particleToTrack.rotation += deg2rad(behaviour.spin); 
					// Increase the spinning speed.
					behaviour.spin *= 1.1; 
					
					// If the eat particle is small enough, remove it.
					if (particleToTrack.scaleY <= 0.02)
					{
						disposeParticleTemporarily(i, particleToTrack);
					}
				}
			}
		}			
	}
}










