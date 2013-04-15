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
	import cadet.core.IInitialisableComponent;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.TransformableSkin;
	import cadet2D.events.SkinEvent;
	
	import hungryHero.components.processes.GlobalsProcess;

	public class ParallaxBehaviour extends Component implements ISteppableComponent, IInitialisableComponent
	{
		public var globals			:GlobalsProcess;
		public var skin				:TransformableSkin;
		
		private var _skin1			:TransformableSkin;
		private var _skin2			:TransformableSkin;
		
		private var _speed			:Number;
		private var _depth			:Number;

		private var _initialised	:Boolean = false;
		
		public function ParallaxBehaviour( name:String = "ParallaxBehaviour")
		{
			super( name );
		}
		
		// "skin" will be replaced each time a new skin sibling is added, hence usage of
		// "skin1" and "skin2" when updating skin positions.
		override protected function addedToScene():void
		{
			addSceneReference( GlobalsProcess, "globals" );
			addSiblingReference( TransformableSkin, "skin" );
		}
		
		// IInitialisableComponent
		public function init():void
		{
			_skin1 = skin;
			_skin2 = TransformableSkin(_skin1.clone());
			parentComponent.children.addItem(_skin2);
			
			if ( _skin1.width == 0 ) {
				_skin1.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			} else {
				_skin2.x = _skin1.x + _skin1.width;
			}
		}
		
		// Wait for the texture to be validated so the width is set
		private function textureValidatedHandler( event:SkinEvent ):void
		{
			var skin:TransformableSkin = TransformableSkin(event.target);
			skin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			_skin2.x = _skin1.x + _skin1.width;
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
				// Skin 1 has moved off the left of the screen
				if ( _skin1.x + _skin1.width < 0 ) {
					_skin1.x = _skin2.x + _skin2.width;
				}
				// Skin 2 has moved off the left of the screen
				if ( _skin2.x + _skin2.width < 0 ) {
					_skin2.x = _skin1.x + _skin1.width;
				}
			} 
			// if direction is right
			else {
				// Skin 1 has moved off the right of the screen
				if ( _skin1.x > skin.displayObject.stage.stageWidth ) {
					_skin1.x = _skin2.x - _skin1.width;
				}
				// Skin 2 has moved off the right of the screen
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




