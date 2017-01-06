package components
{
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import mx.containers.HDividedBox;
	import mx.containers.VDividedBox;
	import mx.controls.Alert;
	import mx.controls.MovieClipSWFLoader;
	import mx.controls.TextArea;
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.components.NumericStepper;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.components.supportClasses.Range;
	
	public class Base extends Application
	{
		
		[Embed(source = "../../lib/assets/playpauseicon.png")]
		static private var playpauseicon:Class;
		
		static private const DEFAULT_DEFINITION:String = "starling.core::Starling";
		static private const DEFAULT_METHODS:String = "current,stage";
		
		public function start(comp:Object):void
		{
			canvas.source = comp;
			canvas.scaleContent = false;
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3DCreate);
		}
		
		private var definition:String;
		private var methods:String;
		
		private function context3DCreate(e:Event):void
		{
			
			container.removeElement(canvas);
			this.x = 768;
			container.percentWidth = 50;
		}
		
		private function refresh(definition:String, methods:String = null):void
		{
			var clazz:Object = loader.contentLoaderInfo.applicationDomain.getDefinition(definition);
			if (methods && methods.length)
			{
				var methodsTemp:Array = methods.split(",");
				while (methodsTemp.length) clazz = clazz[methodsTemp.shift()];
			}
			var list0:XML = parseComp(clazz, null);
			for (var key:String in childList) trace(key, childList[key]);
			tree0.dataProvider = list0;
			tree0.labelField = "@name";
		}
		
		public function Base()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, init, false, 0, true);
		}
		
		private var refreshContainer:Group;
		private var refreshDefinitionText:TextArea;
		private var refreshMethodsText:TextArea;
		private var refreshBtn:Button;
		private var playPauseBtn:ToggleButton;
		private var editorContainer:Group;
		private var canvas:MovieClipSWFLoader;
		private var container:HDividedBox
		private var loader:Loader;
		
		private function init(e:FlexEvent):void
		{
			
			// container						
			container = new HDividedBox();
			container.percentWidth = container.percentHeight = 100;
			
			addElement(container);
			
			// left 
			canvas = new MovieClipSWFLoader();
			canvas.width = 768;
			canvas.height = 1024;
			
			container.addElement(canvas);
			
			// middle
			
			var box0:VDividedBox = new VDividedBox();
			box0.percentWidth = 25;
			box0.percentHeight = 100;
			
			refreshContainer = new Group();
			refreshContainer.percentWidth = 100;
			refreshContainer.percentHeight = 10;
			
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
			
			refreshContainer.addElement(refreshDefinitionText);
			refreshContainer.addElement(refreshMethodsText);
			refreshContainer.addElement(refreshBtn);
			refreshContainer.addElement(playPauseBtn);
			
			tree0 = new Tree();
			tree0.percentWidth = 100;
			tree0.percentHeight = 90;
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
			tree1.percentHeight = 80;
			tree1.showRoot = false;
			tree1.id = "tree1";
			
			editorContainer = new Group();
			editorContainer.percentWidth = 100;
			editorContainer.percentHeight = 20;
			
			text = new TextArea();
			text.percentWidth = 100;
			text.height = 60;
			text.editable = false;
			
			editorContainer.addElement(text);
			
			container.addElement(box1);
			
			box1.addElement(tree1);
			box1.addElement(editorContainer);
			
			// events
			tree0.addEventListener(ListEvent.CHANGE, treeChange);
			tree1.addEventListener(ListEvent.CHANGE, treeChange);
			
			refreshBtn.addEventListener(MouseEvent.CLICK, refreshBtnClick);
			refreshBtn.enabled = true;
			
			playPauseBtn.addEventListener(MouseEvent.CLICK, playPauseBtnClick);
			playPauseBtn.enabled = true;
			
			// skin
			setSkinColor();
			
			// loader
			load();
		
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
		}
		
		private function load():void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			loader.load(new URLRequest("LoaderSwf.swf"));
		}
		
		private function loaderComplete(e:Event):void
		{
			start(LoaderInfo(e.currentTarget).content);
		}
		
		private function refreshBtnClick(e:MouseEvent):void
		{
			refreshBtn.enabled = false;
			try
			{
				refresh(refreshDefinitionText.text, refreshMethodsText.text);
			}
			catch (err:Error)
			{
				Alert.show(err.message);
			}
			refreshBtn.enabled = true;
		}
		
		private function playPauseBtnClick(e:MouseEvent):void
		{
			try
			{
				var starling:Object = loader.contentLoaderInfo.applicationDomain.getDefinition(DEFAULT_DEFINITION)["current"];
				starling[playPauseBtn.selected ? "stop" : "start"]();
			}
			catch (e:Error)
			{
				Alert.show(e.message);
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
		private var node1:XML;
		
		private var dob:Object;
		
		private function treeChange(e:ListEvent):void
		{
			text.text = "";
			canvas.removeEventListener(Event.ENTER_FRAME, canvasChange);
			editorContainer.removeAllElements();
			
			var target:Tree = Tree(e.currentTarget);
			
			switch (target.id)
			{
			case "tree0": 
				node0 = target.selectedItem as XML;
				dob = childList[String(node0.@name)];
				//	
				tree1.dataProvider = describeType(dob)..accessor.( //
				//(@declaredBy == "flash.display::DisplayObject" || @declaredBy == "flash.display::DisplayObjectContainer" || @declaredBy == "flash.display::Sprite") //
				( //
				@declaredBy == "starling.display::DisplayObject"  //
				|| @declaredBy == "starling.display::DisplayObjectContainer" //
				|| @declaredBy == "starling.display::Image" //
				|| @declaredBy == "starling.display::Sprite" //
				|| @declaredBy == "starling.display::Sprite3D" //
				|| @declaredBy == "starling.text::TextField" //
				//
				|| @declaredBy == "com.assukar.view.starling::Component" // Custom
				|| @declaredBy == "com.assukar.view.starling::AssukarTextField" // Custom
				|| @declaredBy == "com.assukar.view.starling::AssukarMovieClip" // Custom
				|| @declaredBy == "com.assukar.view.starling::AssukarMovieBytes" // Custom
				) //
				&& @access == "readwrite" //
				&& ( //
				@type == "int" //
				|| @type == "Number" //
				|| @type == "Boolean" //
				|| @type == "String" //
				)); //
				//&& @name != "name");
				//				
				for each (var node:XML in tree1.dataProvider) delete node.metadata;
				tree1.invalidateDisplayList();
				//
				tree1.labelField = "@name";
				break;
			case "tree1": 
				node1 = target.selectedItem as XML;
				text.text = node1.@name + ":    " + node1.@type + "\nvalue:    " + dob[node1.@name];
				//
				canvas.addEventListener(Event.ENTER_FRAME, canvasChange);
				editorContainer.addElement(text);
				break;
			default: 
				text.text = node1.@name;
				break;
			}
		
		}
		
		private function canvasChange(e:Event):void
		{
			if (text && text.text.length && node1 && dob)
			{
				text.text = node1.@name + ":    " + node1.@type + "\nvalue:    " + dob[node1.@name];
				
				if (editorContainer.numElements <= 1)
				{
					var input:*;
					if (node1.@type == "Number")
					{
						if (node1.@name == "alpha")
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
							//NumericStepper(input).stepSize = String(node1.@name).search("scale") != -1 ? 0.01 : 1;
							NumericStepper(input).stepSize = String(node1.@name).search("scale") != -1 || String(node1.@name).search("rotation") != -1 ? 0.01 : 1;
						}
						
						Range(input).value = Number(dob[node1.@name]);
						
					}
					else if (node1.@type == "Boolean")
					{
						input = new CheckBox();
						CheckBox(input).selected = Boolean(dob[node1.@name]);
					}
					else if (node1.@type == "String")
					{
						input = new TextInput();
						TextInput(input).text = String(dob[node1.@name]);
					}
					else trace("no valid type");
					
					if (!input) return;
					input.y = text.height + 5;
					input.addEventListener(Event.CHANGE, function(e:Event):void
					{
						if (e.currentTarget is Range) dob[node1.@name] = input["value"];
						else if (e.currentTarget is CheckBox) dob[node1.@name] = CheckBox(input).selected;
						else if (e.currentTarget is TextInput)
						{
							try
							{
								dob[node1.@name] = TextInput(input).text;
							}
							catch (e:Error)
							{
								trace(e.message);
							}
						}
					});
					
					editorContainer.addElement(input);
				}
			}
		}
	
	}
}