package hungryHero.components.processes
{
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import hungryHero.components.behaviours.ParallaxBehaviour;
	
	public class BackgroundsProcess extends Component implements ISteppableComponent
	{
		private var _initialised	:Boolean = false;
		private var _parallaxes		:Vector.<IComponent>;
		public var globals			:GlobalsProcess;
		
		private const LEFT			:String = "LEFT";
		private const RIGHT			:String = "RIGHT";
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[LEFT,RIGHT]" )]
		public var xDirection		:String = LEFT;
		
		public function BackgroundsProcess()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
		}
		
		public function step(dt:Number):void
		{
			if (!_initialised) {
				initialise();
			}
			
			if (!globals) return;
			
			for ( var i:uint = 0; i < _parallaxes.length; i ++ ) {
				var parallax:ParallaxBehaviour = _parallaxes[i];
				parallax.speed = globals.playerSpeed * globals.elapsed;
				
				if ( xDirection == LEFT ) {
					parallax.speed *= -1;
				}
			}
		}
		
		private function initialise():void
		{
			_parallaxes = ComponentUtil.getChildrenOfType(_scene, ParallaxBehaviour, true);
			
			_initialised = true;
		}
	}
}