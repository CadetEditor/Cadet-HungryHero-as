package view
{
	import assets.Assets;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import ui.GameOverContainer;
	import ui.HUD;
	import ui.PauseButton;
	
	public class GameView extends Sprite
	{
		// ------------------------------------------------------------------------------------------------------------
		// HUD
		// ------------------------------------------------------------------------------------------------------------
		
		// HUD Container.		
		public var hud:HUD;
		
		// ------------------------------------------------------------------------------------------------------------
		// INTERFACE OBJECTS
		// ------------------------------------------------------------------------------------------------------------
		
		public var gameWindow:Sprite;
		public var gameOverContainer:GameOverContainer;
		
		// Pause button.
		public var pauseButton:PauseButton;
		
		// Kick Off button in the beginning of the game
		public var startButton:Button;
		
		public function GameView()
		{
			// Is hardware rendering?
			//isHardwareRendering = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
			
			visible = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		// On added to stage.  
		//  @param event
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Draw Screen
			gameWindow	= new Sprite();
			addChild(gameWindow);
			
			// Pause button.
			pauseButton = new PauseButton();
			pauseButton.x = pauseButton.width * 2;
			pauseButton.y = pauseButton.height * 0.5;
			addChild(pauseButton);
			
			// Start button.
			startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			startButton.fontColor = 0xffffff;
			startButton.x = stage.stageWidth/2 - startButton.width/2;
			startButton.y = stage.stageHeight/2 - startButton.height/2;
			addChild(startButton);
			
			// Draw HUD
			hud = new HUD();
			addChild(hud);
			
			// Draw Game Over Screen
			gameOverContainer = new GameOverContainer();
			addChild(gameOverContainer);
		}
		
		// Initialize the game. 
		public function initialize():void
		{
			// Dispose screen temporarily.
			disposeTemporarily();
		
			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
			hud.lives = 0;//lives;
			
			// Hide the pause button since the game isn't started yet.
			pauseButton.visible = false;
			
			// Show start button.
			startButton.visible = true;
		}
		
		//  Dispose screen temporarily.
		public function disposeTemporarily():void
		{			
			gameOverContainer.visible = false;
		}
	}
}