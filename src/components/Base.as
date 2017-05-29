package components
{

    import com.assukar.airong.utils.composer.ComposerDataAction;
    import com.assukar.airong.utils.composer.ComposerDataObject;

    import controller.LocalServerSocketController;

    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import mx.containers.HDividedBox;
    import mx.containers.VDividedBox;
    import mx.controls.Alert;
    import mx.controls.ColorPicker;
    import mx.controls.ComboBase;
    import mx.controls.TextArea;
    import mx.controls.Tree;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;
    import mx.graphics.SolidColor;

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

    public class Base extends Application
    {
        [Embed(source="../../lib/assets/playpauseicon.png")]
        static private var playpauseicon:Class;

        static private const DEFAULT_DEFINITION:String = "starling.core::Starling";
        static private const DEFAULT_METHODS:String = "current,stage";

        private var definition:String;
        private var methods:String;

        private function refresh(definition:String, methods:String = null):void
        {
            var cdo:ComposerDataObject = new ComposerDataObject();
            cdo.action = ComposerDataAction.REFRESH;
            cdo.data = [definition, methods];

            LocalServerSocketController.ME.request(cdo, function (data:XML):void
            {
                tree0.dataProvider = data;
                tree0.labelField = "@name";
            });

        }

        public function Base()
        {
            initControllers();
            addEventListener(FlexEvent.CREATION_COMPLETE, init, false, 0, true);
        }

        private function initControllers():void
        {
            LocalServerSocketController.ME = new LocalServerSocketController();
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
        private var container:HDividedBox
        private var loader:Loader;

//        private var cursorPosition:TextArea;

        private function hasStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, hasStage);

            createDisplay();

            // server
            LocalServerSocketController.ME.initiate(COMPOSER::PORT, COMPOSER::HOST);

        }

        private function createDisplay():void
        {
            // container
            container = new HDividedBox();
            container.percentWidth = container.percentHeight = 100;

            addElement(container);

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

//            cursorPosition = new TextArea();
//            cursorPosition.width = 300;
//            cursorPosition.height = 20;
//            cursorPosition.x = 4;
//            cursorPosition.y = 60 + 40 + 14;
//            cursorPosition.text = "global( 0, 0 ) - local( 0, 0 )";
//            cursorPosition.editable = false;
//            cursorPosition.selectable = false;
//            cursorPosition.alpha = 0.6;

            refreshContainer.addElement(refreshDefinitionText);
            refreshContainer.addElement(refreshMethodsText);
            refreshContainer.addElement(refreshBtn);
            refreshContainer.addElement(playPauseBtn);
//            refreshContainer.addElement(cursorPosition);

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

            container.addElement(box1);

            box1.addElement(tree1);

            editorStepSize = new TextInput();
            editorStepSize.width = 80;
            editorStepSize.height = 20;
            //editorStepSize.y = text.height + 30 + 5;
            editorStepSize.text = "1.0";

            box1.addElement(editorStepSize);

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

        private function drawObject(e:MouseEvent):void
        {
            var cdo:ComposerDataObject = new ComposerDataObject();
            cdo.action = ComposerDataAction.DRAW;
            cdo.data = null;

            LocalServerSocketController.ME.request(cdo, function (data:String):void
            {
                if (!data) Alert.show("drawObject error!", "", 4, tree0);
                else
                {
                    tree0.dataProvider = new XML(data);
                    tree0.labelField = "@name";
                    tree0.invalidateList();
                }
            });
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

//            cursorPosition.setStyle("borderVisible", false);
//            cursorPosition.setStyle("color", 0x888888);
        }

        private var orientation:int;


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
            var cdo:ComposerDataObject = new ComposerDataObject();
            cdo.action = ComposerDataAction.PAUSE_TOGGLE;
            cdo.data = playPauseBtn.selected as Boolean;

            LocalServerSocketController.ME.request(cdo, function (data:String):void
            {
                if (data) Alert.show(data, "", 4, tree0);
            });
        }

        private var text:TextArea;
        private var tree0:Tree;
        private var tree1:Tree;
        private var node0:XML;
        private var node1:Array;


        private function treeChange(e:ListEvent):void
        {
            editorContainer.removeAllElements();
            Clipboard.generalClipboard.clear();

            var target:Tree = Tree(e.currentTarget);

            switch (target.id)
            {
                case "tree0":

                    node0 = target.selectedItem as XML;

                    var cdo:ComposerDataObject = new ComposerDataObject();
                    cdo.action = ComposerDataAction.SELECT_COMP;
                    cdo.data = String(node0.@name);

                    LocalServerSocketController.ME.request(cdo, function (data:String):void
                    {
                        tree1.dataProvider = new XMLList(data);
                        tree1.visible = false;
                        updatePropsList();

                        tree1.labelField = "@name";

                        //TODO to fix
                        // global / local positions
//                        if (dob is DisplayObject)
//                        {
//                            if (DisplayObject(dob).hasEventListener(TouchEvent.TOUCH)) DisplayObject(dob).removeEventListener(TouchEvent.TOUCH, updatePositionsDisplay);
//                            dob.addEventListener(TouchEvent.TOUCH, updatePositionsDisplay);
//                        }

                    });


                    break;
                case "tree1":

                    node1 = target.selectedItems as Array;

                    var cdo:ComposerDataObject = new ComposerDataObject();
                    cdo.action = ComposerDataAction.GET_PROP_LABEL;
                    cdo.data = node1 as Array;

                    LocalServerSocketController.ME.request(cdo, function (data:Array):void
                    {
                        for (var i:int = 0; i < node1.length; i++)
                        {
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

                            editorContainer.addElement(editorElement);

                            text.text = data[i];
                        }

                        canvasChange();

                    });


                    break;
                default:
                    //text.text = node1.@name;
                    break;
            }

        }

//        private function updatePositionsDisplay(e:TouchEvent):void
//        {
//
//            TODO to fix
//            Utils.wraplog("updatePositionsDisplay");
//
//            var t:Touch = e.getTouch(dob as DisplayObject);
//            var l:Point;
//            if (t)
//            {
//                l = t.getLocation(dob as DisplayObject);
//                cursorPosition.text = "global( " + int(t.globalX) + ", " + int(t.globalY) + " ) - local( " + int(l.x) + ", " + int(l.y) + " )";
//                cursorPosition.alpha = 1.0;
//            }
//            else
//            {
//                cursorPosition.text = "global( 0, 0 ) - local( 0, 0)";
//                cursorPosition.alpha = 0.6;
//            }
//        }


        private function canvasChange():void
        {

            var dob:Object = null;

            var cdo:ComposerDataObject = new ComposerDataObject();
            cdo.action = ComposerDataAction.CHANGE_PROP;
            cdo.data = node1 as Array;
            LocalServerSocketController.ME.request(cdo, function (data:Array):void
            {
                for (var i:int = 0; i < editorContainer.numElements; i++)
                {
                    dob = data[i];

                    var g:Group = editorContainer.getElementAt(i) as Group;

                    if (g.numElements <= 2)
                    {
                        var text:TextArea = g.getChildAt(0) as TextArea;

                        if (text && text.text.length && node1[i])
                        {
                            var nodeName:String = String(node1[i].@name).split(":")[0];
                            text.text = nodeName + ":    " + node1[i].@type;
                            var input:*;

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

//                                    NumericStepper(input).stepSize = Number(editorStepSize.text);
                                    var nStepperAux0:String = String(dob);
                                    if (nStepperAux0.search(".") != -1)
                                    {
                                        var nStepperAux1:Number = String(nStepperAux0.split(".")[1]).length;
                                        if (nStepperAux1 >= 3) nStepperAux1 = 3;
                                        NumericStepper(input).stepSize = Number(1 / Math.pow(10, nStepperAux1));
                                    }
                                }

                                Range(input).value = Number(dob);
                            }
                            else if (node1[i].@type == "int")
                            {
                                input = new NumericStepper();
                                NumericStepper(input).minimum = -int.MAX_VALUE;
                                NumericStepper(input).maximum = int.MAX_VALUE;
                                NumericStepper(input).stepSize = 1.0;

                                Range(input).value = Number(dob);
                            }
                            else if (node1[i].@type == "uint")
                            {
                                if (nodeName == "color")
                                {
                                    input = new ColorPicker();
                                    ColorPicker(input).showTextField = true;

                                    ColorPicker(input).selectedColor = uint(dob);
                                }
                                else
                                {
                                    input = new NumericStepper();
                                    NumericStepper(input).minimum = 0;
                                    NumericStepper(input).maximum = int.MAX_VALUE;
                                    NumericStepper(input).stepSize = 1.0;

                                    Range(input).value = Number(dob);
                                }
                            }
                            else if (node1[i].@type == "Boolean")
                            {
                                input = new CheckBox();

                                CheckBox(input).selected = Boolean(dob);
                            }
                            else if (node1[i].@type == "String")
                            {
                                input = new TextInput();
                                TextInput(input).width = 250;
                                TextInput(input).height = 40;

                                TextInput(input).text = String(dob);
                            }
                            else trace("no valid type");

                            if (!input) return;

                            input.y = text.height + 5;

                            input["name"] = nodeName;

                            input.addEventListener(Event.CHANGE, function (e:Event):void
                            {

                                var cdo:ComposerDataObject = new ComposerDataObject();
                                cdo.action = ComposerDataAction.APPLY_PROP;
                                cdo.data = null;

                                if (e.currentTarget is Range)
                                {
                                    if (Number(editorStepSize.text)) e.currentTarget["stepSize"] = Number(editorStepSize.text);
                                    cdo.data = [e.currentTarget.name, e.currentTarget["value"]];
                                }
                                else if (e.currentTarget is CheckBox)
                                {
                                    cdo.data = [e.currentTarget.name, CheckBox(e.currentTarget).selected];
                                }
                                else if (e.currentTarget is TextInput)
                                {
                                    cdo.data = [e.currentTarget.name, TextInput(e.currentTarget).text];
                                }
                                else if (e.currentTarget is ComboBase)
                                {
                                    cdo.data = [e.currentTarget.name, ColorPicker(e.currentTarget).selectedColor];
                                }

                                if (cdo.data)
                                {
                                    LocalServerSocketController.ME.request(cdo, function (data:Boolean):void
                                    {
                                        if (data)
                                        {
                                            canvasChange();
                                            updatePropsList();
                                        }
                                    });
                                }

                            });

                            if (!g.containsElement(input)) g.addElement(input);
                        }
                    }
                }


            });

        }

        private var updatePropsListDelay:uint;
        private const UPDATE_PROPS_LIST_DELAY_TIME:Number = 100;

        private function updatePropsList():void
        {
            clearInterval(updatePropsListDelay);
            updatePropsListDelay = setInterval(function ():void
            {

                var cdo:ComposerDataObject = new ComposerDataObject();
                cdo.action = ComposerDataAction.UPDATE_PROP_LABEL;
                cdo.data = XMLList(tree1.dataProvider).toXMLString();

                LocalServerSocketController.ME.request(cdo, function (data:String):void
                {
                    var newValues:XMLList = new XMLList(data);
                    var i:int = 0;

                    var tempNodeName:String;
                    for each (var node:XML in tree1.dataProvider)
                    {
                        node.@name = newValues[i++].@name;
                        delete node.metadata;
                    }
                    tree1.invalidateList();
                    clearInterval(updatePropsListDelay);
                    tree1.visible = true;

                    parsePropsToObjectAndCopy();

                });

            }, UPDATE_PROPS_LIST_DELAY_TIME);

        }

        private function parsePropsToObjectAndCopy():void
        {
            var cdo:ComposerDataObject = new ComposerDataObject();
            cdo.action = ComposerDataAction.COPY_PROP;
            cdo.data = tree1.selectedItems as Array;

            LocalServerSocketController.ME.request(cdo, function (data:String):void
            {
                Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, data);
            });
        }

    }
}

