package hungryHero.model
{
	import cadet.components.processes.SoundProcess;
	import cadet.core.CadetScene;
	
	import cadet2D.components.renderers.Renderer2D;
	
	import hungryHero.components.processes.GlobalsProcess;
	
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
		
		function get renderer():Renderer2D;
		
		function get soundProcess():SoundProcess;
		function get globalsProcess():GlobalsProcess;
	}
}