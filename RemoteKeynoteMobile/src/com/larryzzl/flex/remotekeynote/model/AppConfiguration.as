package com.larryzzl.flex.remotekeynote.model
{
	public class AppConfiguration
	{
		public static const VERSION:String = "0.1.0";
		public static const APP_TYPE:String = "client";
		public static const GROUP_ID:String = "RemoteKeynote";
		// http://en.wikipedia.org/wiki/Multicast_address
		public static const MULTICASE_IP:String = "239.254.254.1:30303";
		public static const HAND_SHAKE_MESSAGE:String = "hello server";
		public static const HAND_SHAKE_CONFIRM_MESSAGE:String = "hello client";
	}
}