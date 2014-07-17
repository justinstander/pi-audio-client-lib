package com.stander.piaudio
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	
	import mx.collections.ArrayList;
	import mx.core.InteractionMode;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	/**
	 * Application Controller
	 * 
	 * @author Justin.Stander
	 * @see flash.events.EventDispatcher
	 */
	public final class Controller extends EventDispatcher
	{
		/**
		 * Host Address
		 */
		private static const HOST:String = "98.116.242.159"
//		private static const HOST:String = "localhost"
		
		/**
		 * Service URL to get file list
		 */
		private static const URL_LIST_FILES:String = "http://"+HOST+":8080/AudioGateway/Files";
		
		/**
		 * Service URL to get a file. Requires replacement of tokens for 
		 * album, artist, and song.
		 */
		private static const URL_GET_FILE:String = "http://"+HOST+":8080/AudioGateway/Files?artist={0}&album={1}&song={2}"
		
		/**
		 * Keyboard key code for play button
		 */
		private static const KEY_CODE_PLAY:uint = 179;
		
		/**
		 * Keyboard key code for next button
		 */
		private static const KEY_CODE_NEXT:uint = 176;
		
		/**
		 * Keyboard key code for previous button
		 */
		private static const KEY_CODE_PREVIOUS:uint = 177;
		
		/**
		 * Keyboard key code for stop button 
		 */
		private static const KEY_CODE_STOP:uint = 178;
		
		/**
		 * Token used to in URL string for artist Id
		 */
		private static const ARTIST_TOKEN:String = "{0}";
		
		/**
		 * Token used to in URL string for album Id
		 */
		private static const ALBUM_TOKEN:String = "{1}";
		
		/**
		 * Token used to in URL string for song Id
		 */
		private static const SONG_TOKEN:String = "{2}";
			
		/**
		 * Singleton instance 
		 */
		private static var instance:Controller;
		
		/**
		 * Sound object for audio playback 
		 */
		private var audio:Sound;
		
		/**
		 * Current sound channel (if audio is playing) 
		 */
		private var channel:SoundChannel;
		
		/**
		 * 
		 */
		private var pausePosition:Number = NaN;
		
		/**
		 * Constructor. Hidden through singleton enforcer.
		 * 
		 * @see SingletonEnforcer
		 */
		public function Controller(enforcer:SingletonEnforcer)
		{
			super();
		}
		
		/**
		 * Gets the singleton instance for this class
		 * 
		 * @return Single instance
		 * @see #instance
		 */
		public static function getInstance():Controller
		{
			if(instance == null)
			{
				instance = new Controller(new SingletonEnforcer());
			}
			return instance;
		}
		
		/**
		 * Initializes the controller instance
		 * 
		 * @param url Url to server's file list
		 * 
		 */
		public function init(stage:Stage):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN,stage_keyDownHandler);
			
			if( Multitouch.supportsTouchEvents )
			{
				Model.getInstance().interactionMode = InteractionMode.TOUCH;
			}
			
			var service:HTTPService = new HTTPService();
			service.url = URL_LIST_FILES;
			service.addEventListener(ResultEvent.RESULT,service_result);
			service.addEventListener(FaultEvent.FAULT,service_fault);
			service.send();
		}
		
		/**
		 * Called from the view when the artist selection changes
		 * 
		 * @param event List event instance
		 * 
		 */
		public function artistChange(event:IndexChangeEvent):void
		{
			var list:List = List(event.target);
			if( list.selectedIndex != -1 )
			{
				var artist:Object = list.selectedItem;
				trace("Artist Select "+artist.mId);
				var model:Model = Model.getInstance();
				model.viewState = Model.STATE_ALBUMS;
				model.currentArtist = new ArrayList(artist.mAlbums);
				list.selectedIndex = -1;
			}
		}
		
		/**
		 * Called from the view when the album selection changes
		 * 
		 * @param event List event instance
		 * 
		 */
		public function albumChange(event:IndexChangeEvent):void
		{
			var list:List = List(event.target);
			if( list.selectedIndex != -1 )
			{
				var album:Object = list.selectedItem;
				trace("Album Select "+album.mId);
				var model:Model = Model.getInstance();
				model.viewState = Model.STATE_SONGS;
				model.currentAlbum = new ArrayList(album.mMusic);
				list.selectedIndex = -1;
			}
			if( audio == null )
			{
				mapAlbumToPlaylist();
				updateCurrentItem(0);
			}
		}
		
		/**
		 * Called from the view when the song selection changes
		 * 
		 * @param event List event instance
		 * 
		 */
		public function songChange(event:IndexChangeEvent):void
		{
			trace("Song Selection Change");
			var list:List = List(event.target);
			var model:Model = Model.getInstance();
			var currentSong:Object = model.playlist[model.playlistIndex];
			var selectedSong:Object = list.selectedItem;
			
			if( selectedSong.mArtistId != currentSong.mArtistId ||
				((selectedSong.mArtistId == currentSong.mArtistId) && (selectedSong.mAlbumId != currentSong.mAlbumId)) )
			{
				trace("* Different Artist or Different Album");
				trace("Current: " + currentSong.mArtistId + " " + currentSong.mAlbumId);
				trace("Selected: " + selectedSong.mArtistId + " " + selectedSong.mAlbumId);
				mapAlbumToPlaylist();
			}
			
			jumpToIndex(list.selectedIndex);
		}
		
		/**
		 * Handles back functionality from navigation 
		 * 
		 */
		public function back():void
		{
			var model:Model = Model.getInstance();
			switch(model.viewState)
			{
				case Model.STATE_ALBUMS:
					model.viewState = Model.STATE_ARTISTS;
					break;
				case Model.STATE_SONGS:
					model.viewState = Model.STATE_ALBUMS;
					break;
			}
		}
		
		/**
		 * Handles play functionality from navigation
		 * 
		 */
		public function play():void
		{
			var model:Model = Model.getInstance();
			if( audio != null)
			{
				if( isNaN(pausePosition) )
				{
					pausePosition = channel.position;
					destroyChannel();
					model.playIcon = Model.ICON_PLAY;
				}
				else
				{
					channel = audio.play(pausePosition);
					addChannelListeners();
					pausePosition = NaN;
					model.playIcon = Model.ICON_PAUSE;
				}
			}
			else
			{
				model.stopEnabled = true;
				model.playIcon = Model.ICON_PAUSE;
				
				playCurrentIndex();
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function stop():void
		{
			if( channel != null )
			{
				channel.stop();
			}
			
			var model:Model = Model.getInstance();
			model.stopEnabled = false;
			model.playIcon = Model.ICON_PLAY;
			
			destroyExistingAudio();
			
			updateCurrentItem(0);
		}
		
		/**
		 * 
		 * 
		 */
		public function previous():void
		{
			trace("Previous");
			var model:Model = Model.getInstance();
			if(model.playlistIndex > 0)
			{
				jumpToIndex(model.playlistIndex-1);
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function next():void
		{
			trace("Next");
			var model:Model = Model.getInstance();
			if(model.playlistIndex < model.playlist.length-1)
			{
				jumpToIndex(model.playlistIndex+1);
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function destroyExistingAudio():void
		{
			trace("Destroy Existing Audio");
			destroyAudio();
			destroyChannel();
			pausePosition = NaN;
		}
		
		/**
		 * 
		 * 
		 */
		private function addAudioListeners():void
		{
			if( audio != null )
			{
				audio.addEventListener(
					IOErrorEvent.IO_ERROR, audio_ioErrorHandler);
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function destroyAudio():void
		{
			if( audio != null )
			{
				audio.removeEventListener(
					IOErrorEvent.IO_ERROR, audio_ioErrorHandler);
				audio = null;
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function addChannelListeners():void
		{
			if( channel != null )
			{
				channel.addEventListener(
					Event.SOUND_COMPLETE, channel_soundCompleteHandler);
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function destroyChannel():void
		{
			if( channel != null )
			{
				channel.stop();
				channel.removeEventListener(
					Event.SOUND_COMPLETE, channel_soundCompleteHandler);
				channel = null;
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function mapAlbumToPlaylist():void
		{
			var model:Model = Model.getInstance();
			var count:uint = model.currentAlbum.length;
			var playlist:Vector.<Object> = new Vector.<Object>();
			for( var i:uint=0;i<count;i++ )
			{
				playlist[i] = model.currentAlbum.getItemAt(i);
			}
			model.playlist = playlist;
			model.playEnabled = true;
		}
		
		/**
		 * 
		 * @param index
		 * 
		 */
		private function jumpToIndex(index:uint):void
		{
			updateCurrentItem(index);
			if( audio != null )
			{
				playCurrentIndex();
			}
		}
		
		/**
		 * 
		 * 
		 */
		private function updateCurrentItem(index:uint):void
		{
			var model:Model = Model.getInstance();
			model.playlistIndex = index;
			model.playlistItem = model.playlist[index];
		}
		
		/**
		 * 
		 * 
		 */
		private function playCurrentIndex():void
		{
			trace("play current index");
			var model:Model = Model.getInstance();
			
			destroyExistingAudio();
			
			audio = new Sound();
			addAudioListeners();
			
			trace("Play ArtistId: "+model.playlistItem.mArtistId+" AlbumId: "+model.playlistItem.mAlbumId+" SongId: "+model.playlistItem.mId);
			
			var url:String = URL_GET_FILE
				.replace(ARTIST_TOKEN,model.playlistItem.mArtistId)
				.replace(ALBUM_TOKEN,model.playlistItem.mAlbumId)
				.replace(SONG_TOKEN,model.playlistItem.mId);
			var request:URLRequest = new URLRequest(url);
			
			audio.load(request);
			
			channel = audio.play();
			addChannelListeners();
			
			model.playIcon = Model.ICON_PAUSE;
		}
		
		/**
		 * Handles results from get files service call
		 * 
		 * @param event Result event instance
		 * @see #init
		 */
		private function service_result(event:ResultEvent):void
		{
			var files:Array = JSON.parse(String(event.result)) as Array;
			Model.getInstance().files = new ArrayList(files);
		}
		
		/**
		 * Handles a fault from get files service call
		 * 
		 * @param event Fault event instance
		 * @see #init
		 */
		private function service_fault(event:FaultEvent):void
		{
			trace("Fault: "+event.message);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function audio_ioErrorHandler(event:IOErrorEvent):void
		{
			trace("Audio IO Error");
			trace(event.text);
			stop();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function channel_soundCompleteHandler(event:Event):void
		{
			trace("Sound Complete");
			if( Model.getInstance().hasNext )
			{
				next();
			}
			else
			{
				stop();
			}
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case KEY_CODE_STOP:
					stop();
					break;
				case KEY_CODE_PREVIOUS:
					previous();
					break;
				case KEY_CODE_NEXT:
					next();
					break;
				case KEY_CODE_PLAY:
					play();
					break;
				default:
//					trace("Key Down: " + event.keyCode);
					break;
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