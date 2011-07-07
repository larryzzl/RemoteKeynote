package com.larryzzl.flex.remotekeynote.controller
{
	import com.larryzzl.flex.remotekeynote.events.ApplicationEvent;
	import com.larryzzl.flex.remotekeynote.events.EventCenter;
	import com.larryzzl.flex.remotekeynote.events.SlideEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;

	public class SlideRemoter
	{
		private static var _inst:SlideRemoter;
		
		private var eventCenter:EventCenter = EventCenter.inst;
		private var logger:Logger = Logger.inst;
		
		private var totalSlideCount:int = 0;
		private var curSlideIdx:int = -1;
		private var slideContentPool:Vector.<BitmapData>;
		private var slideTextPool:Vector.<String>;
		
		private var keynoteStarts:Boolean = false;
		
		public static function get inst():SlideRemoter
		{
			if (_inst == null)
			{
				_inst = new SlideRemoter(new SlideRemoterIniter);
			}
			return _inst;
		}
		
		public function SlideRemoter(val:SlideRemoterIniter)
		{
			slideContentPool = new Vector.<BitmapData>;
			slideTextPool = new Vector.<String>;
			
			setupListeners();
		}
		
		public function get totalSlideNumber():int
		{
			return totalSlideCount;
		}
		
		public function get currentSlideIndex():int
		{
			return curSlideIdx;
		}
		
		public function get currentSlideText():String
		{
			// always display text of current slide
			if (curSlideIdx == -1) return null;
			return slideTextPool[curSlideIdx];
		}
		
		public function get currentSlideContent():BitmapData
		{
			// display content for next slide
			if (curSlideIdx == -1) return null;
			if (curSlideIdx >= slideContentPool.length - 1)
			{
				return slideContentPool[slideContentPool.length - 1];
			}
			else
			{
				return slideContentPool[curSlideIdx + 1];
			}
		}
		
		protected function setupListeners():void
		{
			eventCenter.addEventListener(SlideEvent.ADD_SLIDE_CONTENT, onAddSlideContent, false, 0, true);
			eventCenter.addEventListener(SlideEvent.ADD_SLIDE_TEXT, onAddSlideText, false, 0, true);
			eventCenter.addEventListener(SlideEvent.SLIDE_TO_NEXT, onSlideToNext, false, 0, true);
			eventCenter.addEventListener(SlideEvent.SLIDE_TO_PREVIOUS, onSlideToPrevious, false, 0, true);
			eventCenter.addEventListener(SlideEvent.RESET_SLIDE, onResetSlide, false, 0, true);
			eventCenter.addEventListener(SlideEvent.SLIDE_INFO_UPDATE, onSlideInfoUpdate, false, 0, true);
		}
		
		protected function onSlideInfoUpdate(event:SlideEvent):void
		{
			if (event.slideInfo.hasOwnProperty("total"))
			{
				totalSlideCount = event.slideInfo.total;
			}
		}
		
		protected function onResetSlide(event:SlideEvent):void
		{
			curSlideIdx = -1;
			keynoteStarts = false;
			slideContentPool.splice(0, slideContentPool.length);
			slideTextPool.splice(0, slideTextPool.length);
		}
		
		protected function onSlideToPrevious(event:SlideEvent):void
		{
			if (curSlideIdx > 0)
			{
				curSlideIdx--;
				updateCurrentSlide();
				eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.COMMAND_SLIDE_PREVIOUS));
			}
		}
		
		protected function onSlideToNext(event:SlideEvent):void
		{
			if (curSlideIdx < slideContentPool.length - 1)
			{
				curSlideIdx++;
				updateCurrentSlide();
				eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.COMMAND_SLIDE_NEXT));
			}
		}
		
		protected function onAddSlideText(event:SlideEvent):void
		{
			if (event.slideIndex == slideTextPool.length)
			{
				slideTextPool.push(event.slideText);
			}
			else if (event.slideIndex < slideTextPool.length)
			{
				slideTextPool[event.slideIndex] = event.slideText;
			}
			startKeynote();
			
			logger.fine("Slide text added, index: " + event.slideIndex);
		}
		
		private var _tmpIndex:int;
		protected function onAddSlideContent(event:SlideEvent):void
		{
			_tmpIndex = event.slideIndex;

			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSlideBitmapDataLoaded, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onSlideBitmapDatError, false, 0, true);
			loader.loadBytes(event.slideContent);
		}
		
		protected function onSlideBitmapDatError(event:Event):void
		{
			var cl:LoaderInfo = event.target as LoaderInfo;
			cl.removeEventListener(Event.COMPLETE, onSlideBitmapDataLoaded);
			cl.removeEventListener(IOErrorEvent.IO_ERROR, onSlideBitmapDatError);
		}
		
		protected function onSlideBitmapDataLoaded(event:Event):void
		{
			var cl:LoaderInfo = event.target as LoaderInfo;
			cl.removeEventListener(Event.COMPLETE, onSlideBitmapDataLoaded);
			cl.removeEventListener(IOErrorEvent.IO_ERROR, onSlideBitmapDatError);
			
			if (cl.content && (cl.content is Bitmap))
			{
				var bd:BitmapData = (cl.content as Bitmap).bitmapData;
				if (_tmpIndex == slideContentPool.length)
				{
					slideContentPool.push(bd);
				}
				else if (_tmpIndex < slideContentPool.length)
				{
					slideContentPool[_tmpIndex] = bd;
				}
			}
			startKeynote();
			
			logger.fine("Slide content added, index: " + _tmpIndex);
		}		
		
		protected function startKeynote():void
		{
			if (keynoteStarts == false)
			{
				if (slideTextPool.length > 0 && slideContentPool.length > 1)
				{
					keynoteStarts = true;
					curSlideIdx = 0;
					updateCurrentSlide();
				}
			}
		}
		
		protected function updateCurrentSlide():void
		{
			var e:SlideEvent = new SlideEvent(SlideEvent.CURRENT_SLIDE_UPDATED);
			e.slideIndex = curSlideIdx;
			e.slideBitmapData = currentSlideContent;
			e.slideText = currentSlideText;
			e.totalSlide = totalSlideCount;
			eventCenter.dispatchEvent(e);
		}
		
	}
}

class SlideRemoterIniter{}