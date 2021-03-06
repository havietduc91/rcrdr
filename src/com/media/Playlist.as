package com.media
{
	import as3wavesound.WavSound;
	
	import com.common.SoundStream;
	
	import flash.sampler.pauseSampling;
	import flash.sensors.Accelerometer;
	import flash.utils.ByteArray;

	public class Playlist
	{
		private var _arrayStream:Array;
		private var _currentSound:Number;
		private var _currentSoundStream:SoundStream;

		public function get vol():Number
		{
			return _vol;
		}

		private var _callBack:Function;
		private var _tmpSoundStream:SoundStream;
		private var _timeInterval:Number;
		private var _isPlaying:Boolean;
		private var _vol:Number = 1;
		
		public function updateVolume(vol:Number) :void {
			_vol = vol;
			if(_currentSoundStream != null)
				_currentSoundStream.updateVolume(vol);
			if(_tmpSoundStream != null)
				_tmpSoundStream.updateVolume(vol);
		}
				
		public function Playlist()
		{
			_arrayStream = new Array();
			_currentSound = 0;
			_isPlaying = false;
		}
		
		public function AddSound(url:String):void {
			if(!_isPlaying){
				var ss:SoundStream = new NetSoundStream();
				ss.startup(url);
				_arrayStream.push(ss);
				_currentSound = _arrayStream.length - 1;	
				_timeInterval = -1;
				updateVolume(_vol);
			}
		}
		
		public function AddWavSound(byte:ByteArray, name:String):void {
			var ss:SoundStream = new WavSound(byte, name);
			_arrayStream.push(ss);
			_currentSound = _arrayStream.length - 1;	
			_timeInterval = -1;
			updateVolume(_vol);
		}
		
		public function STOPALL() :void {
			try {
				_tmpSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped");
			}
			try {
				_currentSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped");
			}
		}
		public function AddWaveSoundAndPlay(byte:ByteArray, isPlay:Boolean) : void {
			if(_isPlaying)
				return;
			try {
				_tmpSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped" + isPlay + " " + byte.length);
			}
			byte.position = 0;
			_tmpSoundStream = null;
			_tmpSoundStream = new WavSound(byte,"tmp");
			if(isPlay)
				_tmpSoundStream.play();
			updateVolume(_vol);
			trace("playing",byte.length);
		}
		
		public function play(time:Number = -1):void
		{
			if(_isPlaying)
				return;
			if(_currentSound >= _arrayStream.length)
				return;
			try {
				// stop tmp
				_tmpSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped");
			}
			_currentSoundStream = _arrayStream[_currentSound];
			_currentSoundStream.checkStream(_callBack);
			if(time != -1)
				_currentSoundStream.play(time);
			else _currentSoundStream.play();
			
			_isPlaying = true;	
			trace("play");
			updateVolume(_vol);
		}
				
		public function PLAYALL() :void {
			_currentSound = 0;
			_callBack = function (abc:String):void {
				NEXT();
				_isPlaying = false;
			}	
			play();		
		}
		
		public function NEXT():void {
			if(_currentSound >= _arrayStream.length)
				return;
			_currentSound ++;
			_callBack = function (abc:String):void {
				NEXT();
				_isPlaying = false;
			}
			play();		
		}
		
		public function addCallBack(callBack:Function):void {
			_callBack = function (abc:String):void {				
				_isPlaying = false;
				callBack(abc);
			}
		}
		
		public function getSoundTime(name:String):Number {
			var inSonglist:Boolean = false;
			for(var i:Number = 0;i < _arrayStream.length; i++)
			{
				if(name == (_arrayStream[i] as SoundStream).getName())
				{
					return (_arrayStream[i] as SoundStream).timeTotal();
				}
			}
			
			return -1;
		}
		
		
		public function playSpecial(name:String, time:Number):void
		{
			if(name == "" && _isPlaying)
			{
				_timeInterval = _currentSoundStream.getInterval();
				STOPALL();
				_isPlaying = false;
				return;
			}
			
			if(name == "" && !_isPlaying)
			{
				_timeInterval = _currentSoundStream.getInterval();
				_isPlaying = true;
				play(_timeInterval);
				return;
			}
			
			var inSonglist:Boolean = false;
			for(var i:Number = 0;i < _arrayStream.length; i++)
			{
				if(name == (_arrayStream[i] as SoundStream).getName())
				{
					_currentSound = i;
					inSonglist = true;
				}
			}
			if(inSonglist)
				play(time);
			else {
				AddSound(name);
				play(-1);
			}
		}
	}
}