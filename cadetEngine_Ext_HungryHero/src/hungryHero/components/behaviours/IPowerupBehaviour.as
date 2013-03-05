package hungryHero.components.behaviours
{
	import flash.events.IEventDispatcher;
	
	import cadet.components.sounds.ISound;

	public interface IPowerupBehaviour extends IEventDispatcher
	{
		function init():void
		function execute():void
			
		function set collectSound( value:ISound ):void
		function get collectSound():ISound
	}
}