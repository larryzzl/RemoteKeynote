package com.larryzzl.flex.remotekeynote.controller
{
	import com.larryzzl.flex.remotekeynote.events.ApplicationEvent;
	import com.larryzzl.flex.remotekeynote.events.EventCenter;
	import com.larryzzl.flex.remotekeynote.events.SlideEvent;
	import com.larryzzl.flex.remotekeynote.model.AppConfiguration;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.ByteArray;

	public class ApplicationController
	{
		private static var _inst:ApplicationController;
		
		protected var eventCenter:EventCenter = EventCenter.inst;
		protected var logger:Logger = Logger.inst;
		protected var slideRemoter:SlideRemoter = SlideRemoter.inst;
		
		private var nc:NetConnection;
		private var netGroup:NetGroup;
		// 0: unconnected, 1: connecting, 2: connected
		private var connectionState:int = 0;
		
		public static function get inst():ApplicationController
		{
			if (_inst == null)
			{
				_inst = new ApplicationController(new ApplicationControllerIniter);
			}
			return _inst;
		}
		
		public function ApplicationController(val:ApplicationControllerIniter)
		{
			setupListeners();
		}
		
		[Bindable]
		public function get isConnected():Boolean
		{
			return (connectionState != 0);
		}
		
		public function set isConnected(val:Boolean):void
		{
			// do thing here
		}
		
		protected function setupListeners():void
		{
			eventCenter.addEventListener(ApplicationEvent.CONNECT_TO_SERVER, onConnectToServer, false, 0, true);
			eventCenter.addEventListener(ApplicationEvent.SEND_HAND_SHAKE, onSendHandShake, false, 0, true);
			
			eventCenter.addEventListener(ApplicationEvent.COMMAND_SLIDE_NEXT, onCommandSlideNext, false, 0, true);
			eventCenter.addEventListener(ApplicationEvent.COMMAND_SLIDE_PREVIOUS, onCommandSlidePrevious, false, 0, true);
			eventCenter.addEventListener(ApplicationEvent.COMMAND_SLIDE_EXIT_APP, onCommandSlideExitApp, false, 0, true);
		}
		
		protected function onSendHandShake(event:Event):void
		{
			startHandShake();
		}
		
		protected function onCommandSlideExitApp(event:ApplicationEvent):void
		{
			logger.fine("Send command: slideExit");
			sendMsg({command: {type: "slideExit"}});
		}
		
		protected function onCommandSlidePrevious(event:ApplicationEvent):void
		{
			logger.fine("Send command: slidePrevious");
			sendMsg({command: {type: "slidePrevious"}});
		}
		
		protected function onCommandSlideNext(event:ApplicationEvent):void
		{
			logger.fine("Send command: slideNext");
			sendMsg({command: {type: "slideNext"}});
		}
		
		protected function onConnectToServer(event:ApplicationEvent):void
		{
			if (connectionState == 0)
			{
				initConnection();
			}
		}
		
		protected function initConnection():void
		{
			logger.fine("Start to connect to server");
			
			nc = new NetConnection;
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			nc.connect("rtmfp:");
			
			connectionState = 1;
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				
				case "NetGroup.Connect.Success":
					logger.fine("NetGroup.Connect.Success");
					startHandShake();
					break;
				
				// TODO: check if the exit works
				case "NetGroup.Connect.Exit":
					closeConnection();
					break;
				
				case "NetGroup.SendTo.Notify":
					dataParser(event.info.message);
					break;
			}
		}
		
		protected function closeConnection():void
		{
			logger.fine("Close connection");
			
			netGroup.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			nc.close();
			netGroup = null;
			nc = null;
			connectionState = 0;
		}
		
		private function setupGroup():void
		{
			logger.fine("Start to set up group");
			
			var gs:GroupSpecifier = new GroupSpecifier(AppConfiguration.GROUP_ID);
			gs.ipMulticastMemberUpdatesEnabled = true;
			gs.multicastEnabled = true;
			gs.postingEnabled = true;
			gs.routingEnabled = true;
			gs.addIPMulticastAddress(AppConfiguration.MULTICASE_IP);
			
			netGroup = new NetGroup(nc, gs.groupspecWithAuthorizations());
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
		}
		
		private function startHandShake():void
		{
			logger.fine("Start hand shake");
			netGroup.sendToAllNeighbors({handShake: AppConfiguration.HAND_SHAKE_MESSAGE});
		}
		
		private function dataParser(val:Object):void
		{
			if (val.hasOwnProperty("handShake"))
			{
				if (val.handShake == AppConfiguration.HAND_SHAKE_CONFIRM_MESSAGE)
				{
					logger.fine("Server connected");
					connectionState = 2;
					eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.CONNECT_TO_SERVER_DONE));
				}
			}
			else if (val.hasOwnProperty("slideText"))
			{
				logger.fine("Receive slideText, index: " + val.slideText.slideIndex);
				var e:SlideEvent = new SlideEvent(SlideEvent.ADD_SLIDE_TEXT);
				e.slideIndex = val.slideText.slideIndex;
				e.slideText = val.slideText.slideText;
				eventCenter.dispatchEvent(e);
			}
			else if (val.hasOwnProperty("slideContent"))
			{
				logger.fine("Receive slideText, index: " + val.slideContent.slideIndex);
				var e2:SlideEvent = new SlideEvent(SlideEvent.ADD_SLIDE_CONTENT);
				e2.slideIndex = val.slideContent.slideIndex;
				e2.slideContent = val.slideContent.slideContent;
				eventCenter.dispatchEvent(e2);
			}
			else if (val.hasOwnProperty("command"))
			{
				logger.fine("Receive command, type: " + val.command.type);
				switch (val.command.type)
				{
					case "resetSlide":
						eventCenter.dispatchEvent(new SlideEvent(SlideEvent.RESET_SLIDE));
						break;
					
					case "slideInfo":
						var e3:SlideEvent = new SlideEvent(SlideEvent.SLIDE_INFO_UPDATE);
						e3.slideInfo = val.command.info;
						eventCenter.dispatchEvent(e3);
						break;
				}
			}
		}
		
		private function sendMsg(val:Object):void
		{
			if (connectionState == 2) netGroup.sendToAllNeighbors(val);
		}
	}
}

class ApplicationControllerIniter{}