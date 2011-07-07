package com.larryzzl.flex.remotekeynote.controller
{
	import com.larryzzl.flex.remotekeynote.events.ApplicationEvent;
	import com.larryzzl.flex.remotekeynote.events.EventCenter;
	import com.larryzzl.flex.remotekeynote.events.SlideEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;

	public class SlideRemoter
	{
		private static var _inst:SlideRemoter;
		
		private var eventCenter:EventCenter = EventCenter.inst;
		
		private var totalSlideCount:int = 0;
		private var curSlideIdx:int = -1;
		private var slideContentPool:Vector.<BitmapData>;
		private var slideTextPool:Vector.<String>;
		
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
			curSlideIdx:int = -1;
			slideContentPool.splice(0, slideContentPool.length);
			slideTextPool.splice(0, slideTextPool.length);
		}
		
		protected function onSlideToPrevious(event:SlideEvent):void
		{
			if (curSlideIdx > 0)
			{
				curSlideIdx--;
				var e:SlideEvent = new SlideEvent(SlideEvent.CURRENT_SLIDE_UPDATED);
				e.slideIndex = curSlideIdx;
				e.slideContent = currentSlideContent;
				e.slideText = currentSlideText;
				eventCenter.dispatchEvent(e);
				
				eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.COMMAND_SLIDE_PREVIOUS));
			}
		}
		
		protected function onSlideToNext(event:SlideEvent):void
		{
			if (curSlideIdx < slideContentPool.length - 1)
			{
				curSlideIdx++;
				var e:SlideEvent = new SlideEvent(SlideEvent.CURRENT_SLIDE_UPDATED);
				e.slideIndex = curSlideIdx;
				e.slideContent = currentSlideContent;
				e.slideText = currentSlideText;
				eventCenter.dispatchEvent(e);
				
				eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.COMMAND_SLIDE_NEXT));
			}
		}
		
		protected function onAddSlideText(event:SlideEvent):void
		{
			if (event.slideIndex == slideTextPool.length + 1)
			{
				slideTextPool.push(event.slideText);
			}
			else if (event.slideIndex < slideTextPool.length)
			{
				slideTextPool[event.slideIndex] = event.slideText;
			}
		}
		
		protected function onAddSlideContent(event:SlideEvent):void
		{
			if (event.slideIndex == slideContentPool.length + 1)
			{
				slideContentPool.push(event.slideContent);
			}
			else if (event.slideIndex < slideContentPool.length)
			{
				slideContentPool[event.slideIndex] = event.slideContent;
			}
		}
	}
}

class SlideRemoterIniter{}