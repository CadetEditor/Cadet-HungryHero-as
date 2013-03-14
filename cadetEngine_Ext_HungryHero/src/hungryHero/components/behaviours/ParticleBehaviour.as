package hungryHero.components.behaviours
{
	import cadet.core.Component;
	
	public class ParticleBehaviour extends Component
	{
		private var _speedX:Number;		// Speed X of the particle.
		private var _speedY:Number;		// Speed Y of the particle.
		private var _spin:Number;		// Spin value of the particle.
		
		public function ParticleBehaviour()
		{
			super();
		}
		
		/**
		 * Speed X of the particle. 
		 * 
		 */
		public function get speedX():Number { return _speedX; }
		public function set speedX(value:Number):void { _speedX = value; }
		
		/**
		 * Speed Y of the particle. 
		 * 
		 */
		public function get speedY():Number { return _speedY; }
		public function set speedY(value:Number):void { _speedY = value; }
		
		/**
		 * Spin value of the particle. 
		 * 
		 */
		public function get spin():Number { return _spin; }
		public function set spin(value:Number):void { _spin = value; }
	}
}