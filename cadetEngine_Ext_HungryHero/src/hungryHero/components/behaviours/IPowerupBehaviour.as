package hungryHero.components.behaviours
{
	import flash.events.IEventDispatcher;

	public interface IPowerupBehaviour extends IEventDispatcher
	{
		function init():void
		function execute():void
	}
}