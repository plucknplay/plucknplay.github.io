﻿/*NonverBlasterSimple VideoPlayer by Nonverblahttp://www.nonverbla.de*/package {	import de.popforge.events.*;	import nonverblaster.*;		import com.gskinner.motion.GTween;	import fl.motion.easing.*;	import flash.display.*;	import flash.text.*;	import flash.geom.*;	import flash.events.*;	import flash.media.*;	import flash.net.*;	import flash.external.*;	import flash.system.Security;	import flash.utils.*;	import flash.ui.*;		public class NonverBlaster extends MovieClip {		// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Constants 		//		// Timer speed in Milliseconds		private const INTERVAL_MS		:uint = 1;		private const FADEOUT_MS		:uint = 2500;		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Other Variables 		//		// For testing in Flash:		// Should the Player behave like running in fullScreen or not?		private var isFullScreen		:Boolean = false;		//		public var isPlaying			:Boolean = false;		public var isSeeking			:Boolean = false;		//		// Variables for the Volume Control		private var volumeTransform		:SoundTransform = new SoundTransform();		private var oldVolume			:Number;		//		private var stageRatio			:Number;		private var targetRatio			:Number;		//		private var tweenSpeed			:Number = .5;		//		// The »i« for the »for(){} loops«		private var i					:int;		//		// All used classes		private var playlist			:XML;		private var uldr				:URLLoader;		private var videosXML			:XMLList;		public var isComplete			:Boolean = false;		private var hideTimer			:Timer;		private var loopTimer			:Timer;		private var uiElements			:Array = new Array();		// Margins		public var gap					:uint = 5;		private var margin				:uint = 20;		private var controlHeight		:uint = 20;		//		public var started				:Boolean;		private var theVideo			:TheVideo;		private var teaser				:Teaser;		private var theAudio			:TheAudio;		private var youTube				:YouTube;						public var mediaObject			:MovieClip;				public var control				:Control;		private var customContextMenu	:CustomContextMenu;				private var external			:External;				public var media				:String = "video";				private var scaleBt				:ScaleBt;		public var fitFrame				:DisplayObject;				public var options				:Object;				private var subTitles			:SubTitles;		public var bufferWheel			:BufferWheel;				private var vimeoID				:String;		private var jsStartCalled		:Boolean = false;				//		// ==================================================================================================================================		// Constructor ______________________________________________________________________________________________________________________		//		public function NonverBlaster() {			external = new External(stage, this);						bufferWheel = new BufferWheel();			addChild(bufferWheel);						textFeld.visible = false;			startButton.visible = false;			if(stage != null){				setup(null);			}			Security.allowDomain ("*");		}		public function setup($options){						options = $options;						Glo.bal.main = this;						flash.system.Security.allowDomain("*");			//			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;			stage.quality = StageQuality.HIGH;			//						scaleBt = new ScaleBt();			scaleBt.init(this);						hdBt.init(this);			hdBt.visible = false;						setVariables();			getStageBounds();						startButton.init();						Colorizer.colorize(back, Glo.bal.playerBackColor);						teaser = new Teaser();			theVideo = new TheVideo(this);			youTube = new YouTube(this);			theAudio = new TheAudio(this);						initSubtitles();						control = new Control();			this.addChild(control);			control.init(this, gap, margin, tweenSpeed);			control.y = -40;						uiElements.push(control, scaleBt, hdBt);			// Timer for hiding the control			hideTimer = new Timer(2500, 1);			hideTimer.addEventListener(TimerEvent.TIMER, hideTimerHandler);			//			//			customContextMenu = new CustomContextMenu(this);			this.addChild(customContextMenu);			customContextMenu.init();						loopTimer = new Timer(20,0);			loopTimer.addEventListener(TimerEvent.TIMER, loopIt, false, 0, true);						setTints();						setVolume(Glo.bal.volume);			oldVolume = Glo.bal.volume;						new GTween((new Object()), .05, null, {paused:false, completeListener:fitToScreen});						if(Glo.bal.mediaURL.indexOf("vimeo.com") != -1 && Glo.bal.mediaURL.indexOf("moogaloop") == -1){				// This didn't work because of crossdomain issues, so I used PHP to find video files from vimeo				getVimeoVideo();				//init();			} else {				init();			}		}		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// The init function		//		public function init():void {			trace(Glo.bal.mediaURL);			stage.addEventListener(Event.MOUSE_LEAVE, onStageHandler);			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageHandler);			//			// Keyboard events			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);			stage.addEventListener(Event.FULLSCREEN, fullSreenHandler, false, 0, true);			stage.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);						setMediaType();			if(media == "audio" || Glo.bal.treatAsAudio == "true"){				control.fadeIn();			}			//			// start the Video			if (Glo.bal.autoPlay == "true") {				hideUI();				playMedia();			} else {				setTimeout(resetAll, 1);			}			fitToScreen(null);		}		private function getVimeoVideo(){			Security.loadPolicyFile ("http://vimeo.com/​api/​crossdomain.xml");			vimeoID = Glo.bal.mediaURL.split("vimeo.com/")[1];			XMLReader.loadXML(parseVimeoXML, "http://www.vimeo.com/moogaloop/load/clip:" + vimeoID);		}		public function parseVimeoXML($xml){			var request_signature = $xml.request_signature;			var request_signature_expires = $xml.request_signature_expires;			Glo.bal.teaserURL = $xml.video[0].thumbnail;			Glo.bal.mediaURL = "http://www.vimeo.com/moogaloop/play/clip:"+ vimeoID +"/"+ request_signature +"/" + request_signature_expires + "/?q=hd";			init();		}		public function setTints(){			startButton.setTint();			control.setTint();			scaleBt.setTint();			bufferWheel.setTint();			hdBt.setTint();		}		//		// Parsing the FlashVars		private function setVariables():void {			//			Glo.bal.mediaURL = "";			Glo.bal.teaserURL = "";									var testing:Boolean = false;			// Checks if on my machine, otherwise it won't load any media files by default			if(testing == true){				//				// FOR TESTING IN FLASH				//				Glo.bal.mediaURL = "http://www.nonverbla.de/nonverblaster-hover/media/nice-flowers-sd.mov";				// Glo.bal.hdURL = "../demo/media/nice-flowers-hd.mov";				Glo.bal.teaserURL = "http://www.nonverbla.de/nonverblaster-hover/media/nice-flowers.jpg";				// Glo.bal.quality = "standard";								//Glo.bal.mediaURL = "http://www.nonverbla.de/blog/elemente_blog/nice-flowers-small.mov";				//Glo.bal.mediaURL = "http://www.nonverbla.de/blog/elemente_blog/Kotelett-Piaffe.mp3";				//Glo.bal.mediaURL = "../demo/media/Kotelett-Piaffe.mp3";				//Glo.bal.mediaURL = "http://www.freisprung.com/movies/clouds.flv";								// YouTube:								//Glo.bal.mediaURL = "http://www.youtube.com/watch?v=UrGcd6PN7EE";				//Glo.bal.teaserURL = "http://img.youtube.com/vi/UrGcd6PN7EE/0.jpg";								// Glo.bal.mediaURL = "http://andreasstickel.de/andreasstickel/wp-content/uploads/2011/02/sex_and_the_city.mov";				// Vimeo:								//Glo.bal.mediaURL = "http://vimeo.com/9679622";								// Subtitles:								//Glo.bal.mediaURL = "../demo/media/sex-ist-mies.flv";				//Glo.bal.subtitlesURL = "../demo/media/sex-ist-mies-eng.srt";							}						//Glo.bal.playButtonUrl = "../demo/playButton.png";			Glo.bal.playButtonUrl = "";						Glo.bal.subtitlePosition = "bottom";			Glo.bal.subtitleSize = 15;			Glo.bal.subtitlesColor = "0xffffff";						Glo.bal.autoPlay = "false";			Glo.bal.allowSmoothing = "true";			Glo.bal.buffer = 1;			Glo.bal.showTimecode = "true";			Glo.bal.loop = "false";			Glo.bal.controlColor = "0xffffff";			Glo.bal.controlBackColor = "0x000000";			Glo.bal.showScalingButton = "true";			Glo.bal.scaling = true;			Glo.bal.volume = .8;			Glo.bal.playerBackColor = undefined;			Glo.bal.indentImageURL = "";			Glo.bal.crop = "false";			Glo.bal.controlsEnabled = "true";			Glo.bal.onClick = "togglePlay";			Glo.bal.treatAsAudio = "false";			Glo.bal.jsOnStart = "";			Glo.bal.jsOnComplete = "";									if(options == null){				options = root.loaderInfo.parameters;			}			//			// set all rootFlashVars toLowerCase(), to avoid faults with titleCaseStuff ;)						var flashVars = new Object();			var keyStr:String;		    var valueStr:String;						for (keyStr in options) {				valueStr = String(options[keyStr]);				flashVars[keyStr.toLowerCase()] = valueStr;			}			for (keyStr in flashVars){				valueStr = String(flashVars[keyStr]);				textFeld.appendText(keyStr + ": " + valueStr + "\n");			}						flashVars.mediaurl != undefined ? Glo.bal.mediaURL = flashVars.mediaurl : 0;			flashVars.videourl != undefined ? Glo.bal.mediaURL = flashVars.videourl : 0;			flashVars.audiourl != undefined ? Glo.bal.mediaURL = flashVars.audiourl : 0;			flashVars.teaserurl != undefined ? Glo.bal.teaserURL = flashVars.teaserurl : 0;			flashVars.autoplay != undefined ? Glo.bal.autoPlay = flashVars.autoplay : 0;			flashVars.allowsmoothing != undefined ? Glo.bal.allowSmoothing = flashVars.allowsmoothing : 0;			flashVars.buffer != undefined ? Glo.bal.buffer = Number(flashVars.buffer) : 0;			flashVars.showtimecode != undefined ? Glo.bal.showTimecode = flashVars.showtimecode : 0;			flashVars.loop != undefined ? Glo.bal.loop = flashVars.loop : 0;			flashVars.controlcolor != undefined ? Glo.bal.controlColor = flashVars.controlcolor : 0;			flashVars.controlbackcolor != undefined ? Glo.bal.controlBackColor = flashVars.controlbackcolor : 0;			flashVars.playerbackcolor != undefined ? Glo.bal.playerBackColor = flashVars.playerbackcolor : 0;			flashVars.showscalingbutton != undefined ? Glo.bal.showScalingButton = flashVars.showscalingbutton : 0;			flashVars.defaultvolume != undefined ? Glo.bal.volume = (Number(flashVars.defaultvolume) / 100) : 0;			flashVars.indentimageurl != undefined ? Glo.bal.indentImageURL = flashVars.indentimageurl : 0;			flashVars.crop != undefined ? Glo.bal.crop = flashVars.crop : 0;			flashVars.controlsenabled != undefined ? Glo.bal.controlsEnabled = flashVars.controlsenabled : 0;			flashVars.hdurl != undefined ? Glo.bal.hdURL = flashVars.hdurl : 0;			flashVars.subtitlesurl != undefined ? Glo.bal.subtitlesURL = flashVars.subtitlesurl : 0;			flashVars.subtitlesposition != undefined ? Glo.bal.subtitlePosition = flashVars.subtitlesposition : 0;			flashVars.subtitlessize != undefined ? Glo.bal.subtitleSize = flashVars.subtitlessize : 0;			flashVars.subtitlescolor != undefined ? Glo.bal.subtitlesColor = flashVars.subtitlescolor : 0;			flashVars.onclick != undefined ? Glo.bal.onClick = flashVars.onclick : 0;			flashVars.treatasaudio != undefined ? Glo.bal.treatAsAudio = flashVars.treatasaudio : 0;			flashVars.playbuttonurl != undefined ? Glo.bal.playButtonUrl = flashVars.playbuttonurl : 0;			flashVars.oncomplete != undefined ? Glo.bal.jsOnComplete = flashVars.oncomplete : 0;			flashVars.onstart != undefined ? Glo.bal.jsOnStart = flashVars.onstart : 0;									//ExternalInterface.call("alert", Glo.bal.mediaURL);						if(flashVars.defaulthd == "true" && Glo.bal.hdURL != undefined){				Glo.bal.quality = "high";			} else {				Glo.bal.quality = "standard";			}			if(Glo.bal.hdURL == undefined){				Glo.bal.quality = "standard";			}						Glo.bal.controlColor.toString().indexOf("0x") == -1 ? Glo.bal.controlColor = "0x" + Glo.bal.controlColor : 0;			Glo.bal.controlBackColor.toString().indexOf("0x") == -1 ? Glo.bal.controlBackColor = "0x" + Glo.bal.controlBackColor : 0;			Glo.bal.subtitlesColor.toString().indexOf("0x") == -1 ? Glo.bal.subtitlesColor = "0x" + Glo.bal.subtitlesColor : 0;									if(flashVars.scaleiffullscreen != undefined){				Glo.bal.scaling = flashVars.scaleiffullscreen == "true" ? true : false;			}		}		private function setMediaType(){			var t = Glo.bal.mediaURL.toLowerCase();			if(t.indexOf(".mp3") != -1){				media = "audio";				if(Glo.bal.playerBackColor == undefined){					back.visible = false;				}			} else if(t.indexOf("youtube.com/watch?") != -1){				media = "youTube";			} else {				media = "video";				this.addChild(scaleBt);			}			Glo.bal.media = media;		}		public function applyScaling(){			fitToScreen(null);			scaleBt.adjust();		}				private function loopIt(event:TimerEvent){			for(i=0; i<uiElements.length; i++){				try {					uiElements[i].loopIt();				} catch (e:Error){};				if(subTitles != null){					subTitles.loopIt();				}			}		}		//		// Init Subtitles if there are any		private function initSubtitles(){			if(Glo.bal.subtitlesURL != undefined){				subTitles = new SubTitles(this);				subTitles.load(Glo.bal.subtitlesURL);				addChild(subTitles);			}		}				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Control Media		//		public function playMedia(){			switch(media){				case "video":				playVideo();				break;				case "audio":				playAudio();				break;				case "youTube":				playYouTube();				break;			}			// The Media is not loaded yet, this prevents it from flickering before the "fitOnScreen" is called			mediaObject.visible = false;			setVolume(Glo.bal.volume);			activatePlayer();			if (started == false){				started = true;				startHideTimer();			}			fitToScreen(null);		}		private function activatePlayer(){			loopTimer.start();			hideStartButton();			hideTeaser();			isPlaying = true;			isComplete = false;			control.setActive();			control.setState(isPlaying);		}		public function restartMedia(){			activatePlayer();			mediaObject.restart();			mediaObject.visible = true;		}		public function resumeMedia(){			mediaObject.resume();			isPlaying = true;			control.setState(isPlaying);		}		public function pauseMedia(){			mediaObject.setPause();			isPlaying = false;			control.setState(isPlaying);		}		public function togglePlay():void {			if(mediaObject != null){				mediaObject.togglePlay();				isPlaying = !isPlaying;				control.setState(isPlaying);			}		}		private function addTeaser(){			getStageBounds();			container.addChild(teaser);			teaser.init(this);			teaser.loadPic(Glo.bal.teaserURL);			teaser.visible = true;		}		private function hideTeaser(){			if(media != "audio" && Glo.bal.treatAsAudio != "true"){				teaser.visible = false;			} else if(Glo.bal.treatAsAudio == "true"){				theVideo.visible = false;			}		}		//		// End Control Media		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Play the Video 		// 		private function playVideo():void {			hideTeaser();			bufferWheel.fadeIn();			setMediaObject(theVideo);			theVideo.init(Glo.bal.buffer, Glo.bal.allowSmoothing, Glo.bal.mediaURL);			adjustVideoQuality();			theVideo.playVideo();		}		private function playYouTube(){			trace("Playing Youtube!");			hideTeaser();			setMediaObject(youTube);			youTube.init(Glo.bal.mediaURL);		}		private function playAudio(){			if(teaser.hasImage == false){				hideTeaser();			}			setMediaObject(theAudio);			theAudio.init(Glo.bal.mediaURL);			theAudio.playAudio();			visible = true;		}		private function setDefault():void {			isPlaying = false;			theVideo.setDefault();			control.setState(isPlaying);		}		public function setEnd():void {			trace("setEnd");			bufferWheel.fadeOut();			if(Glo.bal.loop == "true"){				restartMedia();			} else {				resetAll();				// Backwards Compatibility				callJS("computeEnd");				// The shiny new way				external.callJsOnComplete();			}		}		public function resetAll(){			fitToScreen(null);			hideError();			jsStartCalled = false;			isPlaying = false;			isComplete = true;			isSeeking = false;			addTeaser();			control.setState(isPlaying);			control.setInactive();			loopTimer.stop();			control.setProgressToZero();			stopHideTimer();			//hideUI();			Mouse.show();			if(mediaObject != null){				pauseMedia();				mediaObject.visible = false;			}			if(subTitles != null){				subTitles.showText("");			}			try {				theVideo.video.visible = false;			} catch (e:Error){};			showStartButton();		}		public function callJS($function){			try {				if(ExternalInterface.available){					ExternalInterface.call($function);				}			} catch(e:Error){};		}		private function setMediaObject(_mediaObject){			container.addChildAt(_mediaObject, 0);			mediaObject = _mediaObject;			mediaObject.contextMenu = customContextMenu.myContextMenu;		}				public function getLoadingProgress():Number {			return(mediaObject.getLoadingProgress());		}		public function getPlayingProgress():Number {			if(mediaObject.getPlayingProgress() > 0 && jsStartCalled == false){				// Backwards Compatibility				callJS("computeStart");				// The shiny new way				external.callJsOnStart();				jsStartCalled = true;				if(Glo.bal.treatAsAudio != "true"){					mediaObject.visible = true;					visible = true;				}			}			var p = mediaObject.getPlayingProgress();			//ExternalInterface.call("console.log", p);			return(p);		}		public function getTotalTime():Number {			return(mediaObject.getTotalTime());		}		public function setPlayingProgress(progressBarScale):void {			mediaObject.setPlayingProgress(progressBarScale);		}		public function seekToSecond(second):void {			mediaObject.setPlayingProgress(second / getTotalTime());		}		public function getTime(){			return(mediaObject.getTime());		}		//		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 		// Set the Video Volume		public function setVolume($volume):void {			Glo.bal.volume = $volume;			volumeTransform.volume = $volume;			if(mediaObject != null){				mediaObject.setSoundTransform(volumeTransform);			}		}		public function getVolume() {			return(Glo.bal.volume);		}		//		// The volume function for the ContextMenu		public function toggleVolume():void {			if (getVolume() > 0) {				oldVolume = getVolume();				setVolume(0);				customContextMenu.soundItem.caption = "enable Sound";			} else {				setVolume(oldVolume);				customContextMenu.soundItem.caption = "disable Sound";			}			textFeld.text = "toggleVolume";		}		//		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Adjust wether the video should use smoothing or not		//		public function toggleSmoothing():void {			if(theVideo.video.smoothing == true){				theVideo.video.smoothing = false;				customContextMenu.smoothingItem.caption = "enable Smoothing";			} else {				theVideo.video.smoothing = true;				customContextMenu.smoothingItem.caption = "disable Smoothing";			}		}		//		public function setSeeking(_isSeeking):void {			isSeeking = _isSeeking;			if(isSeeking == true){				oldVolume = getVolume();				setVolume(0);			} else {				setVolume(oldVolume);			}			//trace(getVolume());		}		//		////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 		// Handler for keyboard events: 		//		private function keyDownHandler(event:KeyboardEvent):void {			//			// If Space is pressed			if (event.keyCode == 27) {				isFullScreen = false;			}			if (event.keyCode == 32) {				togglePlay();			}		}		//		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// POSITION THE ELEMENTS		// 		private function resizeHandler(e:Event){			fitToScreen(null);		}		private function getStageBounds(){			if(fitFrame == null){				Glo.bal.stageWidth = stage.stageWidth;				Glo.bal.stageHeight = stage.stageHeight;			} else {				x = Math.round(fitFrame.x);				y = Math.round(fitFrame.y);				Glo.bal.stageWidth = fitFrame.width;				Glo.bal.stageHeight = fitFrame.height;			}		}		public function fitToScreen(e:Event):void {						getStageBounds();						bufferWheel.fit();						if(media == "audio" || Glo.bal.treatAsAudio == "true"){				try {					mediaObject.drawPlane();				} catch(e:Error){};				if(Glo.bal.stageHeight < 70){					teaser.visible = false;					control.back.visible = false;				} else {					teaser.visible = true;					control.back.visible = true;				}			}									if(isFullScreen == true){				if(Glo.bal.scaling == false){					if(mediaObject != theVideo){						 if(theVideo.meta.width < Glo.bal.stageWidth && theVideo.meta.height < Glo.bal.stageHeight){							setCentered(theVideo); 						 } else {							setExactFit(theVideo); 						 }					} else {						setCentered(mediaObject);					}				} else {					setExactFit(mediaObject);				}				control.fitToScreen(true, 0, 0, Glo.bal.stageWidth, Glo.bal.stageHeight);				setButtons(0, 0, Glo.bal.stageWidth, Glo.bal.stageHeight);			} else {				setExactFit(mediaObject);				control.fitToScreen(false, 0, 0, Glo.bal.stageWidth, Glo.bal.stageHeight);				setButtons(0, 0, Glo.bal.stageWidth, Glo.bal.stageHeight);			}						if(media == "audio" || Glo.bal.treatAsAudio == "true"){				control.fitToScreen(false, 0, 0, Glo.bal.stageWidth, Glo.bal.stageHeight);			}			if(youTube != null && youTube.stage != null){				youTube.fit();			}			setExactFit(teaser);			back.x = 0;			back.y = 0;			back.width = Glo.bal.stageWidth + 10;			back.height = Glo.bal.stageHeight + 10;			if(subTitles != null){				subTitles.fit();			}		}		private function setExactFit(target){			if(target != null){				stageRatio = Glo.bal.stageWidth / Glo.bal.stageHeight;				targetRatio = target.width / target.height;								var firstRatio:Number;				var secondRatio:Number;								if(Glo.bal.crop == "true" && isFullScreen == false){					firstRatio = stageRatio;					secondRatio = targetRatio;				} else {					firstRatio = targetRatio;					secondRatio = stageRatio;				}				//				if (firstRatio > secondRatio) {					target.width = Math.floor(Glo.bal.stageWidth);					target.scaleY = target.scaleX;				} else {					target.height = Math.floor(Glo.bal.stageHeight);					target.scaleX = target.scaleY;				}				target.width = Math.ceil(target.width);				target.height = Math.ceil(target.height);								target.x = Math.floor(Glo.bal.stageWidth/2 - target.width/2);				target.y = Math.floor(Glo.bal.stageHeight/2 - target.height/2);			}		}		private function setCentered(target){			target.scaleX = target.scaleY = 1;			target.x = Math.floor(Glo.bal.stageWidth/2 - target.width/2);			target.y = Math.floor(Glo.bal.stageHeight/2 - target.height/2);		}		private function setButtons(vidX, vidY, vidW, vidH){			startButton.x = Math.floor(vidX + vidW/2 - startButton.width / 2);			startButton.y = Math.floor(vidY + vidH/2 - startButton.height / 2);			var theGap;			if(isFullScreen != true){				theGap = gap;				scaleBt.visible = false;			} else {				theGap = margin;				if(Glo.bal.showScalingButton == "true" && started == true){					scaleBt.visible = true;				}			}			var lastY:Number = theGap;			var lastX:Number = Math.floor(Glo.bal.stageWidth - hdBt.frame.width - theGap);			if(Glo.bal.hdURL != undefined){				hdBt.x = lastX;				hdBt.y = theGap;				lastY = Math.floor(hdBt.y + hdBt.back.height + gap);			}			scaleBt.x = lastX;			scaleBt.y = lastY;			lastY = Math.floor(scaleBt.y + scaleBt.ui.height + gap);		}		//		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Switch FullScreenMode on and off 		//		public function toggleFullScreen():void {			if (isFullScreen == false) {				stage.displayState = StageDisplayState.FULL_SCREEN;			} else {				stage.displayState = StageDisplayState.NORMAL;			}		}		public function setFullScreen(){			stage.displayState = StageDisplayState.FULL_SCREEN;		}		//		// eventHandler for the display state		private function fullSreenHandler(event:FullScreenEvent):void {			if (stage.displayState == StageDisplayState.FULL_SCREEN) {				isFullScreen = true;				customContextMenu.fullScreenItem.caption = "disable FullScreen";			} else {				isFullScreen = false;				customContextMenu.fullScreenItem.caption = "enable FullScreen";			}			fitToScreen(null);		}		//		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Functions for hiding and showing the startButtonton 		// 		private function showStartButton():void {			//trace("showStartButton");			if(Glo.bal.stageHeight < 70 || Glo.bal.treatAsAudio == "true" || media == "audio"){				hideStartButton();			} else {				Mouse.show();				startButton.visible = true;				startButton.alpha = 1;			}		}		//		public function hideStartButton() {			//trace("hideStartButton");			startButton.visible = false;		}		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// Cookie functions		//		private function setQualityCookie():void {			//cookie.put("quality", {val:_qual});		}		public function setQualityAndRestart($quality):void {			Glo.bal.quality = $quality;			//trace("Set from HD Button: " + $quality);			setQualityCookie();			adjustVideoQuality();			theVideo.playVideo();			setVolume(Glo.bal.volume);		}		private function adjustVideoQuality(){			if(Glo.bal.quality == "high"){				theVideo.videoURL = Glo.bal.hdURL;			} else {				theVideo.videoURL = Glo.bal.mediaURL;			}			//trace(theVideo.videoURL);			hdBt.setText();		}		private function clearMedia(){			theVideo.close();			theAudio.close();			youTube.close();			mediaObject = null;		}		public function switchMedia($url){			resetAll();			clearMedia();			Glo.bal.mediaURL = theVideo.videoURL = $url;			setMediaType();			started = false;			playMedia();					}		//		private function onStageHandler(e:Event){			switch (e.type){				case "mouseMove":				if(mouseX > 0 && mouseX < Glo.bal.stageWidth && mouseY > 0 && mouseY < Glo.bal.stageHeight){					Glo.bal.mouseOnStage = true;					stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageHandler);					stage.addEventListener(Event.MOUSE_LEAVE, onStageHandler);					startHideTimer();				} else {					Glo.bal.mouseOnStage = false;				}				break;				case "mouseLeave":				Glo.bal.mouseOnStage = false;				stage.removeEventListener(Event.MOUSE_LEAVE, onStageHandler);				stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageHandler);				Mouse.show();								if(started == true && isComplete != true){					trace("leave!");					oldVolume = getVolume();					stopHideTimer();					hideUI();					setSeeking(false);				}				break;			}		}		//		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////		// The Timer for the fading the controls in and out in fullScreen mode 		//		// The mouseHandler		private function mouseMoveStart(event:MouseEvent) {			startHideTimer();		}		private function mouseUpHandler(event:MouseEvent) {			startHideTimer();		}		//		// Fade the UI in / out		public function showUI(){			if(Glo.bal.mouseOnStage == true && Glo.bal.controlsEnabled != "false"){				control.fadeIn();				scaleBt.fadeIn();				hdBt.fadeIn();			}		}		public function hideUI(){			if(media != "audio"){				control.fadeOut(isComplete);				scaleBt.fadeOut();				hdBt.fadeOut();			}		}		//		// start the timer		public function startHideTimer() {			if(started == true && isComplete != true){				showUI();				hideTimer.reset();				hideTimer.start();				Mouse.show();				// 				stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStart);			}		}		//		// stop the timer		public function stopHideTimer() {			hideTimer.reset();			hideTimer.stop();			try {				stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStart);				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);			} catch(e:Error){};		}		//		// hideTimer eventHandler		private function hideTimerHandler(event:TimerEvent) {			hideUI();			//			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStart, false, 0, true);		}		public function showError($log){			isPlaying = false;			isComplete = true;			isSeeking = false;			trace("Error: " + $log);			stopHideTimer();			visible = true;			hideStartButton();			control.visible = false;			error.textFeld.autoSize = "center";			error.textFeld.text = "Error: " + $log;			error.textFeld.x = -error.textFeld.width / 2;			error.y = Glo.bal.stageHeight/2 - error.height/2;			error.x = Glo.bal.stageWidth + error.width/2;			error.alpha = 0;			error.visible = true;			new GTween(error, tweenSpeed, {alpha:1, x:Glo.bal.stageWidth / 2}, {ease:Quintic.easeInOut});		}		private function hideError(){			error.visible = false;		}	}}