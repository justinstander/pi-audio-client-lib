package com.stander.piaudio.events
{
	import flash.events.Event;
	
	/**
	 * 
	 * @author Justin.Stander
	 * 
	 */
	public class SongEvent extends Event
	{
		/**
		 * 
		 */
		public static const SONG_SELECT:String = "songSelect";
		
		/**
		 * 
		 */
		public var song:Object;
		
		/**
		 * 
		 * @param type
		 * @param song
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function SongEvent(	type:String,
									song:Object,
									bubbles:Boolean = true,
									cancelable:Boolean = true)
		{
			super(type, bubbles, cancelable);
			this.song = song;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		override public function clone():Event
		{
			return new SongEvent(type, song, bubbles, cancelable);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		override public function toString():String
		{
			return formatToString("SongEvent", "type", "bubbles", "cancelable",
				"eventPhase");
		}
	}
}