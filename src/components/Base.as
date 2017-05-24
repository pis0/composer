package components
{

    import com.assukar.airong.utils.Utils;

    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    import flash.utils.clearInterval;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import flash.utils.setInterval;

    import mx.containers.HDividedBox;
    import mx.containers.VDividedBox;
    import mx.controls.Alert;
    import mx.controls.ColorPicker;
    import mx.controls.ComboBase;
    import mx.controls.MovieClipSWFLoader;
    import mx.controls.TextArea;
    import mx.controls.Tree;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;
    import mx.graphics.SolidColor;

    import remote.LocalServerSocket;

    import spark.components.Application;
    import spark.components.Button;
    import spark.components.CheckBox;
    import spark.components.Group;
    import spark.components.HSlider;
    import spark.components.NumericStepper;
    import spark.components.Scroller;
    import spark.components.TextInput;
    import spark.components.ToggleButton;
    import spark.components.VGroup;
    import spark.components.supportClasses.Range;
    import spark.primitives.Rect;

    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;

    public class Base extends Application
    {
        static private var APPLICATION_DOMAIN:ApplicationDomain = ApplicationDomain.currentDomain;

        [Embed(source="../../lib/assets/playpauseicon.png")]
        static private var playpauseicon:Class;

        static private const DEFAULT_DEFINITION:String = "starling.core::Starling";
        static private const DEFAULT_METHODS:String = "current,stage";

        public function start(comp:Object):void
        {
            canvas.source = comp;
            canvas.scaleContent = false;

            stage.color = 0x0000;
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3DCreate);
        }

        private var definition:String;
        private var methods:String;

        private function context3DCreate(e:Event):void
        {
            container.removeElement(canvas);
            this.x = orientation == 1 ? 1024 : 768;
            container.percentWidth = orientation == 1 ? 34 : 50;
        }

        private function refresh(definition:String, methods:String = null):void
        {

            //TODO to delete
            Utils.wraplog("refresh: " + definition + ", " + methods);

            LocalServerSocket.ME.send([definition, methods]);
            return;


            clearLayer();

            var clazz:Object = loader.contentLoaderInfo.applicationDomain.getDefinition(definition);
            if (methods && methods.length)
            {
                var methodsTemp:Array = methods.split(",");
                while (methodsTemp.length) clazz = clazz[methodsTemp.shift()];
            }
            var list0:XML = parseComp(clazz, null);
            //for (var key:String in childList) trace(key, childList[key]);
            tree0.dataProvider = list0;
            tree0.labelField = "@name";
        }

        public function Base()
        {
            addEventListener(FlexEvent.CREATION_COMPLETE, init, false, 0, true);
        }

        private function init(e:FlexEvent):void
        {
            removeEventListener(FlexEvent.CREATION_COMPLETE, init);
            addEventListener(Event.ADDED_TO_STAGE, hasStage, false, 0, true);
        }

        private var refreshContainer:Group;
        private var refreshDefinitionText:TextArea;
        private var refreshMethodsText:TextArea;
        private var refreshBtn:Button;
        private var playPauseBtn:ToggleButton;
        private var editorScroller:Scroller
        private var editorContainer:Group;
        private var editorStepSize:TextInput;
        private var canvas:MovieClipSWFLoader;
        private var container:HDividedBox
        private var loader:Loader;

        private var cursorPosition:TextArea;

        private function hasStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, hasStage);

            //TODO to fix
//			// loader
//			load();

            //TODO to delete
            createDisplay();

            // server
            LocalServerSocket.ME = new LocalServerSocket();
            LocalServerSocket.ME.start();

        }

        private function createDisplay():void
        {
            // container
            container = new HDividedBox();
            container.percentWidth = container.percentHeight = 100;

            addElement(container);

            // left
            canvas = new MovieClipSWFLoader();
            canvas.width = orientation == 1 ? 1024 : 768;
            canvas.height = orientation == 1 ? 768 : 1024;

            container.addElement(canvas);

            // middle

            var box0:VDividedBox = new VDividedBox();
            box0.percentWidth = 25;
            box0.percentHeight = 100;

            refreshContainer = new Group();
            refreshContainer.percentWidth = 100;
            refreshContainer.percentHeight = 15;

            refreshDefinitionText = new TextArea();
            refreshDefinitionText.width = 300;
            refreshDefinitionText.height = 20;
            refreshDefinitionText.x = 4;
            refreshDefinitionText.y = 4;
            refreshDefinitionText.text = DEFAULT_DEFINITION;

            refreshMethodsText = new TextArea();
            refreshMethodsText.width = 300;
            refreshMethodsText.height = 20;
            refreshMethodsText.x = 4;
            refreshMethodsText.y = 28;
            refreshMethodsText.text = DEFAULT_METHODS;

            refreshBtn = new Button();
            refreshBtn.width = 80;
            refreshBtn.height = 40;
            refreshBtn.x = 4;
            refreshBtn.y = 60;
            refreshBtn.label = "APPLY";

            playPauseBtn = new ToggleButton();
            playPauseBtn.width = 40;
            playPauseBtn.height = 40;
            playPauseBtn.x = 84;
            playPauseBtn.y = 60;

            cursorPosition = new TextArea();
            cursorPosition.width = 300;
            cursorPosition.height = 20;
            cursorPosition.x = 4;
            cursorPosition.y = 60 + 40 + 14;
            cursorPosition.text = "global( 0, 0 ) - local( 0, 0 )";
            cursorPosition.editable = false;
            cursorPosition.selectable = false;
            cursorPosition.alpha = 0.6;

            refreshContainer.addElement(refreshDefinitionText);
            refreshContainer.addElement(refreshMethodsText);
            refreshContainer.addElement(refreshBtn);
            refreshContainer.addElement(playPauseBtn);
            refreshContainer.addElement(cursorPosition);

            tree0 = new Tree();
            tree0.percentWidth = 100;
            tree0.percentHeight = 85;
            tree0.showRoot = false;
            tree0.id = "tree0";

            box0.addElement(refreshContainer);
            box0.addElement(tree0);
            container.addElement(box0);

            // right
            var box1:VDividedBox = new VDividedBox();
            box1.percentWidth = 25;
            box1.percentHeight = 100;

            tree1 = new Tree();
            tree1.percentWidth = 100;
            tree1.percentHeight = 60;
            tree1.showRoot = false;
            tree1.id = "tree1";

            editorContainer = new VGroup();
            editorContainer.percentWidth = 100;
            editorContainer.percentHeight = 40;

            //text = new TextArea();
            //text.percentWidth = 100;
            //text.height = 40;
            //text.editable = false;

            //editorContainer.addElement(text);
            //editorContainer.addElement(editorStepSize);

            container.addElement(box1);

            box1.addElement(tree1);

            editorStepSize = new TextInput();
            editorStepSize.width = 80;
            editorStepSize.height = 20;
            //editorStepSize.y = text.height + 30 + 5;
            editorStepSize.text = "1.0";

            box1.addElement(editorStepSize);

            //TODO to review
            //box1.addElement(editorContainer);
            editorScroller = new Scroller();
            editorScroller.percentWidth = 100;
            editorScroller.percentHeight = 40;
            editorScroller.viewport = editorContainer;

            box1.addElement(editorScroller);

            // events
            tree0.doubleClickEnabled = true;
            tree0.addEventListener(ListEvent.CHANGE, treeChange);
            tree0.addEventListener(MouseEvent.DOUBLE_CLICK, drawObject);

            tree1.addEventListener(ListEvent.CHANGE, treeChange);
            tree1.allowMultipleSelection = true;

            refreshBtn.addEventListener(MouseEvent.CLICK, refreshBtnClick);
            refreshBtn.enabled = true;

            playPauseBtn.addEventListener(MouseEvent.CLICK, playPauseBtnClick);
            playPauseBtn.enabled = true;

            // skin
            setSkinColor();
        }

        //private var layer:Component = null;
        private var layer:Sprite = null;
        private var starlingg:Object = null;

        private function clearLayer():void
        {
            if (!starlingg) starlingg = loader.contentLoaderInfo.applicationDomain.getDefinition(DEFAULT_DEFINITION)["current"];

            if (layer)
            {
                layer.removeChildren(0, -1, true);
                layer.dispose();
                if (Starling(starlingg).stage.contains(layer)) Starling(starlingg).stage.removeChild(layer);
            }
        }

        private function drawObject(e:MouseEvent):void
        {
            try
            {
                clearLayer();

                //layer = new Component();
                layer = new Sprite();
                layer.name = "INDIVIDUAL_LAYER";

                //var layerBg:Quad = new Quad(768, 1024, 0xe1e1e1);
                var layerBg:Quad = orientation == 1 ? new Quad(1024, 768, 0xe1e1e1) : new Quad(768, 1024, 0xe1e1e1);
                layerBg.alpha = 0.95;
                layer.addChild(layerBg);
                layer.touchable = true;

                Starling(starlingg).stage.addChild(layer);

                var clazz:Object = loader.contentLoaderInfo.applicationDomain.getDefinition(getQualifiedClassName(dob));
                layer.addChild((new clazz())["draw"]());

                var list0:XML = parseComp(layer.getChildAt(1), null);
                tree0.dataProvider = list0;
                tree0.labelField = "@name";
                tree0.invalidateList();

            }
            catch (e:Error)
            {
                Alert.show(e.message, "", 4, tree0);
                clearLayer();
            }
        }

        private function setSkinColor():void
        {
            this.setStyle("backgroundColor", 0x212121);
            this.setStyle("contentBackgroundColor", 0x212121);
            this.setStyle("chromeColor", 0xe4e4e4);
            this.setStyle("color", 0x999999);
            this.setStyle("selectionColor", 0xcccccc);
            this.setStyle("focusColor", 0x666666);
            this.setStyle("rollOverColor", 0x999999);
            this.setStyle("symbolColor", 0x000000);
            this.setStyle("focusedTextSelectionColor", 0x666666);
            this.setStyle("unfocusedTextSelectionColor", 0x999999);
            this.setStyle("inactiveTextSelectionColor", 0x333333);
            this.styleManager.getStyleDeclaration("spark.components.Button").setStyle("color", 0x000000);

            playPauseBtn.setStyle("icon", playpauseicon);

            cursorPosition.setStyle("borderVisible", false);
            cursorPosition.setStyle("color", 0x888888);
        }

        private var orientation:int;

        private function load():void
        {
            var configLoader:URLLoader = new URLLoader();
            configLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
            configLoader.addEventListener(Event.COMPLETE, function (e:Event):void
            {
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (ioe:IOErrorEvent):void
                {
                    //Alert.show(ioe.text);
                    Alert.show(ioe.text, "", 4, tree0);
                });

                orientation = int(configLoader.data["orientation"]);
                createDisplay();

                loader.load(new URLRequest(configLoader.data["path"]), new LoaderContext(false, APPLICATION_DOMAIN));

            });
            configLoader.load(new URLRequest("_COMPOSER.config"));

        }

        private function loaderComplete(e:Event):void
        {
            start(LoaderInfo(e.currentTarget).content);
        }

        private function refreshBtnClick(e:MouseEvent):void
        {

            editorContainer.removeAllElements();
            Clipboard.generalClipboard.clear();

            tree1.dataProvider = null;
            tree1.invalidateList();

            refreshBtn.enabled = false;
            try
            {
                refresh(refreshDefinitionText.text, refreshMethodsText.text);
            }
            catch (err:Error)
            {
                //Alert.show(err.message);
                Alert.show(err.message, "", 4, tree0);
            }
            refreshBtn.enabled = true;
        }

        private function playPauseBtnClick(e:MouseEvent):void
        {
            try
            {
                var starling:Object = loader.contentLoaderInfo.applicationDomain.getDefinition(DEFAULT_DEFINITION)["current"];
                starling[String(playPauseBtn.selected ? "stop" : "start")]();
            }
            catch (e:Error)
            {
                //Alert.show(e.message);
                Alert.show(e.message, "", 4, tree0);
            }
        }

        private function getClassName(o:*):String
        {
            if (o == null) return "null";
            try
            {
                return String(Class(loader.contentLoaderInfo.applicationDomain.getDefinition(getQualifiedClassName(o)))).replace("class ", "");
            }
            catch (err:Error)
            {
                //Alert.show(err.message);
            }
            return "null";
        }

        private var childList:Dictionary = new Dictionary();

        private function parseComp(dob:Object, result:XML = null):XML
        {
            var namee:String;
            var className:String = getClassName(dob);
            namee = (dob.name ? dob.name : className != "null" ? className : String(dob)) + "." + String(int.MAX_VALUE * Math.random()).split(".")[0];

            childList[namee] = dob;

            if (!result) result = <data></data>;
            var nodeTemp:XML = <node></node>;
            nodeTemp.@name = namee;
            result = result.appendChild(nodeTemp);

            if (dob.hasOwnProperty("numChildren"))
            {
                var i:int, len:int = dob.numChildren;
                for (i = 0; i < len; i++) parseComp(dob.getChildAt(i), nodeTemp);
            }

            return result;
        }

        private var text:TextArea;
        private var tree0:Tree;
        private var tree1:Tree;

        private var node0:XML;
        //private var node1:XML;
        private var node1:Array;

        private var dob:Object;

        private function treeChange(e:ListEvent):void
        {
            //text.text = "";
            canvas.removeEventListener(Event.ENTER_FRAME, canvasChange);

            editorContainer.removeAllElements();
            //editorContainer.removeChildren(1, int.MAX_VALUE);
            Clipboard.generalClipboard.clear();

            var target:Tree = Tree(e.currentTarget);

            switch (target.id)
            {
                case "tree0":
                    node0 = target.selectedItem as XML;
                    dob = childList[String(node0.@name)];

                    if (dob.hasOwnProperty("unflatten")) dob["unflatten"]();

                    //
                    tree1.dataProvider = describeType(dob).elements().( //
                            (//
                            name() == "accessor" && ( //
                                    //
                                    // native
                                    @declaredBy == "flash.text::TextField"  //
                                    || @declaredBy == "flash.text::StageText"  //
                                    || @declaredBy == "flash.display::DisplayObject"  //
                                    //
                                    // statling
                                    || @declaredBy == "starling.display::DisplayObject"  //
                                    || @declaredBy == "starling.display::DisplayObjectContainer" //
                                    || @declaredBy == "starling.display::Quad" //
                                    || @declaredBy == "starling.display::Image" //
                                    || @declaredBy == "starling.display::Sprite" //
                                    || @declaredBy == "starling.display::Sprite3D" //
                                    || @declaredBy == "starling.text::TextField" //
                                    || @declaredBy == "starling.extensions::ParticleSystem" //
                                    || @declaredBy == "starling.extensions::PDParticleSystem" //
                                    //
                                    // custom
                                    || @declaredBy == "com.assukar.view.starling::Component" //
                                    || @declaredBy == "com.assukar.view.starling::EffectableComponent" //
                                    || @declaredBy == "com.assukar.view.starling::AssukarTextField" //
                                    || @declaredBy == "com.assukar.view.starling::AssukarMovieClip" //
                                    || @declaredBy == "com.assukar.view.starling::AssukarMovieBytes" //
                            ) //
                            && @access == "readwrite") // || name() == "variable" //
                            ).( //
                    @type == "uint" //
                    || @type == "int" //
                    || @type == "Number" //
                    || @type == "Boolean" //
                    || @type == "String" //
                            ).(@name != "name"); //
                    //

                    tree1.visible = false;
                    updatePropsList();

                    tree1.labelField = "@name";

                    // global / local positions
                    if (dob is DisplayObject)
                    {
                        if (DisplayObject(dob).hasEventListener(TouchEvent.TOUCH)) DisplayObject(dob).removeEventListener(TouchEvent.TOUCH, updatePositionsDisplay);
                        dob.addEventListener(TouchEvent.TOUCH, updatePositionsDisplay);
                    }

                    break;
                case "tree1":

                    //node1 = target.selectedItem as XML;
                    node1 = target.selectedItems as Array;

                    parsePropsToObjectAndCopy();

                    //editorContainer.addElement(editorStepSize);

                    //if (target.selectedItems.length >= 2 || !node1) return;

                    //editorContainer.removeAllElements();

                    for (var i:int = 0; i < target.selectedItems.length; i++)
                    {

                        //TODO to review
                        //editorContainer.addElement(text);
                        //editorContainer.addElement(editorStepSize);
                        var editorElement:Group = new Group();
                        var rect:Rect = new Rect();
                        rect.percentWidth = rect.percentHeight = 100;
                        rect.fill = new SolidColor(0x333333, 1.0);
                        editorElement.addElement(rect);

                        var text:TextArea = new TextArea();
                        text.percentWidth = 100;
                        text.height = 20;
                        text.editable = false;
                        text.selectable = false;
                        text.setStyle("borderVisible", false);
                        text.setStyle("contentBackgroundColor", 0x333333);

                        editorElement.addElement(text);

                        //var editorStepSize:TextInput = new TextInput();
                        //editorStepSize.width = 80;
                        //editorStepSize.height = 20;
                        //editorStepSize.y = text.height + 30 + 5;
                        //editorStepSize.text = "1.0";

                        //editorElement.addElement(editorStepSize);

                        //editorContainer.addElement(editorElement);
                        //editorContainer.addElement(editorStepSize);
                        editorContainer.addElement(editorElement);

                        //var nodeName:String = String(node1.@name).split(":")[0];
                        var nodeName:String = String(node1[i].@name).split(":")[0];
                        //text.text = nodeName + ":    " + node1.@type + "\nvalue:    " + (nodeName == "color" ? "0x" + uint(dob[nodeName]).toString(16) : fixPropName(dob[nodeName]));
                        text.text = nodeName + ":    " + node1[i].@type + "\nvalue:    " + (nodeName == "color" ? "0x" + uint(dob[nodeName]).toString(16) : fixPropName(dob[nodeName]));
                        //

                    }

                    canvas.addEventListener(Event.ENTER_FRAME, canvasChange);

                    break;
                default:
                    //text.text = node1.@name;
                    break;
            }

        }

        private function updatePositionsDisplay(e:TouchEvent):void
        {
            var t:Touch = e.getTouch(dob as DisplayObject);
            var l:Point;
            if (t)
            {
                l = t.getLocation(dob as DisplayObject);
                cursorPosition.text = "global( " + int(t.globalX) + ", " + int(t.globalY) + " ) - local( " + int(l.x) + ", " + int(l.y) + " )";
                cursorPosition.alpha = 1.0;
            }
            else
            {
                cursorPosition.text = "global( 0, 0 ) - local( 0, 0)";
                cursorPosition.alpha = 0.6;
            }
        }

        private function canvasChange(e:Event):void
        {

            //if (editorContainer.numElements <= 1)
            for (var i:int = 0; i < editorContainer.numElements; i++)
            {

                var g:Group = editorContainer.getElementAt(i) as Group;

                //if (editorContainer.numElements <= 2)
                //if (g)
                //if (g.numElements <= 1)
                if (g.numElements <= 2)
                {

                    var text:TextArea = g.getChildAt(0) as TextArea;
                    //var text:TextArea = editorContainer.getChildAt(0) as TextArea;

                    //if (text && text.text.length && node1 && dob)
                    if (text && text.text.length && node1[i] && dob)
                    {
                        //var nodeName:String = String(node1.@name).split(":")[0];
                        var nodeName:String = String(node1[i].@name).split(":")[0];

                        //text.text = nodeName + ":    " + node1.@type + "\nvalue:    " + (nodeName == "color" ? "0x" + uint(dob[nodeName]).toString(16) : fixPropName(dob[nodeName]));
                        text.text = nodeName + ":    " + node1[i].@type; // + "\nvalue:    " + (nodeName == "color" ? "0x" + uint(dob[nodeName]).toString(16) : fixPropName(dob[nodeName]));

                        //var editorStepSize:TextInput = new TextInput();
                        //editorStepSize.width = 80;
                        //editorStepSize.height = 20;
                        //editorStepSize.y = text.height + 30 + 5;
                        //editorStepSize.text = "1.0";

                        //g.addElement(editorStepSize);

                        var input:*;

                        //if (node1.@type == "Number")
                        if (node1[i].@type == "Number")
                        {
                            if (nodeName == "alpha")
                            {
                                input = new HSlider();
                                HSlider(input).minimum = 0;
                                HSlider(input).maximum = 1;
                                HSlider(input).stepSize = 0.05;
                                HSlider(input).width = 140;
                            }
                            else
                            {
                                input = new NumericStepper();
                                NumericStepper(input).minimum = -int.MAX_VALUE;
                                NumericStepper(input).maximum = int.MAX_VALUE;
                                //NumericStepper(input).stepSize = String(nodeName).search("scale") != -1 || String(nodeName).search("rotation") != -1 ? 0.01 : 1.0;
                                NumericStepper(input).stepSize = Number(editorStepSize.text);
                            }

                            Range(input).value = Number(dob[nodeName]);
                        }
                        //else if (node1.@type == "int")
                        else if (node1[i].@type == "int")
                        {
                            input = new NumericStepper();
                            NumericStepper(input).minimum = -int.MAX_VALUE;
                            NumericStepper(input).maximum = int.MAX_VALUE;
                            NumericStepper(input).stepSize = 1.0;

                            Range(input).value = Number(dob[nodeName]);
                        }
                        //else if (node1.@type == "uint")
                        else if (node1[i].@type == "uint")
                        {
                            if (nodeName == "color")
                            {
                                input = new ColorPicker();
                                ColorPicker(input).showTextField = true;
                                ColorPicker(input).selectedColor = uint(dob[nodeName]);
                            }
                            else
                            {
                                input = new NumericStepper();
                                NumericStepper(input).minimum = 0;
                                NumericStepper(input).maximum = int.MAX_VALUE;
                                NumericStepper(input).stepSize = 1.0;

                                Range(input).value = Number(dob[nodeName]);
                            }
                        }
                        //else if (node1.@type == "Boolean")
                        else if (node1[i].@type == "Boolean")
                        {
                            input = new CheckBox();
                            CheckBox(input).selected = Boolean(dob[nodeName]);
                        }
                        //else if (node1.@type == "String")
                        else if (node1[i].@type == "String")
                        {
                            input = new TextInput();
                            TextInput(input).width = 250;
                            TextInput(input).height = 40;
                            TextInput(input).text = String(dob[nodeName]);
                        }
                        else trace("no valid type");

                        if (!input) return;

                        input.y = text.height + 5;

                        //editorStepSize.visible = false;
                        //if (input is NumericStepper)
                        //{
                        //editorStepSize.visible = true;
                        //g.addElement(editorStepSize);
                        //}

                        //input["name"] = editorStepSize["name"] = nodeName;
                        input["name"] = nodeName;

                        input.addEventListener(Event.CHANGE, function (e:Event):void
                        {
                            try
                            {
                                if (e.currentTarget is Range)
                                {
                                    if (Number(editorStepSize.text)) e.currentTarget["stepSize"] = Number(editorStepSize.text);

                                    //dob[nodeName] = input["value"];
                                    dob[e.currentTarget.name] = e.currentTarget["value"];
                                    updatePropsList();
                                    parsePropsToObjectAndCopy();

                                    //if (e.currentTarget is NumericStepper) NumericStepper(input).textDisplay.text = String(dob[nodeName]);
                                    if (e.currentTarget is NumericStepper) NumericStepper(e.currentTarget).textDisplay.text = String(dob[e.currentTarget.name]);
                                }
                                else if (e.currentTarget is CheckBox)
                                {
                                    //dob[nodeName] = CheckBox(input).selected;
                                    dob[e.currentTarget.name] = CheckBox(e.currentTarget).selected;
                                    updatePropsList();
                                    parsePropsToObjectAndCopy();
                                }
                                else if (e.currentTarget is TextInput)
                                {
                                    //dob[nodeName] = TextInput(input).text;
                                    dob[e.currentTarget.name] = TextInput(e.currentTarget).text;
                                    updatePropsList();
                                    parsePropsToObjectAndCopy();
                                }
                                else if (e.currentTarget is ComboBase)
                                {
                                    //dob[nodeName] = ColorPicker(input).selectedColor;
                                    dob[e.currentTarget.name] = ColorPicker(e.currentTarget).selectedColor;
                                    updatePropsList();
                                    parsePropsToObjectAndCopy();
                                }
                            }
                            catch (err:Error)
                            {
                                //Alert.show(err.message);
                                trace(err.message);
                            }

                        });

                        //editorContainer.addElement(input);
                        if (!g.containsElement(input)) g.addElement(input);

                    }
                }
            }

            //editorContainer.invalidateSize();
            //editorScroller.invalidateDisplayList();

        }

        private var updatePropsListDelay:uint;
        private const UPDATE_PROPS_LIST_DELAY_TIME:Number = 100;

        private function updatePropsList():void
        {
            clearInterval(updatePropsListDelay);
            updatePropsListDelay = setInterval(function ():void
            {
                var tempNodeName:String;
                for each (var node:XML in tree1.dataProvider)
                {
                    tempNodeName = String(node.@name).split(":")[0];

                    if (tempNodeName == "color")
                    {
                        node.@name = tempNodeName + ": 0x" + uint(dob[tempNodeName]).toString(16);
                    }
                    //else node.@name = fixPropName(tempNodeName + ": " + dob[tempNodeName]);
                    else node.@name = tempNodeName + ": " + fixPropName(String(dob[tempNodeName]));
                    delete node.metadata;
                }
                tree1.invalidateList();
                clearInterval(updatePropsListDelay);

                tree1.visible = true;

            }, UPDATE_PROPS_LIST_DELAY_TIME);

        }

        private function fixPropName(value:String):String
        {
            if (!value) return "null";
            value = value.replace(/[\u000d\u000a\u0008\u0020]+/g, " ");
            return value.length >= 30 ? value.slice(0, 30) + "..." : value;
        }

        private function parsePropsToObjectAndCopy():void
        {
            var temp:Array;
            var result:String = "{";
            var value:String;
            var valueTemp:*;
            var flag:Boolean = false;
            for each (var item:XML in tree1.selectedItems)
            {
                if (flag) result += ", ";
                temp = item.@name.split(": ");
                valueTemp = dob[temp[0]];
                value = valueTemp is String ? JSON.stringify(valueTemp) : String(valueTemp);
                result += temp[0] + ": " + value
                flag = true;
            }
            result += "}";

            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, result);
        }

    }
}

