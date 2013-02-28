package hungryHero.components.behaviours
{
	import flash.events.Event;
	
	import cadet.core.Component;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	public class SpeedUpBehaviour extends Component implements IPowerupBehaviour
	{
		public var globals			:GlobalsProcess;
		
		public var _effectLength	:Number = 50; // How long does coffee power last? (in seconds)
		
		private var power			:Number;
		
		private var notifyComplete	:Boolean;
		
		public function SpeedUpBehaviour()
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

		[Serializable][Inspectable( priority="50" )]
		public function set effectLength( value:Number ):void
		{
			_effectLength = value;
		}
		public function get effectLength():Number { return _effectLength; }
	
		// -------------------------------------------------------------------------------------
		
		public function init():void
		{
			power = effectLength;
			notifyComplete = false;
		}
		
		public function execute():void
		{
			if (!globals) return;
			
			// If drank coffee, fly faster for a while.
			if (power > 0)
			{
				globals.playerSpeed += (globals.playerMaxSpeed - globals.playerSpeed) * 0.2;
				
				// If we have a coffee, reduce the value of the power.
				power -= globals.elapsed;
			} else if (!notifyComplete) {
				notifyComplete = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}		
	}
}