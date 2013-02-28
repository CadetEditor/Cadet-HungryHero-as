package hungryHero.components.behaviours
{
	import cadet.core.Component;
	
	import cadet2D.components.transforms.ITransform2D;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	public class MoveBehaviour extends Component implements IMoveBehaviour
	{
		public var globals					:GlobalsProcess;
		private var _transform				:ITransform2D;
		private var _angle					:Number = 0;
		
		public function MoveBehaviour()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
		}

		// -------------------------------------------------------------------------------------
		// PUBLIC API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable(priority="50", editor="Slider", min="0", max="360", snapInterval="1") ]
		public function set angle( value:Number ):void
		{
			_angle = value;
		}
		public function get angle():Number { return _angle; }
		
		[Serializable][Inspectable( priority="51", editor="ComponentList", scope="scene" )]
		public function set transform( value:ITransform2D ):void
		{
			_transform = value;
		}
		public function get transform():ITransform2D { return _transform; }
		
		// -------------------------------------------------------------------------------------
		
		public function init():void
		{
			
		}
		
		public function execute():void
		{
			var distance:Number = 10;
			if ( globals ) {
				distance = globals.playerSpeed * globals.elapsed;
			}
			moveFixedDistanceAtAngle(transform, angle * Math.PI / 180, distance)
		}
		
		// Move the Point a fixed distance at a given angle
		private function moveFixedDistanceAtAngle(transform:ITransform2D, angleRadians:Number, distance:Number):void
		{
			//var angleRadians:Number = angle * Math.PI / 180;
			var vX:Number = Math.sin(angleRadians);
			var vY:Number = Math.cos(angleRadians);
			
			var xStep:Number = distance * vX;
			var yStep:Number = distance * vY;
			
			transform.x += xStep;
			transform.y += yStep;
		}
		
/*		public function movePercentageDistanceToTarget(point:Point, target:Point, percentage:Number):Point
		{
			var a:Number = target.x - point.x; 
			var b:Number = target.y - point.y;
			var h:Number = Math.sqrt(a*a+b*b);
			
//			var angleRadians:Number = Math.atan2(a, b); 
//			angle = angleRadians * 180/Math.PI;
//			
//			var distance:Number = h * percentage;
//			
//			return moveFixedDistanceAtAngle(point, angleRadians, distance);
			
			var xStep:Number = a * percentage;
			var yStep:Number = b * percentage;
			
			point.x += xStep;
			point.y += yStep;
			
			return point;
		}*/
	}
}