package model
{
	import flash.events.IEventDispatcher;
	
	import cadet.core.CadetScene;
	
	import starling.display.DisplayObjectContainer;

	public interface IGameModel extends IEventDispatcher
	{
		function init( parent:DisplayObjectContainer ):void
		function reset():void
		function dispose():void
		
		function get cadetScene():CadetScene
		
		function get muted():Boolean
		function set muted( value:Boolean ):void
	}
}