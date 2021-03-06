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
	import cadet.core.ComponentContainer;
	import cadet.entities.ComponentFactory;
	
	import cadet2D.resources.ExternalXMLResourceParser;
	
	import core.app.CoreApp;
	import core.app.managers.ResourceManager;
	import core.app.resources.ExternalResourceParserFactory;
	
	import hungryHero.components.behaviours.HeroBehaviour;
	import hungryHero.components.behaviours.MagnetBehaviour;
	import hungryHero.components.behaviours.MoveBehaviour;
	import hungryHero.components.behaviours.ObstacleBehaviour;
	import hungryHero.components.behaviours.ParallaxBehaviour;
	import hungryHero.components.behaviours.ShakeBehaviour;
	import hungryHero.components.behaviours.SpeedUpBehaviour;
	import hungryHero.components.processes.BackgroundsProcess;
	import hungryHero.components.processes.EatParticlesProcess;
	import hungryHero.components.processes.GlobalsProcess;
	import hungryHero.components.processes.ItemsProcess;
	import hungryHero.components.processes.ObstaclesProcess;
	import hungryHero.components.processes.WindParticlesProcess;
	
	public class CadetEditor_Ext_HungryHero extends Sprite
	{
		public function CadetEditor_Ext_HungryHero()
		{
			var resourceManager:ResourceManager = CoreApp.resourceManager;
			
			resourceManager.addResource( new ExternalResourceParserFactory( ExternalXMLResourceParser, "External XML Resource Parser", ["pex"] ) );
			
			// Behaviours
			resourceManager.addResource( new ComponentFactory( HeroBehaviour, "Hero Behaviour", "Behaviours", CadetEngineIcons.Behaviour, ComponentContainer, 1 ) );
			resourceManager.addResource( new ComponentFactory( MagnetBehaviour, "Magnet Behaviour", "Behaviours", CadetEngineIcons.Behaviour ) );
			resourceManager.addResource( new ComponentFactory( MoveBehaviour, "Move Behaviour", "Behaviours", CadetEngineIcons.Behaviour ) );
			resourceManager.addResource( new ComponentFactory( ObstacleBehaviour, "Obstacle Behaviour", "Behaviours", CadetEngineIcons.Behaviour, ComponentContainer, 1 ) );
			resourceManager.addResource( new ComponentFactory( ParallaxBehaviour, "Parallax", "Behaviours",	CadetEngineIcons.Behaviour, ComponentContainer,	1 ) );
			resourceManager.addResource( new ComponentFactory( ShakeBehaviour, "Shake Behaviour", "Behaviours", CadetEngineIcons.Behaviour, null, 1 ) );
			resourceManager.addResource( new ComponentFactory( SpeedUpBehaviour, "Speed Up Behaviour", "Behaviours", CadetEngineIcons.Behaviour, ComponentContainer, 1 ) );
			// Processes
			resourceManager.addResource( new ComponentFactory( BackgroundsProcess, "Backgrounds Process", "Processes", CadetEngineIcons.Process ) );
			resourceManager.addResource( new ComponentFactory( GlobalsProcess, "Globals Process", "Processes", CadetEngineIcons.Process ) );
			resourceManager.addResource( new ComponentFactory( ItemsProcess, "Items Process", "Processes", CadetEngineIcons.Process ) );
			resourceManager.addResource( new ComponentFactory( ObstaclesProcess, "Obstacles Process", "Processes", CadetEngineIcons.Process ) );
			resourceManager.addResource( new ComponentFactory( EatParticlesProcess, "Eat Particle Process", "Processes", CadetEngineIcons.Process ) );
			resourceManager.addResource( new ComponentFactory( WindParticlesProcess, "Wind Particle Process", "Processes", CadetEngineIcons.Process ) );
		}
	}
}