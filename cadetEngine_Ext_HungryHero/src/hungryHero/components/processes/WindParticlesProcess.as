package hungryHero.components.processes
{
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.core.IInitialisableComponent;
	import cadet.core.ISteppableComponent;
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	
	import hungryHero.pools.Pool;
	
	public class WindParticlesProcess extends Component implements ISteppableComponent, IInitialisableComponent
	{
		public var globals						:GlobalsProcess;
		public var renderer						:Renderer2D;

		private var _worldBounds				:WorldBounds2D;
		public var worldBoundsRect				:Rectangle = new Rectangle(0, 0, 800, 600);
		
		private var _particles					:Vector.<AbstractSkin2D>;
		private var _particlesContainer			:IComponentContainer;
		
		// ------------------------------------------------------------------------------------------------------------
		// PARTICLES
		// ------------------------------------------------------------------------------------------------------------
		
		private var _particlesPool:Pool;
		
		private var _particlesToAnimate:Vector.<AbstractSkin2D>;//Particle>;
		private var _particlesToAnimateLength:uint;
		
///		private var _isHardwareRendering:Boolean = true;
		
		public function WindParticlesProcess( name:String = "WindParticlesProcess" )
		{
			super( name );
			_particlesToAnimate = new Vector.<AbstractSkin2D>();
			_particlesToAnimateLength = 0;
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
			addSceneReference(GlobalsProcess, "globals");
		}
		
		// IInitialisableComponent
		public function init():void
		{
			// Create Wind Particle pool and place it outside the stage area.
			createParticlePool();
		}
		
		// ISteppableComponent
		public function step(dt:Number):void
		{
			if ( globals.gameState == GlobalsProcess.GAME_STATE_FLYING )
			{
				// If not hit by obstacle, fly normally.
				if (globals.hitObstacle <= 0)
				{
					// If hero is flying extremely fast, create a wind effect and show force field around hero.
					if (globals.playerSpeed > globals.playerMinSpeed + 100)
					{
						createParticle();
						// Animate hero faster.
					}
				}
				
				// Animate elements.
				animateParticles();
			}
			else if ( globals.gameState == GlobalsProcess.GAME_STATE_OVER )
			{
				for(var n:uint = 0; n < _particlesToAnimateLength; n++)
				{
					if (_particlesToAnimate[n] != null)
					{
						// Dispose the wind particle temporarily.
						disposeWindParticleTemporarily(n, _particlesToAnimate[n]);
					}
				}
			}
		}
		
		public function set worldBounds( value:WorldBounds2D ):void
		{
			if ( _worldBounds ) {
				_worldBounds.removeEventListener( InvalidationEvent.INVALIDATE, invalidateWorldBoundsHandler );
			}
			
			_worldBounds = value;
			
			if ( _worldBounds ) {
				worldBoundsRect = _worldBounds.getRect();
				_worldBounds.addEventListener( InvalidationEvent.INVALIDATE, invalidateWorldBoundsHandler );
			}
		}
		public function get worldBounds():WorldBounds2D { return _worldBounds; }
		
		private function invalidateWorldBoundsHandler( event:InvalidationEvent ):void
		{
			worldBoundsRect = _worldBounds.getRect();
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
		 * Create Wind Particle Pool. 
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
			
			_particlesPool = new Pool(particleCreate, particleClean, 10, 30);
		}
		
		/**
		 * Create eat particl objects and add to display list.
		 * Also called from the Pool class while creating minimum number of objects & run-time objects < maximum number.
		 * @return Eat particle that was created.
		 * 
		 */
		private function particleCreate():AbstractSkin2D
		{
			var newSkin:MovieClipSkin = new MovieClipSkin();
			_particlesContainer.children.addItem(newSkin);
			
			newSkin.x = worldBoundsRect.right;
			newSkin.validateNow();
			
			return newSkin;
		}
		
		/**
		 * Clean the eat particles before reusing from the pool. Called from the pool. 
		 * @param particle
		 * 
		 */
		private function particleClean(particle:AbstractSkin2D):void
		{
			particle.x = renderer.viewport.stage.stageWidth + particle.width * 2;
		}
		
		/**
		 * Create wind force particle. 
		 * 
		 */
		private function createParticle():void
		{
			// Create a wind particle.
			//var itemToTrack:Particle = _particlesPool.checkOut();
			var itemToTrack:MovieClipSkin = MovieClipSkin(_particlesPool.checkOut());
			
			// Place the object randomly along hte screen.
			itemToTrack.x = renderer.viewport.stage.stageWidth;
			itemToTrack.y = Math.random() * renderer.viewport.stage.stageHeight;
			
			// Set the scale of the wind object randomly.
			itemToTrack.scaleX = itemToTrack.scaleY = Math.random() * 0.5 + 0.5;
			
			var randItem:AbstractSkin2D = _particles[Math.round(Math.random() * (_particles.length-1))];
			var randImgSkin:ImageSkin = ImageSkin(randItem);
			var imgSkin:MovieClipSkin = MovieClipSkin(itemToTrack);
			imgSkin.texture = randImgSkin.texture;
			imgSkin.textureAtlas = randImgSkin.textureAtlas;
			imgSkin.texturesPrefix = randImgSkin.texturesPrefix;
			
			// Animate the wind particle.
			_particlesToAnimate[_particlesToAnimateLength++] = itemToTrack;
		}
		
		/**
		 * Dispose the wind particle temporarily. Check-in into pool (will get cleaned) and reduce the vector length by 1. 
		 * @param animateId
		 * @param particle
		 * 
		 */
		private function disposeWindParticleTemporarily(animateId:uint, particle:AbstractSkin2D):void//Particle):void
		{
			_particlesToAnimate.splice(animateId, 1);
			_particlesToAnimateLength--;
			_particlesPool.checkIn(particle);
		}
		
		/**
		 * Animate the wind particles that are marked animatable. 
		 * 
		 */
		private function animateParticles():void
		{
			var itemToTrack:AbstractSkin2D;//Particle;
			
			for(var i:uint = 0;i < _particlesToAnimateLength;i++)
			{
				// Create wind particle.
				itemToTrack = _particlesToAnimate[i];
				
				if (itemToTrack)
				{
					// Move the wind based on its scale.
					itemToTrack.x -= 100 * itemToTrack.scaleX; 
					
					// If the wind particle goes off screen, remove it.
					if (itemToTrack.x < -itemToTrack.width || globals.gameState == GlobalsProcess.GAME_STATE_OVER)
					{
						disposeWindParticleTemporarily(i, itemToTrack);
					}
				}
			}
		}	
	}
}