﻿package nonverblaster {	import flash.display.*;	import flash.events.*;	import flash.media.*;	import flash.net.*;	import flash.utils.ByteArray;	import flash.external.ExternalInterface;		public class TheAudio extends MovieClip{				private var main				:MovieClip;		private var url					:String;		private var soundChannel		:SoundChannel;		private var sound				:Sound;		private var pos					:Number;		private var isPlaying			:Boolean = false;		private var st					:SoundTransform = new SoundTransform();		public var plane				:Sprite = new Sprite();		private var ba					:ByteArray = new ByteArray();				public function TheAudio($main){			main = $main;			this.addChild(plane);		}		public function init($url){			drawPlane();			url = $url;			var request:URLRequest = new URLRequest(url);			sound = new Sound();			sound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);			sound.load(request);						this.buttonMode = true;			this.addEventListener(MouseEvent.MOUSE_DOWN, mH);		}		public function close(){			try {				soundChannel.stop();				sound.close();				//ExternalInterface.call("alert", "sound close!");			} catch(e:Error){};		}		private function mH(e:Event){			togglePlay();		}		public function drawPlane(){			plane.visible = false;			var g = plane.graphics;			g.clear();			g.beginFill(0xff0000, 0);			g.drawRect(0, 0, Glo.bal.stageWidth, Glo.bal.stageHeight);			g.endFill();		}		public function playAudio(){			playFrom(0);		}		private function playFrom($pos){			soundChannel = sound.play($pos, 1);			soundChannel.soundTransform = st;			soundChannel.addEventListener(Event.SOUND_COMPLETE, doSoundComplete);			isPlaying = true;		}		public function restart(){			soundChannel.stop();			playFrom(0);		}		public function togglePlay(){			if(isPlaying == true){				setPause();			} else {				resume();			}		}		public function resume(){			playFrom(pos);		}		public function setPause(){						pos = soundChannel.position;			soundChannel.stop();			isPlaying = false;		}		private function doSoundComplete(e:Event){			main.setEnd();		}		private function errorHandler(e:Event){			main.showError("No audio file was found! \n" + Glo.bal.mediaURL);		}		//		// Controlling Methods		//		public function getTotalTime():Number{			return(sound.length);		}		public function getPlayingProgress():Number{			return(soundChannel.position / sound.length * getLoadingProgress());		}		public function getLoadingProgress():Number {			return(sound.bytesLoaded / sound.bytesTotal);		}		public function getTime():Number {			return(soundChannel.position / 1000);		}		public function getDuration():Number {			return(sound.length / 1000);		}		public function setPlayingProgress(progressBarScale):void {			soundChannel.stop();			playFrom(progressBarScale * sound.length / getLoadingProgress());			if(main.isPlaying != true){				setPause();			}		}		public function setSoundTransform($st){			st = $st;			soundChannel.soundTransform = st;		}		public function getVolume():Number{			return(soundChannel.soundTransform.volume);		}	}}