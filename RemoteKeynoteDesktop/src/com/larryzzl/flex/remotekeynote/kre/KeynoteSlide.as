package com.larryzzl.flex.remotekeynote.kre
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class KeynoteSlide
	{
		public static const KEYNOTE_SLIDE_STATE_ERROR:int = -1;
		public static const KEYNOTE_SLIDE_STATE_IDLE:int = 0;
		public static const KEYNOTE_SLIDE_STATE_LOADING:int = 1;
		public static const KEYNOTE_SLIDE_STATE_LOADED:int = 2;
		public static const KEYNOTE_SLIDE_STATE_SHOWING:int = 3;
		
		public var backgroundImageUrl:String;
		public var transitionType:String;
		public var notes:String;
		public var isEnabled:Boolean = true;
		public var slideIndex:int;
		
		private var keynoteSlideState:int = KEYNOTE_SLIDE_STATE_IDLE;
		private var loadCallback:Function;
		private var loader:Loader;
		
		public function KeynoteSlide(idx:int, bgUrl:String, tranType:String, note:String, isEnabled:Boolean = true)
		{
			this.slideIndex = idx;
			this.backgroundImageUrl = bgUrl;
			this.transitionType = tranType;
			this.notes = note;
			this.isEnabled = isEnabled;
			
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSlideBackgroundLoaded, false, 0, true);
		}
		
		public function get state():int
		{
			return keynoteSlideState;
		}
		
		protected function onSlideBackgroundLoaded(event:Event):void
		{
			//trace(loader.content);
			if (loader.content && loader.content is Bitmap)
			{
				keynoteSlideState = KEYNOTE_SLIDE_STATE_LOADED;
			}
			else
			{
				keynoteSlideState = KEYNOTE_SLIDE_STATE_ERROR;
			}
			
			if (loadCallback != null)
			{
				loadCallback(this);
			}
		}
		
		public function loadSlide(cb:Function):void
		{
			if (keynoteSlideState == KEYNOTE_SLIDE_STATE_IDLE)
			{
				loadCallback = cb;
				keynoteSlideState = KEYNOTE_SLIDE_STATE_LOADING;
				loader.load(new URLRequest(backgroundImageUrl));
			}
			else if (keynoteSlideState == KEYNOTE_SLIDE_STATE_LOADED)
			{
				if (cb != null)
				{
					cb(this);
				}
			}
		}

		public function dispose():void
		{
			loader.unload();
			keynoteSlideState = KEYNOTE_SLIDE_STATE_IDLE;
		}
	}
}