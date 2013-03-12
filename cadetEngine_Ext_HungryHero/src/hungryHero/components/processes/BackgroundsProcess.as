package hungryHero.components.processes
{
	import flash.utils.Dictionary;
	
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.ISteppableComponent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	import hungryHero.components.behaviours.ParallaxBehaviour;
	
	public class BackgroundsProcess extends Component implements ISteppableComponent
	{
		private var _parallaxes		:Vector.<IComponent>;
		public var globals			:GlobalsProcess;
		
		private const LEFT			:String = "LEFT";
		private const RIGHT			:String = "RIGHT";
		private const NONE			:String = "NONE";
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[LEFT,RIGHT,NONE]" )]
		public var xDirection		:String = LEFT;
		
		private var _parallaxTable	:Dictionary;	
		
		public function BackgroundsProcess()
		{
			super();
			
			_parallaxTable = new Dictionary();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
			
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
			
			addParallaxes();
		}
		
		public function step(dt:Number):void
		{
			if (!globals || globals.paused) return;
			
			var speed:Number = 0;
			
			if ( xDirection != NONE ) {
				speed = globals.playerSpeed * globals.elapsed;
				
				if ( xDirection == LEFT ) {
					speed *= -1;
				}
			}
			
			for each ( var parallax:ParallaxBehaviour in _parallaxTable ) {		
				parallax.speed = speed;
			}
		}
		
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ParallaxBehaviour == false ) return;
			addParallax( ParallaxBehaviour( event.component ) );
		}
		
		private function componentRemovedFromSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ParallaxBehaviour == false ) return;
			removeParallax( ParallaxBehaviour( event.component ) );
		}

		private function addParallaxes():void
		{
			var allParallaxes:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, ParallaxBehaviour, true );
			for each ( var parallax:ParallaxBehaviour in allParallaxes )
			{
				addParallax( parallax );
			}
		}
		
		private function addParallax( parallax:ParallaxBehaviour ):void
		{
			_parallaxTable[parallax] = parallax;
		}
		
		private function removeParallax( parallax:ParallaxBehaviour ):void
		{
			delete _parallaxTable[parallax];
		}
	}
}