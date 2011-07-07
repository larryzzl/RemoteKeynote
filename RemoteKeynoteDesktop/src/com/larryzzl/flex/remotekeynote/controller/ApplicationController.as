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

	public class ApplicationController
	{
		private static var _inst:ApplicationController;
		
		protected var eventCenter:EventCenter = EventCenter.inst;
		protected var logger:Logger = Logger.inst;
		
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
			eventCenter.addEventListener(ApplicationEvent.SETUP_CONNECTION, onSetupConnection, false, 0, true);
			
			eventCenter.addEventListener(SlideEvent.SEND_SLIDE_CONTENT, onCommandSlideSendContent, false, 0, true);
			eventCenter.addEventListener(SlideEvent.SEND_SLIDE_TEXT, onCommandSendText, false, 0, true);
			eventCenter.addEventListener(SlideEvent.UPDATE_SLIDE_INFO, onCommandSlideUpdateInfo, false, 0, true);
			eventCenter.addEventListener(SlideEvent.RESET_SLIDE, onCommandResetSlide, false, 0, true);
		}
		
		protected function onCommandResetSlide(event:SlideEvent):void
		{
			logger.fine("Send command: resetSlide");
			sendMsg({command: {type: "resetSlide"}});
		}
		
		protected function onCommandSlideSendContent(event:SlideEvent):void
		{
			logger.fine("Send slideContent, index: " + event.slideIndex);
			sendMsg({slideContent: {slideContent: event.slideContent, slideIndex: event.slideIndex}});
		}
		
		protected function onCommandSendText(event:SlideEvent):void
		{
			logger.fine("Send slideText, index: " + event.slideIndex);
			sendMsg({slideText: {slideText: event.slideText, slideIndex: event.slideIndex}});
		}
		
		protected function onCommandSlideUpdateInfo(event:SlideEvent):void
		{
			logger.fine("Send command: slideInfo");
			sendMsg({command: {type: "slideInfo", info: {total: event.totalSlideNumber}}});
		}
		
		protected function onSetupConnection(event:ApplicationEvent):void
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
		
		private function dataParser(val:Object):void
		{
			if (val.hasOwnProperty("handShake"))
			{
				if (val.handShake == AppConfiguration.HAND_SHAKE_MESSAGE)
				{
					logger.fine("client connected");
					netGroup.sendToAllNeighbors({handShake: AppConfiguration.HAND_SHAKE_CONFIRM_MESSAGE});
					connectionState = 2;
					eventCenter.dispatchEvent(new ApplicationEvent(ApplicationEvent.CLIENT_CONNECTED));
				}
			}
			else if (val.hasOwnProperty("command"))
			{
				logger.fine("Receive command, type: " + val.command.type);
				switch (val.command.type)
				{
					case "slideNext":
						logger.fine("slideNext");
						eventCenter.dispatchEvent(new SlideEvent(SlideEvent.SLIDE_TO_NEXT));
						break;
					
					case "slidePrevious":
						logger.fine("slidePrevious");
						eventCenter.dispatchEvent(new SlideEvent(SlideEvent.SLIDE_TO_PREVIOUS));
						break;
					
					case "slideExit":
						eventCenter.dispatchEvent(new SlideEvent(ApplicationEvent.EXIT_APP));
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