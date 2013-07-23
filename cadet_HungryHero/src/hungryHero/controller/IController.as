package hungryHero.controller
{
	import starling.display.DisplayObjectContainer;

	public interface IController
	{
		function init(view:DisplayObjectContainer):void;
		function reInit():void;
		function dispose():void;
		function enable():void;
		function disable():void;
	}
}