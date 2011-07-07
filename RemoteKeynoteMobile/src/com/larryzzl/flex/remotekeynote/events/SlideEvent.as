package com.larryzzl.flex.remotekeynote.events
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class SlideEvent extends BasicEvent
	{
		public static const ADD_SLIDE_CONTENT:String = "ADD_SLIDE_CONTENT";
		public static const ADD_SLIDE_TEXT:String = "ADD_SLIDE_TEXT";
		
		public static const SLIDE_TO_NEXT:String = "SLIDE_TO_NEXT";
		public static const SLIDE_TO_PREVIOUS:String = "SLIDE_TO_PREVIOUS";
		
		public static const CURRENT_SLIDE_UPDATED:String = "CURRENT_SLIDE_UPDATED";
		
		public static const RESET_SLIDE:String = "RESET_SLIDE";
		public static const SLIDE_INFO_UPDATE:String = "SLIDE_INFO_UPDATE";
		
		public var slideContent:ByteArray;
		public var slideBitmapData:BitmapData;
		public var slideText:String;
		public var slideIndex:int;
		public var slideInfo:Object;
		public var totalSlide:int;
		
		public function SlideEvent(type:String)
		{
			super(type);
		}
	}
}