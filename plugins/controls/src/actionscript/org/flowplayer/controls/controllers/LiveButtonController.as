﻿/* * Author: Thomas Dubois, <thomas _at_ flowplayer org> * This file is part of Flowplayer, http://flowplayer.org * * Copyright (c) 2011 Flowplayer Ltd * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.controls.controllers {    	import org.flowplayer.controls.Controlbar;	import org.flowplayer.controls.SkinClasses;	import org.flowplayer.model.ClipEvent;		import org.flowplayer.ui.controllers.AbstractButtonController;	import org.flowplayer.ui.buttons.ButtonEvent;	import org.flowplayer.view.Flowplayer;	import flash.display.DisplayObjectContainer;	import org.flowplayer.ui.buttons.LiveTooltipButton;	import org.flowplayer.ui.buttons.TooltipButtonConfig;	import org.flowplayer.ui.buttons.LiveToggleButton;	import flash.external.*;		public class LiveButtonController extends AbstractButtonController {				public function LiveButtonController() {			super();						ExternalInterface.addCallback("sendLiveButtonType", buttonSetFromJS);		}				override protected function createWidget():void {						var dvrButton:LiveTooltipButton = new LiveTooltipButton( 												new dvrFaceClass(), 												_config as TooltipButtonConfig, 												_player.animationEngine);            setAccessible(dvrButton, "dvr");																		var liveButton:LiveTooltipButton = new LiveTooltipButton(												new liveFaceClass(), 												_config as TooltipButtonConfig, 												_player.animationEngine);            setAccessible(liveButton,  "live");						_widget = new LiveToggleButton(liveButton, dvrButton);					}				override public function get name():String {			return "Live";		}				override public function get defaults():Object {			return {				tooltipEnabled: false,				tooltipLabel: "Live",				visible: false,				enabled: true			};		}		public function get dvrFaceClass():Class {			return SkinClasses.getClass("fp.DVRButton");		}				public function get liveFaceClass():Class {			return SkinClasses.getClass("fp.LiveButton");	    }					override protected function onButtonClicked(event:ButtonEvent):void {			var buttonType:Number = (_widget as LiveToggleButton).buttonType;			if(buttonType == 2) {				ExternalInterface.call("thaitv.changeToLiveMode");			}			}				private function buttonSetFromJS(buttonType:Number):void {            (_widget as LiveToggleButton).buttonType = buttonType;        }	}}