package hungryHero.components.behaviours
{
	import cadet.components.sounds.ISound;
	import cadet.core.IComponent;

	public interface IPowerupBehaviour extends IComponent
	{
		function init():void
		function execute():void
			
		function set collectSound( value:ISound ):void
		function get collectSound():ISound
	}
}