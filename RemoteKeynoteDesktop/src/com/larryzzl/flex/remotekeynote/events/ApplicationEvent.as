package com.larryzzl.flex.remotekeynote.events
{
	public class ApplicationEvent extends BasicEvent
	{
		public static const SETUP_CONNECTION:String = "SETUP_CONNECTION";
		public static const CLIENT_CONNECTED:String = "CLIENT_CONNECTED";
		
		public static const MOVE_SLIDE:String = "MOVE_SLIDE";
		public static const ZOOM_SLIDE:String = "ZOOM_SLIDE";
		public static const RESET_VISUAL_SLIDE:String = "RESET_VISUAL_SLIDE";

		public static const EXIT_APP:String = "EXIT_APP";
		
		public var newScale:Number = 1;
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;
		
		public function ApplicationEvent(type:String)
		{
			super(type);
		}
	}
}