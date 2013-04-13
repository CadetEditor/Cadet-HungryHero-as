package model
{
	import cadet.core.CadetScene;
	
	import starling.display.DisplayObjectContainer;

	public interface IGameModel
	{
		function init( parent:DisplayObjectContainer ):void
		function reset():void
		function dispose():void
		
		function get cadetScene():CadetScene
		function set cadetScene( value:CadetScene ):void
		
		function get muted():Boolean
		function set muted( value:Boolean ):void
	}
}