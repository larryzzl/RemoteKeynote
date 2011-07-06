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
		
		private var currentSlideIndex:int = -1;
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
		
		public function get currentSlideText():String
		{
			if (currentSlideIndex == -1) return null;
			return slideTextPool[currentSlideIndex];
		}
		
		public function get currentSlideContent():BitmapData
		{
			if (currentSlideIndex == -1) return null;
			return slideContentPool[currentSlideIndex];
		}
		
		protected function setupListeners():void
		{
			eventCenter.addEventListener(SlideEvent.ADD_SLIDE_CONTENT, onAddSlideContent, false, 0, true);
			eventCenter.addEventListener(SlideEvent.ADD_SLIDE_TEXT, onAddSlideText, false, 0, true);
			eventCenter.addEventListener(SlideEvent.SLIDE_TO_NEXT, onSlideToNext, false, 0, true);
			eventCenter.addEventListener(SlideEvent.SLIDE_TO_PREVIOUS, onSlideToPrevious, false, 0, true);
			eventCenter.addEventListener(SlideEvent.RESET_SLIDE, onResetSlide, false, 0, true);
		}
		
		protected function onResetSlide(event:SlideEvent):void
		{
			currentSlideIndex:int = -1;
			slideContentPool.splice(0, slideContentPool.length);
			slideTextPool.splice(0, slideTextPool.length);
		}
		
		protected function onSlideToPrevious(event:SlideEvent):void
		{
			if (currentSlideIndex > 0)
			{
				currentSlideIndex--;
				var e:SlideEvent = new SlideEvent(SlideEvent.CURRENT_SLIDE_UPDATED);
				e.slideIndex = currentSlideIndex;
				e.slideContent = currentSlideContent;
				e.slideText = currentSlideText;
				eventCenter.dispatchEvent(e);
				
				eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.COMMAND_SLIDE_PREVIOUS));
			}
		}
		
		protected function onSlideToNext(event:SlideEvent):void
		{
			if (currentSlideIndex < slideContentPool.length - 1)
			{
				currentSlideIndex++;
				var e:SlideEvent = new SlideEvent(SlideEvent.CURRENT_SLIDE_UPDATED);
				e.slideIndex = currentSlideIndex;
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