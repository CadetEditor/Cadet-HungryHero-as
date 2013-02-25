// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package
{
	import flash.display.Sprite;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.entities.ComponentFactory;
	
	import cadet2D.components.core.Entity;
	
	import flox.app.FloxApp;
	import flox.app.managers.ResourceManager;
	
	import hungryHero.components.behaviours.ParallaxBehaviour;
	import hungryHero.components.processes.ItemsProcess;
	
	public class CadetEditor_Ext_HungryHero extends Sprite
	{
		public function CadetEditor_Ext_HungryHero()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;
			
			// Behaviours
			//resourceManager.addResource( new ComponentFactory( ItemBehaviour, "Item Behaviour", "Behaviours", CadetEngineIcons.Behaviour, Entity, 1 ) );
			resourceManager.addResource( new ComponentFactory( ParallaxBehaviour, "Parallax", "Behaviours",	CadetEngineIcons.Behaviour, Entity,	1 ) );
			// Processes
			resourceManager.addResource( new ComponentFactory( ItemsProcess, "Item Spawner", "Processes", CadetEngineIcons.Process ) );
		}
	}
}