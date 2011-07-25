package com.larryzzl.flex.remotekeynote.kre
{
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	import com.larryzzl.flex.remotekeynote.controller.Logger;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.UIComponent;

	public class KeynoteRenderEngine
	{
		private var keynote:Keynote;
		private var rootCanvas:UIComponent;
		
		private var curSlideContainer:UIComponent;
		private var nextSlideContainer:UIComponent;
		private var curSlide:KeynoteSlide;
		private var nextSlide:KeynoteSlide;
		
		private var isWaittingForNextSlide:Boolean = true;
		private var isSlideAnimating:Boolean = false;
		
		private var logger:Logger = Logger.inst;
		
		public function KeynoteRenderEngine(keynote:Keynote, canvas:UIComponent)
		{
			this.keynote = keynote;
			this.rootCanvas = canvas;
			
			prepare();
		}
		
		public function start():void
		{
			isWaittingForNextSlide = true;
			prepareSlides();
		}
		
		public function next():void
		{
			if (isSlideAnimating == true) return;
			
			if (nextSlide != null)
			{
				switch (nextSlide.transitionType)
				{
					case "fade":
						startTransitionFade();
						break;
					
					case "slide":
						startTransitionSlide();
						break;
					
					case "slide3d":
						startTransitionSlide3d();
						break;
				}
			}
		}
		
		public function previous():void
		{
			if (isSlideAnimating == true) return;
			
			isWaittingForNextSlide = true;
			if (keynote.previousSlide() == false) isWaittingForNextSlide = false;
		}
		
		private function prepare():void
		{
			// create placeholder for slides
			nextSlideContainer = new UIComponent;
			nextSlideContainer.width = rootCanvas.width;
			nextSlideContainer.height = rootCanvas.height;
			rootCanvas.addChild(nextSlideContainer);
			
			curSlideContainer = new UIComponent;
			curSlideContainer.width = rootCanvas.width;
			curSlideContainer.height = rootCanvas.height;
			rootCanvas.addChild(curSlideContainer);
			
			keynote.addEventListener(KeynoteEvent.KEYNOTE_STATE_CHANGE, onKeynoteStateUpdate, false, 0, true);
		}
		
		protected function onKeynoteStateUpdate(event:KeynoteEvent):void
		{
			if (event.keynoteState == Keynote.KEYNOTE_STATE_READY)
			{
				prepareSlides();
			}
			else if (event.keynoteState == Keynote.KEYNOTE_STATE_BUFFER)
			{
				logger.fine("loading slides");
			}
			else if (event.keynoteState == Keynote.KEYNOTE_STATE_ERROR)
			{
				logger.error("Slides load error! Current index: " + keynote.curIndex);
			}
		}
		
		private function prepareSlides():void
		{
			if (keynote.state == Keynote.KEYNOTE_STATE_READY)
			{
				if (isWaittingForNextSlide == false) return;
				
				isWaittingForNextSlide = false;
				curSlide = keynote.getCurrentSlide();
				nextSlide = keynote.getNextSlide();
				
				fillKeynoteContent(curSlideContainer, curSlide.renderResult);
				if (nextSlide != null) fillKeynoteContent(nextSlideContainer, nextSlide.renderResult);
			}
		}
		
		private function startTransitionFade():void
		{
			isSlideAnimating = true;
			nextSlideContainer.alpha = 0;
			Tweener.addTween(nextSlideContainer, {alpha: 1, time: 2});
			Tweener.addTween(curSlideContainer, {alpha: 0, time: 2, onComplete:keynoteTransitionEnd});
		}
		
		private function startTransitionSlide():void
		{
			isSlideAnimating = true;
			nextSlideContainer.x = curSlideContainer.width;
			Tweener.addTween(nextSlideContainer, {x: 0, time: 2, transition:Equations.easeOutQuart});
			Tweener.addTween(curSlideContainer, {x: -curSlideContainer.width, time: 2, transition:Equations.easeOutQuart, onComplete:keynoteTransitionEnd});
		}
		
		private function startTransitionSlide3d():void
		{
			isSlideAnimating = true;
			startTransitionSlide();
		}
		
		private function keynoteTransitionEnd():void
		{
			swipSlides();
			isWaittingForNextSlide = true;
			if (keynote.nextSlide() == true)
			{
				prepareSlides();
			}
			else
			{
				logger.fine("SLIDE END");
			}
			isSlideAnimating = false;
		}
		
		private function swipSlides():void
		{
			// swip current & next slide
			emptyContainer(curSlideContainer);
			emptyContainer(nextSlideContainer);
			fillKeynoteContent(curSlideContainer, nextSlide.renderResult);
			
			curSlideContainer.x = 0;
			curSlideContainer.alpha = 1;
			nextSlideContainer.x = 0;
			nextSlideContainer.alpha = 1;
		}
		
		private function fillKeynoteContent(container:UIComponent, keynoteContent:DisplayObject):void
		{
			container.addChild(keynoteContent);
			
			// fill content centered
			if (keynoteContent.width / keynoteContent.height > container.width / container.height)
			{
				var s:Number = keynoteContent.width / container.width;
				keynoteContent.width = container.width;
				keynoteContent.height = keynoteContent.height / s;
				
				keynoteContent.x = 0;
				keynoteContent.y = (container.height - keynoteContent.height) * 0.5;
			}
			else
			{
				s = keynoteContent.height / container.height;
				keynoteContent.width = keynoteContent.width / s;
				keynoteContent.height = container.height;
				
				keynoteContent.x = (container.width - keynoteContent.width) * 0.5;
				keynoteContent.y = 0;
			}
		}
		
		private function emptyContainer(container:UIComponent):void
		{
			for (var i:int = 0; i < container.numChildren; ++i)
			{
				container.removeChildAt(0);
			}
		}
	}
}