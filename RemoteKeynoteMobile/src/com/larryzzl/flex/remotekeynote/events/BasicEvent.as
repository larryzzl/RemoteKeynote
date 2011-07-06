package com.larryzzl.flex.remotekeynote.events
{
	import flash.events.Event;
	
	public class BasicEvent extends Event
	{
		public var success:Boolean = true;
		public var param:Object;
		public var callback:Function;
		
		public function BasicEvent(type:String)
		{
			super(type, false, false);
		}
	}
}