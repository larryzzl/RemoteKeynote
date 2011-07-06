package com.larryzzl.flex.remotekeynote.events
{
	import flash.display.BitmapData;

	public class SlideEvent extends BasicEvent
	{
		public static const ADD_SLIDE_CONTENT:String = "ADD_SLIDE_CONTENT";
		public static const ADD_SLIDE_TEXT:String = "ADD_SLIDE_TEXT";
		
		public static const SLIDE_TO_NEXT:String = "SLIDE_TO_NEXT";
		public static const SLIDE_TO_PREVIOUS:String = "SLIDE_TO_PREVIOUS";
		
		public static const CURRENT_SLIDE_UPDATED:String = "CURRENT_SLIDE_UPDATED";
		
		public static const RESET_SLIDE:String = "RESET_SLIDE";
		
		public var slideContent:BitmapData;
		public var slideText:String;
		public var slideIndex:int;
		
		public function SlideEvent(type:String)
		{
			super(type);
		}
	}
}