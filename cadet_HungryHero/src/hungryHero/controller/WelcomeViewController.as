package hungryHero.controller
{
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import hungryHero.events.NavigationEvent;
	
	import hungryHero.sound.Sounds;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	import hungryHero.view.WelcomeView;

	public class WelcomeViewController implements IController
	{
		private var _view				:WelcomeView;
		
		private const ABOUT_SCREEN		:String = "about";
		private const WELCOME_SCREEN	:String = "welcome";
		
		// Screen mode - "welcome" or "about".
		private var screenMode			:String;
		
		public function WelcomeViewController()
		{
		}
		
		public function init(view:DisplayObjectContainer):void
		{
			_view	= WelcomeView(view);
			
			enable();
		}
		
		public function reInit():void
		{
			enable();
		}
		
		public function dispose():void
		{
			disable();
		}
		
		public function enable():void
		{
			_view.visible = true;
			
			Sounds.instance.addEventListener( flash.events.Event.CHANGE, toggleMuteHandler );
			
			initializeView();
			
			_view.playBtn.addEventListener(starling.events.Event.TRIGGERED, onPlayClick);
			_view.aboutBtn.addEventListener(starling.events.Event.TRIGGERED, onAboutClick);
			_view.hsharmaBtn.addEventListener(starling.events.Event.TRIGGERED, onHsharmaBtnClick);
			_view.starlingBtn.addEventListener(starling.events.Event.TRIGGERED, onStarlingBtnClick);
			_view.backBtn.addEventListener(starling.events.Event.TRIGGERED, onAboutBackClick);
		}
		
		public function disable():void
		{
			if (screenMode != ABOUT_SCREEN) SoundMixer.stopAll();
			
			_view.disposeTemporarily();
			_view.visible = false;
			
			Sounds.instance.removeEventListener( flash.events.Event.CHANGE, toggleMuteHandler );
			
			_view.playBtn.removeEventListener(starling.events.Event.TRIGGERED, onPlayClick);
			_view.aboutBtn.removeEventListener(starling.events.Event.TRIGGERED, onAboutClick);
			_view.hsharmaBtn.removeEventListener(starling.events.Event.TRIGGERED, onHsharmaBtnClick);
			_view.starlingBtn.removeEventListener(starling.events.Event.TRIGGERED, onStarlingBtnClick);
			_view.backBtn.removeEventListener(starling.events.Event.TRIGGERED, onAboutBackClick);
		}
		
		private function toggleMuteHandler( event:flash.events.Event ):void
		{
			if ( !Sounds.muted ) {
				Sounds.sndBgMain.play(0, 999);	
			} else {
				SoundMixer.stopAll();
			}
		}
	
		// On back button click from about screen. 
		// @param event
		private function onAboutBackClick(event:starling.events.Event):void
		{
			if (!Sounds.muted) Sounds.sndCoffee.play();
			
			initializeView();
		}
		
		// On credits click on hsharma.com image. 
		// @param event
		private function onHsharmaBtnClick(event:starling.events.Event):void
		{
			navigateToURL(new URLRequest("http://www.hsharma.com/"), "_blank");
		}
		
		// On credits click on Starling Framework image. 
		// @param event
		private function onStarlingBtnClick(event:starling.events.Event):void
		{
			navigateToURL(new URLRequest("http://www.gamua.com/starling"), "_blank");
		}
		
		// On play button click. 
		// @param event
		private function onPlayClick(event:starling.events.Event):void
		{
			_view.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "play"}, true));
			
			if (!Sounds.muted) Sounds.sndCoffee.play();
		}
		
		// On about button click. 
		//  @param event
		private function onAboutClick(event:starling.events.Event):void
		{
			if (!Sounds.muted) Sounds.sndMushroom.play();
			
			showAboutScreen();
		}
		
		private function initializeView():void
		{
			// If not coming from about, restart playing background music.
			if (screenMode != ABOUT_SCREEN) {
				if (!Sounds.muted) Sounds.sndBgMain.play(0, 999);
			}
			
			screenMode = WELCOME_SCREEN;
			
			_view.initialize();
		}
		public function showAboutScreen():void
		{
			screenMode = ABOUT_SCREEN;
			_view.showAbout();
		}		
	}
}