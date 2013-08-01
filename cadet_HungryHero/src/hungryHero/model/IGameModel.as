package hungryHero.model
{
	import cadet.core.CadetScene;
	
	import cadet2D.components.renderers.Renderer2D;
	
	import starling.display.DisplayObjectContainer;

	public interface IGameModel
	{
		function init( parent:DisplayObjectContainer ):void;
		function reset():void;
		function dispose():void;
		function enable():void;
		function disable():void;
		
		function get cadetScene():CadetScene;
		function set cadetScene( value:CadetScene ):void;
		
		function get muted():Boolean;
		function set muted( value:Boolean ):void;
		
		function get renderer():Renderer2D;
	}
}