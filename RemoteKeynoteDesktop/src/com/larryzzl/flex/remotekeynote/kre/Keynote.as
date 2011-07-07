package com.larryzzl.flex.remotekeynote.kre
{
	public class Keynote
	{
		public static const KEYNOTE_STATE_IDLE:int = 0;
		public static const KEYNOTE_STATE_LOADING:int = 1;
		public static const KEYNOTE_STATE_LOADED:int = 2;
		public static const KEYNOTE_STATE_SHOWING:int = 3;
		public static const KEYNOTE_STATE_ERROR:int = 4;
		
		public var backgroundImageUrl:String;
		public var transitionType:String;
		public var notes:String;
		
		private var keynoteState:int = KEYNOTE_STATE_IDLE;
		
		public function Keynote(bgUrl:String, tranType:String, note:String)
		{
			backgroundImageUrl = bgUrl;
			transitionType = tranType;
			notes = note;
		}
		
		public function loadKeynote():void
		{
			
		}
	}
}