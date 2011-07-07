package com.larryzzl.flex.remotekeynote.events
{
	public class ApplicationEvent extends BasicEvent
	{
		public static const CONNECT_TO_SERVER:String = "CONNECT_TO_SERVER";
		public static const CONNECT_TO_SERVER_DONE:String = "CONNECT_TO_SERVER_DONE";
		public static const SEND_HAND_SHAKE:String = "SEND_HAND_SHAKE";
		
		public static const COMMAND_SLIDE_NEXT:String = "COMMAND_SLIDE_NEXT";
		public static const COMMAND_SLIDE_PREVIOUS:String = "COMMAND_SLIDE_PREVIOUS";
		public static const COMMAND_SLIDE_EXIT_APP:String = "COMMAND_SLIDE_EXIT_APP";
		
		public function ApplicationEvent(type:String)
		{
			super(type);
		}
	}
}