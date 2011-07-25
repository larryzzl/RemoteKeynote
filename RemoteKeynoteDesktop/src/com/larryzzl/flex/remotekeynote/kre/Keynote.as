package com.larryzzl.flex.remotekeynote.kre
{
	import com.larryzzl.flex.remotekeynote.controller.Logger;
	import com.larryzzl.flex.remotekeynote.events.EventCenter;
	import com.larryzzl.flex.remotekeynote.events.SlideEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.xml.XMLDocument;
	
	import mx.rpc.xml.SimpleXMLDecoder;

	public class Keynote extends EventDispatcher
	{
		public static const KEYNOTE_STATE_IDLE:int = 0;
		public static const KEYNOTE_STATE_BUFFER:int = 1;
		public static const KEYNOTE_STATE_READY:int = 2;
		public static const KEYNOTE_STATE_ERROR:int = 3;
		
		private static const KEYNOTE_FILE_NAME:String = "keynote.xml";
		private static const SLIDE_LOAD_BUFFER_LENGTH:int = 3;
		
		private var rootUrl:String;
		private var _author:String;
		private var _createData:Date;
		private var _updateData:Date;
		private var _notes:String;
		private var _version:String;
		
		private var slides:Vector.<KeynoteSlide>;
		private var keynoteFile:File;
		private var curSlideIndex:int = 0;
		private var loadedSlideIndex:int = -1;
		
		private var keynoteState:int = KEYNOTE_STATE_IDLE;
		
		private var logger:Logger = Logger.inst;
		
		public function Keynote(folderUrl:String, autoLoad:Boolean = true)
		{
			rootUrl = folderUrl;
			slides = new Vector.<KeynoteSlide>;
			
			if (autoLoad) loadKeynote();
		}
		
		public function get state():int
		{
			return keynoteState;
		}
		
		public function get author():String
		{
			return _author;
		}
		
		public function get createData():Date
		{
			return _createData;
		}
		
		public function get updateData():Date
		{
			return _updateData;
		}
		
		public function get notes():String
		{
			return _notes;
		}
		
		public function get version():String
		{
			return _version;
		}
		
		public function get size():int
		{
			return slides.length;
		}
		
		public function get curIndex():int
		{
			return curSlideIndex;
		}
		
		public function loadKeynote():void
		{
			if (keynoteState == KEYNOTE_STATE_IDLE)
			{
				updateKeynoteState(KEYNOTE_STATE_BUFFER);
				generateKeynotSlides();
			}
		}
		
		public function nextSlide():Boolean
		{
			if (curSlideIndex == slides.length - 1) return false;
			
			curSlideIndex++;
			prepareSlides();
			
			return true;
		}
		
		public function previousSlide():Boolean
		{
			if (curSlideIndex == 0) return false;
			
			curSlideIndex--;
			prepareSlides();
			
			return true;
		}
		
		public function getCurrentSlide():KeynoteSlide
		{
			return slides[curSlideIndex];
		}
		
		public function getNextSlide():KeynoteSlide
		{
			return (curSlideIndex == slides.length - 1) ? null : slides[curSlideIndex + 1];
		}
		
		private function updateKeynoteState(val:int):void
		{
			if (keynoteState != val)
			{
				keynoteState = val;
				dispatchStateChangeEvent();
			}
		}
		
		private function generateKeynotSlides():void
		{
			cleanup();
			
			// get keynote file
			keynoteFile = new File(mixKeynoteFileName(rootUrl, KEYNOTE_FILE_NAME));
			if (keynoteFile.exists == false)
			{
				updateKeynoteState(KEYNOTE_STATE_ERROR);
				return;
			}
			
			keynoteFile.addEventListener(Event.COMPLETE, onKeynoteFileLoaded);
			keynoteFile.load();
		}
		
		protected function onKeynoteFileLoaded(event:Event):void
		{
			keynoteFile.removeEventListener(Event.COMPLETE, onKeynoteFileLoaded);
			
			var xmlDoc:XMLDocument = new XMLDocument(XML(keynoteFile.data).toXMLString());
			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
			var keynote:Object = decoder.decodeXML(xmlDoc);
			
			// generate slides
			var keynoteInfo:Object = keynote.remote_keynote.keynote_info;
			parseKeynoteInfo(keynoteInfo);
			var keynotes:Array = arrayGenerator(keynote.remote_keynote.keynotes.keynote);
			parseKeynoteSlides(keynotes);
			
			loadedSlideIndex = -1;
			curSlideIndex = 0;
			prepareSlides();
		}
		
		private function prepareSlides():void
		{
			updateKeynoteState(KEYNOTE_STATE_BUFFER);
			if (loadedSlideIndex + 1 < slides.length)
			{
				slides[loadedSlideIndex + 1].loadSlide(slideLoadDoneCallback);
			}
			else
			{
				checkIfSlideReady();
			}
		}
		
		private function slideLoadDoneCallback(slide:KeynoteSlide):void
		{
			logger.fine("Slide " + slide.slideIndex + " is loaded, success: " + (slide.state != KeynoteSlide.KEYNOTE_SLIDE_STATE_ERROR));
			
			loadedSlideIndex = slide.slideIndex;
			var e:SlideEvent = new SlideEvent(SlideEvent.SLIDE_LOADED);
			e.slideIndex = slide.slideIndex;
			e.slide = slide;
			EventCenter.inst.dispatchEvent(e);
			
			checkIfSlideReady();
			
			if (SLIDE_LOAD_BUFFER_LENGTH + curSlideIndex > loadedSlideIndex)
			{
				if (loadedSlideIndex + 1 < slides.length)
				{
					slides[loadedSlideIndex + 1].loadSlide(slideLoadDoneCallback);
				}
			}
		}
		
		private function checkIfSlideReady():void
		{
			if (slides[curSlideIndex].state >= KeynoteSlide.KEYNOTE_SLIDE_STATE_LOADED)
			{
				if (curSlideIndex + 1 < slides.length)
				{
					// check next slide
					if (slides[curSlideIndex + 1].state >= KeynoteSlide.KEYNOTE_SLIDE_STATE_LOADED)
					{
						playReady(true);
					}
					else
					{
						playReady(false);
					}
				}
				else
				{
					playReady(true);
				}
			}
			else
			{
				playReady(false);
			}
		}
		
		private function playReady(ready:Boolean):void
		{
			logger.fine("Slide ready: " + ready);
			updateKeynoteState(ready ? KEYNOTE_STATE_READY : KEYNOTE_STATE_BUFFER);
		}
		
		private function parseKeynoteInfo(val:Object):void
		{
			if (val.hasOwnProperty("author")) _author = val.author;
			if (val.hasOwnProperty("notes")) _notes = val.notes;
			if (val.hasOwnProperty("version")) _version = val.version;
			if (val.hasOwnProperty("create_date") && val.create_date != null)
			{
				var cd:Date = new Date;
				cd.setTime(Date.parse(val.create_date));
				_createData = cd;
			}
			if (val.hasOwnProperty("update_date") && val.update_date != null)
			{
				var ud:Date = new Date;
				ud.setTime(Date.parse(val.update_date));
				_updateData = ud;
			}
		}
		
		private function arrayGenerator(val:Object):Array
		{
			if (val is Array) return (val as Array);
			return [val];
		}
		
		private function parseKeynoteSlides(ks:Array):void
		{
			for each (var slide:Object in ks)
			{
				if (slide.enable == false) continue;
				var sks:KeynoteSlide = new KeynoteSlide(slides.length,
														mixKeynoteFileName(rootUrl, slide.background_image),
														slide.transition,
														slide.notes,
														slide.enable);
				slides.push(sks);
			}
			
			var e:SlideEvent = new SlideEvent(SlideEvent.UPDATE_SLIDE_INFO);
			e.totalSlideNumber = slides.length;
			EventCenter.inst.dispatchEvent(e);
		}
		
		private function mixKeynoteFileName(rootPath:String, name:String):String
		{
			var lastChar:String = rootPath.charAt(rootPath.length - 1);
			if (lastChar == "/" || lastChar == "\\")
			{
				return rootPath + name;
			}
			else
			{
				return rootPath + "/" + name;
			}
		}
		
		public function dispose():void
		{
			cleanup();
			updateKeynoteState(KEYNOTE_STATE_IDLE);
		}
		
		private function cleanup():void
		{
			// clean all slides
			if (slides.length > 0)
			{
				for each (var k:KeynoteSlide in slides)
				{
					k.dispose();
				}
				slides.splice(0, slides.length);
			}
			
			// clean keynote itself
			
		}
		
		private function dispatchStateChangeEvent():void
		{
			var e:KeynoteEvent = new KeynoteEvent(KeynoteEvent.KEYNOTE_STATE_CHANGE);
			e.keynoteState = keynoteState;
			dispatchEvent(e);
		}
	}
}