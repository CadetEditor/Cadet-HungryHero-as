package hungryHero.components.behaviours
{
	import cadet2D.components.transforms.ITransform2D;

	public interface IMoveBehaviour extends IPowerupBehaviour
	{
		// The transform of the item to be moved
		function set transform( value:ITransform2D ):void
		function get transform():ITransform2D
	}
}