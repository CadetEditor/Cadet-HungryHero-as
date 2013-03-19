package hungryHero.components.behaviours
{
	import cadet.components.sounds.ISound;
	import cadet.core.IComponent;
	
	import cadet2D.components.particles.PDParticleSystemComponent;

	public interface IPowerupBehaviour extends IComponent
	{
		function init():void
		function execute():void
			
		function set collectSound( value:ISound ):void
		function get collectSound():ISound
		
		function set particleEffect( value:PDParticleSystemComponent ):void
		function get particleEffect():PDParticleSystemComponent
	}
}