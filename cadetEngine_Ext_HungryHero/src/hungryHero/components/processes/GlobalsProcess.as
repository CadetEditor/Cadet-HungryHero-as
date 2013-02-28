package hungryHero.components.processes
{
	import flash.utils.getTimer;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	public class GlobalsProcess extends Component implements ISteppableComponent
	{
		[Serializable][Inspectable(priority="51") ]
		public var numLives:int = 5;
		[Serializable][Inspectable(priority="52") ]
		public var playerMinSpeed:Number = 650;
		[Serializable][Inspectable(priority="53") ]
		public var playerMaxSpeed:Number = 1400;
		
		[Serializable][Inspectable(priority="54") ]
		public var playerSpeed:Number = playerMinSpeed;
		
		public var elapsed:Number = 0;
		
		/** Time calculation for animation. */
		private var timePrevious:Number = 0;
		private var timeCurrent:Number = 0;
		
		public function GlobalsProcess()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			
		}
		
		public function step( dt:Number ):void
		{
			calculateElapsed();
			
			// constantly slow playerSpeed down towards playerMinSpeed
			playerSpeed -= (playerSpeed - playerMinSpeed) * 0.01;
			if ( playerSpeed < playerMinSpeed + 1 ) {
				playerSpeed = playerMinSpeed;
			}
		}
		
		private function calculateElapsed():void
		{
			// Set the current time as the previous time.
			timePrevious = timeCurrent;
			
			// Get teh new current time.
			timeCurrent = getTimer(); 
			
			// Calcualte the time it takes for a frame to pass, in milliseconds.
			elapsed = (timeCurrent - timePrevious) * 0.001; 
		}
	}
}