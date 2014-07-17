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
		public static const STATE_ARTISTS:String = "artists";
		
		/**
		 * Constant for the <code>albums</code> view state
		 */
		public static const STATE_ALBUMS:String = "albums";
		
		/**
		 * Constant for the <code>songs</code> view state
		 */
		public static const STATE_SONGS:String = "songs";
		
		[Embed(source="../assets/playButton.png")]
		/**
		 * Play button label for Play 
		 */
		public static const ICON_PLAY:Class;
		
		[Embed(source="../assets/pauseButton.png")]
		/**
		 * Play button label for Pause
		 */
		public static const ICON_PAUSE:Class;
		
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
		private var _viewState:String = STATE_ARTISTS;
		
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
		 * Internal
		 * @see #playEnabled 
		 */
		private var _playEnabled:Boolean;
		
		/**
		 * Internal
		 * @see #playLabel 
		 */
		private var _playIcon:Class = ICON_PLAY;
		
		/**
		 * Internal
		 * @see #stopEnabled 
		 */
		private var _stopEnabled:Boolean;
		
		/**
		 * Internal
		 * @see #playlist 
		 */
		private var _playlist:Vector.<Object>;
		
		/**
		 * Internal
		 * @see #playlistIndex
		 */
		private var _playlistIndex:int = -1;
		
		/**
		 * Internal
		 * @see #playlistItem 
		 */
		private var _playlistItem:Object;
		
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
				dispatchEvent(new Event("playlistItemChange"));
			}
		}

		[Bindable(event="playEnabledChange")]
		/**
		 * Playback enabled/available flag
		 */
		public function get playEnabled():Boolean
		{
			return _playEnabled;
		}
		public function set playEnabled(value:Boolean):void
		{
			if( _playEnabled !== value)
			{
				_playEnabled = value;
				dispatchEvent(new Event("playEnabledChange"));
			}
		}

		[Bindable(event="playlistChange")]
		/**
		 * Current playlist used for playback
		 */
		public function get playlist():Vector.<Object>
		{
			return _playlist;
		}
		public function set playlist(value:Vector.<Object>):void
		{
			if( _playlist !== value)
			{
				_playlist = value;
				dispatchEvent(new Event("playlistChange"));
				dispatchEvent(new Event("hasNextChange"));
				dispatchEvent(new Event("hasPreviousChange"));
			}
		}

		[Bindable(event="stopEnabledChange")]
		/**
		 * Stop enabled flag 
		 */
		public function get stopEnabled():Boolean
		{
			return _stopEnabled;
		}
		public function set stopEnabled(value:Boolean):void
		{
			if( _stopEnabled !== value)
			{
				_stopEnabled = value;
				dispatchEvent(new Event("stopEnabledChange"));
			}
		}

		[Bindable(event="playlistIndexChange")]
		/**
		 * Current Index of the current play list, if one exists 
		 */
		public function get playlistIndex():int
		{
			return _playlistIndex;
		}
		public function set playlistIndex(value:int):void
		{
			if( _playlistIndex !== value)
			{
				_playlistIndex = value;
				dispatchEvent(new Event("playlistIndexChange"));
				dispatchEvent(new Event("hasNextChange"));
				dispatchEvent(new Event("hasPreviousChange"));
			}
		}

		[Bindable(event="playIconChange")]
		/**
		 * Label for the play button 
		 */
		public function get playIcon():Class
		{
			return _playIcon;
		}
		public function set playIcon(value:Class):void
		{
			if( _playIcon !== value)
			{
				_playIcon = value;
				dispatchEvent(new Event("playIconChange"));
			}
		}

		[Bindable(event="hasNextChange")]
		/**
		 * Flag indicating if current playlist selection has a next item
		 */
		public function get hasNext():Boolean
		{
			if( _playlist == null )
			{
				return false;
			}
			return _playlistIndex != -1 && _playlistIndex < _playlist.length-1;
		}

		[Bindable(event="hasPreviousChange")]
		/**
		 * Flag indicating if current playlist selection has a previous item
		 */
		public function get hasPrevious():Boolean
		{
			if( _playlist == null )
			{
				return false;
			}
			return _playlistIndex > 0;
		}

		[Bindable(event="playlistItemChange")]
		/**
		 * Current playlist item (song)
		 */
		public function get playlistItem():Object
		{
			return _playlistItem;
		}
		public function set playlistItem(value:Object):void
		{
			if( _playlistItem !== value)
			{
				_playlistItem = value;
				dispatchEvent(new Event("playlistItemChange"));
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