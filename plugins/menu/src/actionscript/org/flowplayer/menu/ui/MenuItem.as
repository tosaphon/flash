/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2010 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.menu.ui {
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormatAlign;
    import flash.text.Font;
    import flash.text.StyleSheet;

    import fp.TickMark;

    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.menu.*;
    import org.flowplayer.ui.buttons.AbstractButton;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.Flowplayer;

    public class MenuItem extends AbstractButton {
        private var _text:TextField;
        private var _tickMark:DisplayObject;
        private var _mask:Sprite;
        private var _image:DisplayObject;
        private var _player:Flowplayer;

        private var _buffer:int = 10;
        
        //embed font
		[Embed(source="../cmprasanmit.ttf", fontName = "cmprasanmit", fontFamily="cmprasanmit", mimeType="application/x-font-truetype", 
    embedAsCFF="false", unicodeRange="U+0020-007E,U+0E01-0E5B")] 
        public var cmprasanmitFont:Class;

        public function MenuItem(player:Flowplayer, config:MenuItemConfig, animationEngine:AnimationEngine) {
            _player = player;
            super(config, animationEngine);
            
            Font.registerFont(cmprasanmitFont);
        }

        override protected function onClicked(event:MouseEvent):void {
            if (! itemConfig.toggle) return;
            if (_tickMark.parent) {
                removeChild(_tickMark);
            } else {
                addChild(_tickMark);
            }
        }

        public function set selected(selected:Boolean):void {
//            if (! _tickMark) return;
            if (selected && ! _tickMark.parent) {
                addChild(_tickMark);
            } else if (_tickMark.parent) {
                removeChild(_tickMark);
            }
        }

        public function get selected():Boolean {
            return _tickMark.parent != null;
        }

        override protected function createFace():DisplayObjectContainer {
            return new MenuItemFace(itemConfig.color, itemConfig.alpha);
        }

        override protected function childrenCreated():void {
            if (itemConfig.toggle) {
                _tickMark = new TickMark();
                if (itemConfig.selected) {
                    addChild(_tickMark);
                }
            }
            
            var style:StyleSheet = new StyleSheet();
			style.setStyle(".menuItem", {fontFamily: "cmprasanmit", fontSize: 18, fontWeight:"bold"});
            _text = addChild(TextUtil.createTextField(false, null, 12, true)) as TextField;
            _text.embedFonts = true;
            _text.selectable = false;
            _text.type = TextFieldType.DYNAMIC;
            _text.textColor = config.fontColor;
            //_text.textColor = 0x3399FF;
            _text.blendMode = BlendMode.LAYER;
            _text.autoSize = TextFieldAutoSize.CENTER;
            _text.wordWrap = true;
            _text.multiline = true;
            _text.antiAliasType = AntiAliasType.ADVANCED;
            _text.condenseWhite = true;
            _text.defaultTextFormat.bold = true;
            _text.defaultTextFormat.align = TextFormatAlign.CENTER;
            
			_text.styleSheet = style;
            _text.htmlText = "<p class='menuItem'>" + itemConfig.label + "</p>";
            addChild(_text);

            if (config.imageUrl) {
                loadImage();
            }
            
        }

        private function loadImage():void {
            var loader:ResourceLoader = _player.createLoader();
            loader.addBinaryResourceUrl(config.imageUrl);
            loader.load(null, function(loader:ResourceLoader):void {
                log.debug("image loaded from " + config.imageUrl);
                _image = addChild(loader.getContent() as DisplayObject) as DisplayObject;
                onResize();
            });
        }

        private function addMask():void {
            log.debug("addMask()");
            _mask = addChild(new Sprite()) as Sprite;
            _mask.blendMode = BlendMode.ERASE;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            face.width = width;
            face.height = height;
            //_text.width = _text.textWidth + 10;
            //#498 set initial text width to the max item width
            _text.width = face.width - _buffer;
            _text.height = _text.textHeight + 6;

            if (_image) {
                _image.x = 10;
                _image.y = 5;
                _image.height = height - 10;
                _image.scaleX = _image.scaleY;
                //#498 resize the label text if an image is set.
                _text.width = _text.width - _image.width - _buffer;
            }

            if (itemConfig.toggle) {
                _tickMark.height = 9;
                _tickMark.scaleX = _tickMark.scaleY;
                Arrange.center(_tickMark, 0, height);
                //_tickMark.y = _tickMark.y - 2; // adjust it a bit
                _tickMark.x = _image ? (_image.x + _image.width) : _buffer;
                //#498 resize the label text if a tickmark is configured.
                _text.width = _text.width - _tickMark.width;
                _text.x = _tickMark.x + _tickMark.width + 7;
                Arrange.center(_text, 0, height);
            } else {

                _text.x = _image ? (_image.x + _image.width + _buffer) : _buffer + 5;
                Arrange.center(_text,  0, height);
            }
        }

        override protected function doEnable(enabled:Boolean):void {
            _text.textColor = enabled ? config.fontColor: config.disabledColor;
            _text.alpha = enabled ? config.fontAlpha : config.disabledAlpha;
            if (_tickMark) {
                GraphicsUtil.transformColor(_tickMark, enabled ? config.fontColorRGBA : config.disabledRGBA);
            }
        }

        override protected function get disabledDisplayObject():DisplayObject {
            return null;
        }

        private function get itemConfig():MenuItemConfig {return _config as MenuItemConfig;}

    }
}