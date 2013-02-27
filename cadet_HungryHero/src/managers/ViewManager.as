package managers
{
	import flash.utils.Dictionary;
	
	import controller.IController;
	
	import events.ViewManagerEvent;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.EventDispatcher;
	
	[Event(type="events.ViewManagerEvent", name="viewChange")]
	
	public class ViewManager extends EventDispatcher
	{
		private var _container			:DisplayObjectContainer;
		
		private var _registeredViews			:Dictionary;
		private var _currentView			:DisplayObjectContainer;
		private var _currentController		:controller.IController;
		
		private var _viewToCreate		:Class;
		private var _fade				:Boolean;
		
		private var _viewInstances		:Dictionary;
		private var _activatedViews		:Dictionary;
		
		public function ViewManager( container:DisplayObjectContainer )
		{
			_container = container;
			
			_viewInstances = new Dictionary();
			_registeredViews = new Dictionary();
			_activatedViews	= new Dictionary();
		}
		
		public function registerView( viewType:Class, controllerType:Class ):void
		{
			_registeredViews[viewType] = controllerType;
			
			cacheView(viewType);
		}
		
		private function cacheView( viewType:Class ):void
		{
			if ( _viewInstances[viewType] ) return;
			var instance:DisplayObjectContainer = DisplayObjectContainer( new viewType() );
			_viewInstances[viewType] = instance;
		}
		
		public function disable():void
		{
			destroyCurrentView();
		}

		private function destroyCurrentView():void
		{
			if ( _currentController ) {
				_currentController.dispose();
				_currentController = null;
				_container.removeChild(_currentView);
				_currentView = null;
			}
		}
		
		public function changeView( viewType:Class ):void
		{
			_viewToCreate = viewType;

			if ( _currentController ) {
				_currentController.disable();
			}
			createNewView();			
		}
		
		private function createNewView():void
		{
			if ( !_viewToCreate ) return;
			
			if ( _viewInstances[_viewToCreate] == null ) {
				cacheView(_viewToCreate);
			}
			
			var controllerType:Class = _registeredViews[ _viewToCreate ];
			
			if ( _activatedViews[controllerType] ) {
				_currentController = IController(_activatedViews[controllerType]);
				_currentController.reInit();
			} else {
				_currentView = _viewInstances[_viewToCreate];
				
				_currentController = new controllerType();
				_container.addChild(_currentView);
				_currentController.init(_currentView);
				
				_activatedViews[controllerType]	= _currentController;
			}
		
			var event	:ViewManagerEvent   = new ViewManagerEvent(ViewManagerEvent.VIEW_CHANGE);
			event.view						= _currentView;
			dispatchEvent( event );
		}
		
		public function get currentView():DisplayObjectContainer
		{
			return _currentView;
		}
			
	}
}