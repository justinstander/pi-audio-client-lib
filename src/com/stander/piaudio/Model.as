package com.stander.piaudio
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.core.InteractionMode;
	
	/**
	 * Application Model
	 * 
	 * @author Justin.Stander
	 * @see flash.events.EventDispatcher
	 */
	public final class Model extends EventDispatcher
	{
		/**
		 * Constant for the <code>artists</code> view state
		 */
		public static const ARTISTS:String = "artists";
		
		/**
		 * Constant for the <code>albums</code> view state
		 */
		public static const ALBUMS:String = "albums";
		
		/**
		 * Constant for the <code>songs</code> view state
		 */
		public static const SONGS:String = "songs";
		
		/**
		 * Singleton instance 
		 */
		private static var instance:Model;
		
		/**
		 * Internal
		 * @see #files 
		 */
		private var _files:ArrayList;
		
		/**
		 * Internal
		 * @see #interactionMode 
		 */
		private var _interactionMode:String = InteractionMode.MOUSE;
		
		/**
		 * Internal
		 * @see #viewState 
		 */
		private var _viewState:String = ARTISTS;
		
		/**
		 * Internal
		 * @see #currentArtist 
		 */
		private var _currentArtist:ArrayList;
		
		/**
		 * Internal
		 * @see #currentAlbum 
		 */
		private var _currentAlbum:ArrayList;

		/**
		 * Constructor. Hidden through singleton enforcer.
		 * 
		 * @see SingletonEnforcer
		 */
		public function Model(enforcer:SingletonEnforcer)
		{
			super();
		}
		
		/**
		 * Gets the singleton instance for this class
		 * 
		 * @return Singleton instance
		 * @see #instance
		 */
		public static function getInstance():Model
		{
			if(instance == null)
			{
				instance = new Model(new SingletonEnforcer());
			}
			return instance;
		}
		
		[Bindable(event="filesChange")]
		/**
		 * Files object
		 */
		public function get files():ArrayList
		{
			return _files;
		}
		public function set files(value:ArrayList):void
		{
			if( _files !== value )
			{
				_files = value;
				dispatchEvent(new Event("filesChange"));
			}
		}
		
		[Bindable(event="interactionModeChange")]
		/**
		 * Global interaction mode
		 */
		public function get interactionMode():String
		{
			return _interactionMode;
		}
		public function set interactionMode(value:String):void
		{
			if( _interactionMode !== value)
			{
				_interactionMode = value;
				dispatchEvent(new Event("interactionModeChange"));
			}
		}
		
		[Bindable(event="viewStateChange")]
		/**
		 * View state 
		 */
		public function get viewState():String
		{
			return _viewState;
		}
		public function set viewState(value:String):void
		{
			if( _viewState !== value)
			{
				_viewState = value;
				dispatchEvent(new Event("viewStateChange"));
			}
		}
		
		[Bindable(event="currentArtistChange")]
		/**
		 * Current Artist's albums
		 */
		public function get currentArtist():ArrayList
		{
			return _currentArtist;
		}
		public function set currentArtist(value:ArrayList):void
		{
			if( _currentArtist !== value)
			{
				_currentArtist = value;
				dispatchEvent(new Event("currentArtistChange"));
			}
		}
		
		[Bindable(event="currentAlbumChange")]
		/**
		 * Current Album 
		 */
		public function get currentAlbum():ArrayList
		{
			return _currentAlbum;
		}
		public function set currentAlbum(value:ArrayList):void
		{
			if( _currentAlbum !== value)
			{
				_currentAlbum = value;
				dispatchEvent(new Event("currentAlbumChange"));
			}
		}

	}
}

/**
 * Empty class that prevents instances of this class to be instantiated
 * externally.
 * 
 * @author Justin.Stander
 * 
 */
class SingletonEnforcer{}