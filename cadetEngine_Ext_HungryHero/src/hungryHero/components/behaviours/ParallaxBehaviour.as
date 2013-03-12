// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 50-99

package hungryHero.components.behaviours
{
	import cadet.core.Component;
	import cadet.core.IInitOnRunComponent;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.AbstractSkin2D;
	
	import hungryHero.components.processes.GlobalsProcess;

	public class ParallaxBehaviour extends Component implements ISteppableComponent, IInitOnRunComponent
	{
		public var globals			:GlobalsProcess;
		public var skin				:AbstractSkin2D;
		
		private var _skin1			:AbstractSkin2D;
		private var _skin2			:AbstractSkin2D;
		
		private var _speed			:Number;
		private var _depth			:Number;

		private var _initialised	:Boolean = false;
		
		public function ParallaxBehaviour()
		{
			name = "ParallaxBehaviour";
		}
		
		// "skin" will be replaced each time a new skin sibling is added, hence usage of
		// "skin1" and "skin2" when updating skin positions.
		override protected function addedToScene():void
		{
			addSceneReference( GlobalsProcess, "globals" );
			addSiblingReference( AbstractSkin2D, "skin" );
		}
		
		// IInitOnRunComponent
		public function init():void
		{
			_skin1 = skin;
			_skin2 = AbstractSkin2D(_skin1.clone());
			parentComponent.children.addItem(_skin2);
			_skin2.x = skin.x + skin.width;			
		}
		
		// ISteppableComponent
		public function step(dt:Number):void
		{
			if ( !skin || !_skin1 || !_skin2 ) return;
			if ( globals && globals.paused ) return;
			if ( !_skin1.displayObject.stage || !_skin2.displayObject.stage ) return;
			
			_skin1.x += Math.round(_speed * depth);
			_skin2.x += Math.round(_speed * depth);
			
			// if direction is left
			if ( _speed < 0 ) {
				if ( _skin1.x + _skin1.width < 0 ) {
					_skin1.x = _skin2.x + _skin2.width;
				}
				if ( _skin2.x + _skin2.width < 0 ) {
					_skin2.x = _skin1.x + _skin1.width;
				}
			} 
			// if direction is right
			else {
				if ( _skin1.x > skin.displayObject.stage.stageWidth ) {
					_skin1.x = _skin2.x - _skin1.width;
				}
				if ( _skin2.x > skin.displayObject.stage.stageWidth ) {
					_skin2.x = _skin1.x - _skin2.width;
				}					
			}
		}
		
		[Serializable][Inspectable( editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function set depth( value:Number ):void
		{
			_depth = value;
		}
		public function get depth():Number { return _depth; }
		
		[Serializable][Inspectable]
		public function set speed( value:Number ):void 
		{ 
			_speed = value;
		}
		public function get speed():Number { return _speed; }
	}
}




