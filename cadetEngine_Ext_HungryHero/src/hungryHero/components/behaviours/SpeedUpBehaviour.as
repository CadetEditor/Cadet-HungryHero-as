package hungryHero.components.behaviours
{
	import flash.events.Event;
	
	import cadet.core.Component;
	
	import hungryHero.components.processes.GlobalsProcess;
	
	public class SpeedUpBehaviour extends Component implements IPowerupBehaviour
	{
		public var globals			:GlobalsProcess;
		
		// How long does coffee power last? (in seconds)
		[Serializable][Inspectable( priority="50" )]
		public var effectLength	:Number = 50;
		
		[Inspectable( priority="51" )]
		public var power			:Number;
		
		private var notifyComplete	:Boolean;
		
		public function SpeedUpBehaviour()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(GlobalsProcess, "globals");
		}
		
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