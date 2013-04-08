package hungryHero.components.processes
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	public class GlobalsProcess extends Component implements ISteppableComponent
	{
		[Serializable][Inspectable(priority="51") ]
		public var numLives:int = 5;
		// priority 52
		private var _currentLives:int = numLives;
		
		[Serializable][Inspectable(priority="53") ]
		public var playerMinSpeed:Number = 650;
		[Serializable][Inspectable(priority="54") ]
		public var playerMaxSpeed:Number = 1400;
		
		[Serializable][Inspectable(priority="55") ]
		public var playerSpeed:Number = 0;

		[Serializable][Inspectable(priority="56") ]
		public var paused:Boolean = false;		
		
		public var elapsed:Number = 0;
		
		/** Time calculation for animation. */
		private var timePrevious:Number = 0;
		private var timeCurrent:Number = 0;
		
		public static const GAME_STATE_IDLE:String = "gameStateIdle";
		public static const GAME_STATE_FLYING:String = "gameStateFlying";
		public static const GAME_STATE_OVER:String = "gameStateOver";
		public static const GAME_STATE_ENDED:String = "gameStateEnded";
		
		public var gameState				:String;
		public var hitObstacle				:Number = 0;	// The power of obstacle after it is hit.
		public var scoreDistance			:Number = 0;
		public var scoreItems				:Number = 0;
		
		public function GlobalsProcess( name:String = "GlobalsProcess" )
		{
			gameState = GAME_STATE_IDLE;
			
			super(name);
		}
		
		public function reset():void
		{
			currentLives = numLives;
			gameState = GAME_STATE_IDLE;
			scoreItems = 0;
			scoreDistance = 0;
			hitObstacle = 0;
		}
		
		public function step( dt:Number ):void
		{
			calculateElapsed();
			
			if ( paused ) return;
			
			//trace("elapsed "+elapsed);
			
			if ( gameState == GAME_STATE_FLYING )
			{
				// constantly slow playerSpeed down towards playerMinSpeed
				playerSpeed -= (playerSpeed - playerMinSpeed) * 0.01;
	
				scoreDistance += (playerSpeed * elapsed) * 0.1;
			}
			else if ( gameState == GAME_STATE_OVER ) 
			{	
				if ( playerSpeed == 0 ) {
					dispatchEvent( new Event( GAME_STATE_ENDED )) ;
					gameState = GAME_STATE_ENDED;
				}
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
		
		[Serializable][Inspectable(priority="52") ]
		public function get currentLives():int
		{
			return _currentLives;
		}
		public function set currentLives( value:int ):void
		{
			_currentLives = value;
			
			if ( _currentLives == 0 ) {
				gameState = GAME_STATE_OVER;
			}
		}
	}
}



