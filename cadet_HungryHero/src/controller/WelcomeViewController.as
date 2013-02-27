package controller
{
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import events.NavigationEvent;
	
	import sound.Sounds;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	import view.WelcomeView;

	public class WelcomeViewController implements IController
	{
		private var _view				:WelcomeView;
		
		private const ABOUT_SCREEN		:String = "about";
		private const WELCOME_SCREEN	:String = "welcome";
		
		/** Screen mode - "welcome" or "about". */
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
			
			initializeView();
			
			_view.playBtn.addEventListener(Event.TRIGGERED, onPlayClick);
			_view.aboutBtn.addEventListener(Event.TRIGGERED, onAboutClick);
			_view.hsharmaBtn.addEventListener(Event.TRIGGERED, onHsharmaBtnClick);
			_view.starlingBtn.addEventListener(Event.TRIGGERED, onStarlingBtnClick);
			_view.backBtn.addEventListener(Event.TRIGGERED, onAboutBackClick);
		}
		
		public function disable():void
		{
			if (screenMode != ABOUT_SCREEN) SoundMixer.stopAll();
			
			_view.disposeTemporarily();
			_view.visible = false;
			
			_view.playBtn.removeEventListener(Event.TRIGGERED, onPlayClick);
			_view.aboutBtn.removeEventListener(Event.TRIGGERED, onAboutClick);
			_view.hsharmaBtn.removeEventListener(Event.TRIGGERED, onHsharmaBtnClick);
			_view.starlingBtn.removeEventListener(Event.TRIGGERED, onStarlingBtnClick);
			_view.backBtn.removeEventListener(Event.TRIGGERED, onAboutBackClick);
		}
		
		/**
		 * On back button click from about screen. 
		 * @param event
		 * 
		 */
		private function onAboutBackClick(event:Event):void
		{
			if (!Sounds.muted) Sounds.sndCoffee.play();
			
			initializeView();
		}
		
		/**
		 * On credits click on hsharma.com image. 
		 * @param event
		 * 
		 */
		private function onHsharmaBtnClick(event:Event):void
		{
			navigateToURL(new URLRequest("http://www.hsharma.com/"), "_blank");
		}
		
		/**
		 * On credits click on Starling Framework image. 
		 * @param event
		 * 
		 */
		private function onStarlingBtnClick(event:Event):void
		{
			navigateToURL(new URLRequest("http://www.gamua.com/starling"), "_blank");
		}
		
		/**
		 * On play button click. 
		 * @param event
		 * 
		 */
		private function onPlayClick(event:Event):void
		{
			_view.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "play"}, true));
			
			if (!Sounds.muted) Sounds.sndCoffee.play();
		}
		
		/**
		 * On about button click. 
		 * @param event
		 * 
		 */
		private function onAboutClick(event:Event):void
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
		private function showAboutScreen():void
		{
			screenMode = ABOUT_SCREEN;
			_view.showAbout();
		}		
	}
}