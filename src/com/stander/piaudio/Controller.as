package com.stander.piaudio
{
	import com.stander.piaudio.events.AlbumEvent;
	import com.stander.piaudio.events.ArtistEvent;
	import com.stander.piaudio.events.SongEvent;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.ui.Multitouch;
	
	import mx.collections.ArrayList;
	import mx.core.InteractionMode;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	/**
	 * Application Controller
	 * 
	 * @author Justin.Stander
	 * @see flash.events.EventDispatcher
	 */
	public final class Controller extends EventDispatcher
	{
		/**
		 * Singleton instance 
		 */
		private static var instance:Controller;
		
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
			addListeners(stage);
			
			if( Multitouch.supportsTouchEvents )
			{
				Model.getInstance().interactionMode = InteractionMode.TOUCH;
			}
			
			var service:HTTPService = new HTTPService();
			service.url = "http://98.113.133.110:8080/AudioGateway/Files";
			service.addEventListener(ResultEvent.RESULT,service_result);
			service.addEventListener(FaultEvent.FAULT,service_fault);
			service.send();
		}
		
		/**
		 * 
		 * @param stage
		 * 
		 */
		private function addListeners(stage:Stage):void
		{
			trace("Add Listeners to Display List");
			stage.addEventListener(
				ArtistEvent.ARTIST_SELECT, artistSelectHandler);
			stage.addEventListener(AlbumEvent.ALBUM_SELECT, albumSelectHandler);
			stage.addEventListener(SongEvent.SONG_SELECT, songSelectHandler);
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
		 * @param event Artist event instance
		 * 
		 */
		private function artistSelectHandler(event:ArtistEvent):void
		{
			event.stopImmediatePropagation();
			
			var model:Model = Model.getInstance();
			trace("Artist Select "+event.artist.mId);
			model.viewState = Model.ALBUMS;
			model.currentArtist = new ArrayList(event.artist.mAlbums);
		}
		
		/**
		 * 
		 * @param event Album event instance
		 * 
		 */
		private function albumSelectHandler(event:AlbumEvent):void
		{
			event.stopImmediatePropagation();
			
			var model:Model = Model.getInstance();
			trace("Album Select "+event.album.mId);
			model.viewState = Model.SONGS;
			model.currentAlbum = new ArrayList(event.album.mMusic);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function songSelectHandler(event:SongEvent):void
		{
			event.stopImmediatePropagation();
			
			var model:Model = Model.getInstance();
			trace("Song Select "+event.song.mId);
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