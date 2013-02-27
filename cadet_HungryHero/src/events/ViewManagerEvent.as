package events
{
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	public class ViewManagerEvent extends Event
	{
		public static const VIEW_CHANGE		:String = "viewChange";
		public var view						:DisplayObjectContainer;
		
		public function ViewManagerEvent(type:String)
		{
			super(type);
		}
		
	}
}