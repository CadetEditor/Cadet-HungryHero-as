package hungryHero.components.behaviours
{
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.transforms.ITransform2D;
	
	import starling.display.DisplayObjectContainer;
	
	public class ShakeBehaviour extends Component implements ISteppableComponent
	{
		public var shake		:Number;
		
		private var _target		:IComponent;
		
		[Serializable][Inspectable( priority="50" )]
		public var targetX		:Number = 0;
		[Serializable][Inspectable( priority="51" )]
		public var targetY		:Number = 0;
		
		public function ShakeBehaviour()
		{
			super("ShakeBehaviour");
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="52" )]
		public function set target( value:IComponent ):void
		{
			_target = value;
		}
		public function get target():IComponent { return _target; }
		
		public function step( dt:Number ):void
		{
			var xpos:int;
			var ypos:int;
			
			// Animate quake effect, shaking the camera a little to the sides and up and down.
			if (shake > 0)
			{
				shake -= 0.1;
				// Shake left right randomly.
				xpos = int(Math.random() * shake - shake * 0.5) + targetX; 
				// Shake up down randomly.
				xpos = int(Math.random() * shake - shake * 0.5) + targetY; 
			}
			else if ( xpos != targetX || xpos != targetY ) 
			{
				// If the shake value is 0, reset the stage back to normal.
				// Reset to initial position.
				xpos = targetX;
				xpos = targetY;
			}
			
			if ( target is Renderer2D ) {
				var viewport:DisplayObjectContainer = Renderer2D(target).viewport;
				if ( viewport ) {
					viewport.x = xpos;
					viewport.y = ypos;
				}
			} else if ( target is ITransform2D ) {
				var transform:ITransform2D = ITransform2D(target);
				transform.x = xpos;
				transform.y = ypos;
			}
		}
	}
}









