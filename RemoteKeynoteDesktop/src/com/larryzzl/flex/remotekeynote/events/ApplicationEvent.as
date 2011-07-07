package com.larryzzl.flex.remotekeynote.events
{
	public class ApplicationEvent extends BasicEvent
	{
		public static const SETUP_CONNECTION:String = "SETUP_CONNECTION";
		public static const CLIENT_CONNECTED:String = "CLIENT_CONNECTED";

		public static const EXIT_APP:String = "EXIT_APP";
		
		public function ApplicationEvent(type:String)
		{
			super(type);
		}
	}
}