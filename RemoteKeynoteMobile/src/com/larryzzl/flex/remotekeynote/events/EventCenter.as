package com.larryzzl.flex.remotekeynote.events
{
	import flash.events.EventDispatcher;

	public class EventCenter extends EventDispatcher
	{
		private static var _inst:EventCenter;
		
		public static function get inst():EventCenter
		{
			if (_inst == null)
			{
				_inst = new EventCenter(new EventCenterIniter);
			}
			return _inst;
		}
		
		public function EventCenter(val:EventCenterIniter)
		{
		}
	}
}

class EventCenterIniter{}