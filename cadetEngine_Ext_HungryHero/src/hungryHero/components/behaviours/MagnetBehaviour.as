package hungryHero.components.behaviours
{
	import flash.events.Event;
	
	import cadet.core.Component;
	
	import cadet2D.components.transforms.ITransform2D;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	public class MagnetBehaviour extends Component implements IMoveBehaviour
	{
		public var globals			:GlobalsProcess;
		
		private var _transform:ITransform2D;
		
		[Serializable][Inspectable( priority="51" )]
		public var targetTransform:ITransform2D;
		
		[Serializable][Inspectable( priority="52" )]
		public var pcDistance:Number = 0.2;
		
		// How long does mushroom power last? (in seconds)
		[Serializable][Inspectable( priority="53" )]
		public var effectLength	:Number = 40;
		
		[Inspectable( priority="54" )]
		public var power			:Number;
		
		private var notifyComplete	:Boolean;
		
		public function MagnetBehaviour()
		{
			super();
		}
		
		public function init():void
		{
			power = effectLength;
			notifyComplete = false;
		}
		
		override protected function addedToScene():void
		{
			trace("ADDED MAGNET");
			addSceneReference(GlobalsProcess, "globals");
		}
		
		public function execute():void
		{
			var elapsed:Number = globals ? globals.elapsed : 0.01;
			
			// If drank coffee, fly faster for a while.
			if (power > 0)
			{
				movePercentageDistanceToTarget(transform, pcDistance);
				// If we have a coffee, reduce the value of the power.
				power -= elapsed;
				
				//trace("power "+power+" elapsed "+elapsed);
			} else if (!notifyComplete) {
				notifyComplete = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
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
		
		[Serializable][Inspectable( priority="50" )]
		public function set transform( value:ITransform2D ):void
		{
			_transform = value;
		}
		public function get transform():ITransform2D
		{
			return _transform;
		}
	}
}