package com.larryzzl.flex.remotekeynote.kre
{
	import flash.events.Event;
	
	public class KeynoteEvent extends Event
	{
		public static const KEYNOTE_STATE_CHANGE:String = "KEYNOTE_STATE_CHANGE";
		
		public var keynoteState:int;
		
		public function KeynoteEvent(type:String)
		{
			super(type, false, false);
		}
	}
}