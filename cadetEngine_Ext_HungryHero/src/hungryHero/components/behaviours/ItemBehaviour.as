package hungryHero.components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.AbstractSkin2D;
	
	public class ItemBehaviour extends Component implements ISteppableComponent
	{
		public var skin			:AbstractSkin2D;
		public var speed		:int = -15;
		
		public function ItemBehaviour()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(AbstractSkin2D, "skin");
		}
		
		public function step(dt:Number):void
		{
			skin.x += speed;
		}
	}
}