package hungryHero.view
{
	import hungryHero.assets.Assets;
	
	import hungryHero.font.Font;
	import hungryHero.font.Fonts;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class WelcomeView extends Sprite
	{
		private var bg:Image;				// Background image.
		private var title:Image;			// Game title.
		
		public var playBtn:Button;
		public var aboutBtn:Button;
		public var hsharmaBtn:Button;
		public var starlingBtn:Button;
		public var backBtn:Button;
		
		private var hero:Image;				// Hero artwork.
		private var aboutText:TextField;	// About text field.
		
		private var _currentDate:Date;		// Current date.
		
		private var fontRegular:Font;		// Font - Regular text.
	
		private var tween_hero:Tween;		// Hero art tween object.
		
		public function WelcomeView()
		{
			//this.visible = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		// On added to stage. 
		//  @param event
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			drawScreen();
		}
		
		private function drawScreen():void
		{
			// GENERAL ELEMENTS
			bg = new Image(Assets.getTexture("BgWelcome"));
			bg.blendMode = BlendMode.NONE;
			this.addChild(bg);
			
			title = new Image(Assets.getAtlas().getTexture(("welcome_title")));
			title.x = 600;
			title.y = 65;
			this.addChild(title);
			
			// WELCOME ELEMENTS
			hero = new Image(Assets.getAtlas().getTexture("welcome_hero"));
			hero.x = -hero.width;
			hero.y = 130;
			this.addChild(hero);
			
			playBtn = new Button(Assets.getAtlas().getTexture("welcome_playButton"));
			playBtn.x = 640;
			playBtn.y = 340;
			this.addChild(playBtn);
			
			aboutBtn = new Button(Assets.getAtlas().getTexture("welcome_aboutButton"));
			aboutBtn.x = 460;
			aboutBtn.y = 460;
			this.addChild(aboutBtn);
			
			// ABOUT ELEMENTS
			fontRegular = Fonts.getFont("Regular");
			
			aboutText = new TextField(480, 600, "", fontRegular.fontName, fontRegular.fontSize, 0xffffff);
			aboutText.text = "Hungry Hero is a free and open source game built on Adobe Flash using Starling Framework.\n\nhttp://www.hungryherogame.com\n\n" +
				" The concept is very simple. The hero is pretty much always hungry and you need to feed him with food." +
				" You score when your Hero eats food.\n\nThere are different obstacles that fly in with a \"Look out!\"" +
				" caution before they appear. Avoid them at all costs. You only have 5 lives. Try to score as much as possible and also" +
				" try to travel the longest distance.";
			aboutText.x = 60;
			aboutText.y = 230;
			aboutText.hAlign = HAlign.CENTER;
			aboutText.vAlign = VAlign.TOP;
			aboutText.height = aboutText.textBounds.height + 30;
			this.addChild(aboutText);
			
			hsharmaBtn = new Button(Assets.getAtlas().getTexture("about_hsharmaLogo"));
			hsharmaBtn.x = aboutText.x;
			hsharmaBtn.y = aboutText.bounds.bottom;
			this.addChild(hsharmaBtn);
			
			starlingBtn = new Button(Assets.getAtlas().getTexture("about_starlingLogo"));
			starlingBtn.x = aboutText.bounds.right - starlingBtn.width;
			starlingBtn.y = aboutText.bounds.bottom;
			this.addChild(starlingBtn);
			
			backBtn = new Button(Assets.getAtlas().getTexture("about_backButton"));
			backBtn.x = 660;
			backBtn.y = 350;
			this.addChild(backBtn);
		}

		// Show about screen.
		public function showAbout():void	
		{	
			hero.visible = false;
			playBtn.visible = false;
			aboutBtn.visible = false;
			
			aboutText.visible = true;
			hsharmaBtn.visible = true;
			starlingBtn.visible = true;
			backBtn.visible = true;
		}
	
		// Initialize welcome screen.
		public function initialize():void
		{
			disposeTemporarily();
			
			hero.visible = true;
			playBtn.visible = true;
			aboutBtn.visible = true;
			
			aboutText.visible = false;
			hsharmaBtn.visible = false;
			starlingBtn.visible = false;
			backBtn.visible = false;
			
			hero.x = -hero.width;
			hero.y = 100;
			
			tween_hero = new Tween(hero, 4, Transitions.EASE_OUT);
			tween_hero.animate("x", 80);
			Starling.juggler.add(tween_hero);
			
			this.addEventListener(Event.ENTER_FRAME, floatingAnimation);
		}
		
		// Animate floating objects. 
		// @param event
		private function floatingAnimation(event:Event):void
		{
			_currentDate = new Date();
			
			hero.y = 130 + (Math.cos(_currentDate.getTime() * 0.002)) * 25;
			playBtn.y = 340 + (Math.cos(_currentDate.getTime() * 0.002)) * 10;
			aboutBtn.y = 460 + (Math.cos(_currentDate.getTime() * 0.002)) * 10;
		}
		
		// Dispose objects temporarily. 
		public function disposeTemporarily():void
		{
			if (this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, floatingAnimation);
		}		
	}
}