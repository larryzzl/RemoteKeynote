package com.larryzzl.flex.remotekeynote.events
{
	import com.larryzzl.flex.remotekeynote.kre.KeynoteSlide;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class SlideEvent extends BasicEvent
	{
		public static const SEND_SLIDE_CONTENT:String = "SEND_SLIDE_CONTENT";
		public static const SEND_SLIDE_TEXT:String = "SEND_SLIDE_TEXT";
		public static const UPDATE_SLIDE_INFO:String = "UPDATE_SLIDE_INFO";
		public static const RESET_SLIDE:String = "RESET_SLIDE";
		
		public static const SLIDE_LOADED:String = "SLIDE_LOADED";
		public static const SLIDE_TO_NEXT:String = "SLIDE_TO_NEXT";
		public static const SLIDE_TO_PREVIOUS:String = "SLIDE_TO_PREVIOUS";
		
		public static const CURRENT_SLIDE_UPDATED:String = "CURRENT_SLIDE_UPDATED";
		
		public var slideContent:ByteArray;
		public var slideBitmapData:BitmapData;
		public var slideText:String;
		public var slideIndex:int;
		public var slideInfo:Object;
		public var totalSlideNumber:int;
		public var slide:KeynoteSlide;
		
		public function SlideEvent(type:String)
		{
			super(type);
		}
	}
}