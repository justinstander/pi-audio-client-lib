package com.stander.piaudio.events
{
	import flash.events.Event;
	
	/**
	 * Album Event Class
	 * 
	 * @author Justin Stander (justin.stander@gmail.com)
	 * 
	 */
	public class AlbumEvent extends Event
	{
		/**
		 * 
		 */
		public static const ALBUM_SELECT:String = "albumSelect";
		
		/**
		 * 
		 */
		public var album:Object;
		
		/**
		 * 
		 * @param type
		 * @param album
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function AlbumEvent(	type:String,
									album:Object,
									bubbles:Boolean = true,
									cancelable:Boolean = true)
		{
			super(type, bubbles, cancelable);
			this.album = album;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		override public function clone():Event
		{
			return new AlbumEvent(type, album, bubbles, cancelable);
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