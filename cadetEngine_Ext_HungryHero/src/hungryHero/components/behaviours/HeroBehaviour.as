package hungryHero.components.behaviours
{
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	import cadet.core.IRenderer;
	import cadet.core.ISteppableComponent;
	import cadet.events.InvalidationEvent;
	import cadet.events.RendererEvent;
	import cadet.util.deg2rad;
	import cadet.util.rad2deg;
	
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.transforms.ITransform2D;
	import cadet2D.components.transforms.Transform2D;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class HeroBehaviour extends Component implements ISteppableComponent
	{
		public static const HERO_STATE_IDLE		:int = 0;
		public static const HERO_STATE_FLYING	:int = 1;
		public static const HERO_STATE_HIT		:int = 2;
		public static const HERO_STATE_FALL		:int = 3;
		
		private var state					:int;
		
		public var transform				:ITransform2D;
		public var skin						:ImageSkin;
		public var globals					:GlobalsProcess;
		public var shakeBehaviour			:ShakeBehaviour;
		private var _worldBounds			:WorldBounds2D;
		private var _renderer				:Renderer2D;
		
		private var worldBoundsRect			:Rectangle;

		private var touchX					:Number = 0;
		private var touchY					:Number = 0;
		
		public function HeroBehaviour()
		{
			
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
			addSceneReference(WorldBounds2D, "worldBounds");
			addSceneReference(Renderer2D, "renderer");
			addSceneReference(ShakeBehaviour, "shakeBehaviour");
			
			addSiblingReference(Transform2D, "transform");
			addSiblingReference(AbstractSkin2D, "skin");
		}	
		
		public function step(dt:Number):void
		{
			// HeroBehaviour is dependent on the following associations
			if (!renderer || !_renderer.viewport) return;
			if (!worldBounds) return;
			if (!globals || globals.paused) return;
			if (!transform) return;
			
			var startX:Number = 200;//_renderer.viewport.stage.stageWidth * 0.2;
			
			// Before game starts.
			if ( globals.gameState == GlobalsProcess.GAME_STATE_IDLE )
			{
				// Take off.
				if (transform.x < startX) {
					transform.x += ((startX + 10) - transform.x) * 0.05;
					transform.y -= (transform.y - touchY) * 0.1;
					
					globals.playerSpeed += (globals.playerMinSpeed - globals.playerSpeed) * 0.05;
					//bg.speed = playerSpeed * elapsed;
				} else {
					globals.gameState = GlobalsProcess.GAME_STATE_FLYING;
					state = HERO_STATE_FLYING;
				}
				
				rotateToMouse();
				confineToBounds();
			} 
			else if ( globals.gameState == GlobalsProcess.GAME_STATE_FLYING ) 
			{			
				// If not hit by obstacle, fly normally.
				if (globals.hitObstacle <= 0) {
					transform.y -= (transform.y - touchY) * 0.1;
					
					// If hero is flying extremely fast, create a wind effect and show force field around hero.
					if (globals.playerSpeed > globals.playerMinSpeed + 100) {
						//createWindForce();
						// Animate hero faster.
						//hero.setHeroAnimationSpeed(1);
					} else {
						// Animate hero normally.
						//hero.setHeroAnimationSpeed(0);
					}
					
					rotateToMouse();
					confineToBounds();
					
				} else {
					// Hit by obstacle
					//if (coffee <= 0)
					if ( globals.playerSpeed <= globals.playerMinSpeed )
					{
						// Play hero animation for obstacle hit.
						if (state != HERO_STATE_HIT) {
							state = HERO_STATE_HIT;
						}
						
						// Move hero to center of the screen.
						transform.y -= (transform.y - (worldBoundsRect.top + worldBoundsRect.height)/2) * 0.1;
						
						// Spin the hero.
						if (transform.y > _renderer.viewport.stage.stageHeight * 0.5) {
							transform.rotation -= deg2rad(globals.hitObstacle * 2);
						} else {
							transform.rotation += deg2rad(globals.hitObstacle * 2);
						}
					}
					
					// If hit by an obstacle.
					globals.hitObstacle--;
					
					// Camera shake.
					if (shakeBehaviour) {
						shakeBehaviour.shake = globals.hitObstacle;
					}
				}
			}
						
		}
		
		// This should be set FPS
		public function setHeroAnimationSpeed(speed:int):void 
		{
			if ( skin is MovieClipSkin ) {
				var mcSkin:MovieClipSkin = MovieClipSkin(skin);
				if (speed == 0) mcSkin.fps = 20;
				else mcSkin.fps = 60;
			}
		}
		
		private function rotateToMouse():void
		{
			if (!skin.quad) return;
			
			var halfSkinHeight:Number = skin.height * 0.5;
			var halfSkinWidth:Number = skin.width * 0.5;
			
			skin.quad.x = -halfSkinWidth;
			skin.quad.y = -halfSkinHeight;
			
			var rotation:Number = transform.rotation;
			
			// Rotate hero based on mouse position.
			var touchDiff:Number = -(transform.y - touchY) * 0.2;
			if ( touchDiff > -30 && touchDiff < 30 ) {
				rotation = deg2rad(touchDiff);
			}
			
			// Limit the hero's rotation to < 30.
			if (rad2deg(transform.rotation) > 30 ) rotation = deg2rad(30);
			if (rad2deg(transform.rotation) < -30 ) rotation = -deg2rad(30);
			
			transform.rotation = rotation;
		}
		
		private function confineToBounds():void
		{
			var halfSkinHeight:Number = skin.height * 0.5;
			
			// Confine the hero to stage area limit
			if (transform.y > worldBoundsRect.bottom - halfSkinHeight)    
			{
				transform.y = worldBoundsRect.bottom - halfSkinHeight;
				transform.rotation = deg2rad(0);
			}
			if (transform.y < worldBoundsRect.top + halfSkinHeight)    
			{
				transform.y = worldBoundsRect.top + halfSkinHeight;
				transform.rotation = deg2rad(0);
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
		
		public function set renderer( value:IRenderer ):void
		{
			if (!(value is Renderer2D)) return;
			
			if ( _renderer) {
				_renderer.viewport.stage.removeEventListener( TouchEvent.TOUCH, touchEventHandler );
			}
			_renderer = Renderer2D(value);
			
			if ( _renderer && _renderer.viewport ) {
				_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
			} else {
				renderer.addEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
			}
		}
		public function get renderer():IRenderer
		{
			return _renderer;
		}
		
		private function rendererInitialisedHandler( event:RendererEvent ):void
		{
			renderer.removeEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
			_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
		}
		
		protected function touchEventHandler( event:TouchEvent ):void
		{
			if ( !transform ) return;
			if ( !_renderer ) return;
			
			var dispObj:DisplayObject = DisplayObject(_renderer.viewport.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				// include MOVED for touch screens (where hover isn't available)
				if (touch.phase == TouchPhase.HOVER || touch.phase == TouchPhase.MOVED) {
					touchX = touch.globalX;
					touchY = touch.globalY;
					break;
				}
			}
		}
	}
}