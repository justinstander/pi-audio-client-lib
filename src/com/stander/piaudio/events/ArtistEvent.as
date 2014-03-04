package com.stander.piaudio.events
{
	import flash.events.Event;
	
	/**
	 * 
	 * @author Justin.Stander
	 * 
	 */
	public class ArtistEvent extends Event
	{
		/**
		 * Constant for the <code>artistSelect</code> event 
		 */
		public static const ARTIST_SELECT:String = "artistSelect";
		
		/**
		 * Artist data 
		 */
		public var artist:Object;
		
		/**
		 * Album Event
		 *  
		 * @param type
		 * @param album
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function ArtistEvent(	type:String,
										artist:Object,
										bubbles:Boolean = true,
										cancelable:Boolean = true)
		{
			super(type, bubbles, cancelable);
			this.artist = artist;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		override public function clone():Event
		{
			return new ArtistEvent(type, artist, bubbles, cancelable);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		override public function toString():String
		{
			return formatToString("AlbumEvent", "type", "bubbles", "cancelable",
				"eventPhase");
		}
	}
}