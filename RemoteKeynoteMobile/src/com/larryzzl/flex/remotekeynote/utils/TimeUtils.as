package com.larryzzl.flex.remotekeynote.utils
{
	public class TimeUtils
	{
		public function TimeUtils()
		{
		}
		
		public static function ms2TimeString(val:Number):String
		{
			if (val < 0) return "";
			
			var s:int = val * 0.001;	// second
			var m:int = s / 60;			// minute
			s = s - m * 60;
			var h:int = m / 60;			// hour
			m = m - h * 60;
			
			var t:String = ((s < 10) ? ":0" : ":") + s;
			t = m + t;
			if (m < 10 && m > 0) t = "0" + t;
			if (h > 0) t = h + ":" + t;
			return t;
		}
	}
}