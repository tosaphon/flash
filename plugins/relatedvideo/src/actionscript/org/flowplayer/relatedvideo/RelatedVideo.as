package org.flowplayer.relatedvideo {	import flash.display.Stage;    import flash.display.DisplayObject;    import flash.display.DisplayObjectContainer;    import flash.events.*;    import flash.external.ExternalInterface;    import org.flowplayer.controller.ResourceLoader;    import org.flowplayer.model.DisplayPluginModel;    import org.flowplayer.model.Plugin;    import org.flowplayer.model.PluginEventType;    import org.flowplayer.model.PluginModel;    import org.flowplayer.view.AbstractSprite;    import org.flowplayer.view.FlowStyleSheet;    import org.flowplayer.view.Flowplayer;    import org.flowplayer.view.Styleable;    /**     * Related Video plugin.     *     * @author api     */    public class RelatedVideo extends AbstractSprite implements Plugin, Styleable {                private var _player:Flowplayer;        private var _model:DisplayPluginModel;        private var _contentView:ContentView;        private var _leftButton:ArrowButton;        private var _rightButton:ArrowButton;        private var _html:String;        private var _urlImageList:Object;        private var _imageWidth:Number;        private var _imageHeight:Number;        private var _imageY:Number;        public function RelatedVideo() {        		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);        }                private function onAddedToStage(event:Event):void {			            //#483 only run the stage event once to prevent re-enabling unnecessarily.            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);                        if(_leftButton && _rightButton) {            		stage.addChild(_leftButton);            		stage.addChild(_rightButton);
            }		}        override protected function onResize():void {            if (!_contentView) return;            arrangeArrowButton();            _contentView.setSize(width, height);            _contentView.x = 0;            _contentView.y = 0;        }        /**         * Sets the plugin model. This gets called before the plugin         * has been added to the display list and before the player is set.         * @param plugin         */        public function onConfig(plugin:PluginModel):void {            _model = plugin as DisplayPluginModel;            if (plugin.config) {                				_urlImageList = plugin.config.urlList;                	_html = plugin.config.warningText;                	_imageWidth = plugin.config.imageWidth;                	_imageHeight = plugin.config.imageHeight;                	_imageY = plugin.config.imageY;                	_html = plugin.config.html;            }        }        /**         * Sets the Flowplayer interface. The interface is immediately ready to use, all         * other plugins have been loaded an initialized also.         * @param player         */        public function onLoad(player:Flowplayer):void {            log.info("set player");            _player = player;                        createContentView();            createCloseButton();                        _model.dispatchOnLoad();        }        /**         * Sets the HTML content.         * @param htmlText         */        [External]        public function set html(htmlText:String):void {            log.debug("set hetml()");            _contentView.html = htmlText;        }        public function get html():String {            log.debug("get hetml()");            return _contentView.html;        }        /**         * Sets style properties.         */        public function css(styleProps:Object = null):Object {            var result:Object = _contentView.css(styleProps);            return result;        }        public function get style():FlowStyleSheet {            return _contentView ? _contentView.style : null;        }        public function set style(value:FlowStyleSheet):void {            _contentView.style = value;        }        private function createStyleSheet(cssText:String = null):FlowStyleSheet {            var styleSheet:FlowStyleSheet = new FlowStyleSheet("#content", cssText);            // all root style properties come in config root (backgroundImage, backgroundGradient, borderRadius etc)            addRules(styleSheet, _model.config);            // style rules for the textField come inside a style node            addRules(styleSheet, _model.config.style);            return styleSheet;        }        private function addRules(styleSheet:FlowStyleSheet, rules:Object):void {            var rootStyleProps:Object;            for (var styleName:String in rules) {                log.debug("adding additional style rule for " + styleName);                if (FlowStyleSheet.isRootStyleProperty(styleName)) {                    if (! rootStyleProps) {                        rootStyleProps = new Object();                    }                    log.debug("setting root style property " + styleName + " to value " + rules[styleName]);                    rootStyleProps[styleName] = rules[styleName];                } else {                    styleSheet.setStyle(styleName, rules[styleName]);                }            }            styleSheet.addToRootStyle(rootStyleProps);        }        private function createContentView(cssText:String = null, closeImage:DisplayObject = null):void {            log.debug("creating content view");            _contentView = new ContentView(_player);            _contentView.loadAllImages(_urlImageList, _imageWidth, _imageHeight, _imageY);            _contentView.drawImageContainerMask();            log.debug("callign onResize");            onResize(); // make it correct size before adding to display list (avoids unnecessary re-arrangement)//            log.debug("setting stylesheet " + cssText);            _contentView.style = createStyleSheet(cssText);//            log.debug("setting html");            _contentView.html = _html;            addChild(_contentView);        }        public override function set alpha(value:Number):void {            super.alpha = value;            if (!_contentView) return;            _contentView.alpha = value;        }        private function onMouseOver(event:MouseEvent):void {            if (!_model) return;            if (_contentView.redrawing) return;            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onMouseOver");        }        private function onMouseOut(event:MouseEvent):void {            if (!_model) return;            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onMouseOut");        }        private function onClick(event:MouseEvent):void {            if (!_model) return;            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onClick");        }        public function getDefaultConfig():Object {            return { top: 10, left: '50%', width: '95%', height: 50, opacity: 0.9, borderRadius: 10, backgroundGradient: 'low' };        }        public function animate(styleProps:Object):Object {            return _contentView.animate(styleProps);        }        public function onBeforeCss(styleProps:Object = null):void {        }        public function onBeforeAnimate(styleProps:Object):void {        }        private function arrangeArrowButton():void {            if (_leftButton && _rightButton) {            		_leftButton.x = 5;            		_leftButton.y = _rightButton.y = this.y +  _contentView.getArrowPos() - (_rightButton.height /2 );            		_rightButton.x = width - _rightButton.width - 5;            }        }        private function createCloseButton():void {            _leftButton = new ArrowButton(true);            _leftButton.addEventListener(MouseEvent.CLICK, onArrowLeftClicked);                        _rightButton = new ArrowButton(false);            _rightButton.addEventListener(MouseEvent.CLICK, onArrowRightClicked);                    }        private function onArrowLeftClicked(event:MouseEvent):void {            _contentView.moveImage(-100);        }                private function onArrowRightClicked(event:MouseEvent):void {            _contentView.moveImage(100);        }    }}