package com.larryzzl.flex.remotekeynote.controller
{
	import mx.collections.ArrayCollection;

	public class Logger
	{
		private static var _inst:Logger;
		private static var logCount:int = 0;
		
		private var logPool:ArrayCollection;
		
		public static function get inst():Logger
		{
			if (_inst == null)
			{
				_inst = new Logger(new LoggerIniter);
			}
			return _inst;
		}
		
		public function Logger(val:LoggerIniter)
		{
			logPool = new ArrayCollection;
		}
		
		[Bindable]
		public function get logs():ArrayCollection
		{
			return logPool;
		}
		
		public function set logs(val:ArrayCollection):void
		{
			// do nothing here
		}
		
		public function fine(...args):void
		{
			var s:String = "";
			for (var i:int = 0; i < args.length; ++i)
			{
				if (args[i] == null) continue;
				s += args[i].toString();
				if (i != args.length - 1) s += ", ";
			}
			writeLog(s);
		}
		
		public function error(...args):void
		{
			var s:String = "";
			for (var i:int = 0; i < args.length; ++i)
			{
				if (args[i] == null) continue;
				s += args[i].toString();
				if (i != args.length - 1) s += ", ";
			}
			writeLog("[ERROR] " + s);
		}
		
		protected function writeLog(s:String):void
		{
			logCount++;
			logPool.addItemAt(logCount + ": " + s, 0);
			trace(logCount + ": " + s);
		}
	}
}

class LoggerIniter{}