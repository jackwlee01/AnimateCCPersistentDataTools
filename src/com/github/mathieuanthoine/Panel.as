package com.github.mathieuanthoine 
{
	import adobe.utils.MMExecute;
	import fl.controls.Button;
	import fl.controls.DataGrid;
	import fl.controls.RadioButton;
	import fl.data.DataProvider;
	import fl.events.DataGridEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.system.Capabilities;
	
	/**
	 * ...
	 * @author Mathieu Anthoine
	 */
	public class Panel extends MovieClip 
	{
		
		protected static var instance: Panel;
		
		public var mcBg:MovieClip;
		public var btnDel:Button;
		public var btnAdd:Button;
		public var btnType:Button;
		public var mcGrid:DataGrid;
		
		protected const COMMAND_PREFIX:String = "fl.runScript( fl.configURI + 'PersistentData/PersistentData.jsfl'";

		public static function getInstance (): Panel {
			if (instance == null) instance = new Panel();
			return instance;
		}		
	
		public function Panel() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init (pEvent:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener (Event.MOUSE_LEAVE,lostFocus);
			stage.addEventListener (MouseEvent.MOUSE_OVER, getFocus);
			changeTheme();
			addChild(mcBg);
			
			mcGrid.columns = ["key","value"];
			mcGrid.dataProvider=new DataProvider();
			mcGrid.addEventListener(DataGridEvent.ITEM_EDIT_END,onChange);
			btnAdd.addEventListener(MouseEvent.CLICK,onAdd);
			btnDel.addEventListener(MouseEvent.CLICK, onDel);
			btnType.addEventListener(MouseEvent.CLICK, onType);
			
			onResize();
			
		}
		
		function changeTheme () {
			var lResult:String= callJSFL ("colorTheme");
			var lColor:Array = lResult=="" ? ["#515151","#FFFFFF"] : lResult.split(",");
			var lColorTransform:ColorTransform = new ColorTransform();
			lColorTransform.color = parseInt(lColor[0].substring(1),16);
			mcBg.bg.transform.colorTransform = lColorTransform;
			lColorTransform.color = parseInt(lColor[1].substring(1),16);
			mcBg.txt.transform.colorTransform = lColorTransform;
		}
		
		protected function onResize (pEvent:Event=null) : void {
			mcBg.bg.width=stage.stageWidth;
			mcBg.bg.height = stage.stageHeight;
			mcBg.txt.x=mcBg.bg.width/2;
			mcBg.txt.y=mcBg.bg.height/2;
			mcGrid.width = stage.stageWidth-14;
			mcGrid.height = stage.stageHeight-37;
			btnDel.x=stage.stageWidth-25;
			btnAdd.x=stage.stageWidth-50;
			btnDel.y=stage.stageHeight-25;
			btnAdd.y=stage.stageHeight-25;
			btnType.y=stage.stageHeight-25;
		}
		
		protected function lostFocus (pEvent:Event): void {
			stage.removeEventListener (Event.MOUSE_LEAVE,lostFocus);
			stage.addEventListener (MouseEvent.MOUSE_OVER,getFocus);
			addChild(mcBg);
			mcBg.txt.visible=true;
			btnAdd.setFocus();
			onChange();
		}

		protected function getFocus (pEvent:Event): void {
			stage.addEventListener (Event.MOUSE_LEAVE,lostFocus);
			stage.removeEventListener (MouseEvent.MOUSE_OVER,getFocus);
			addChildAt(mcBg,0);
			mcBg.txt.visible=false;
			load(callJSFL("load"));
		}

		protected function onChange (pEvent:DataGridEvent=null):void {
			addEventListener(Event.ENTER_FRAME,save);
		}

		protected function onAdd(pEventMouseEvent:MouseEvent) {
			mcGrid.addItem({});
		}

		protected function onDel(pEventMouseEvent:MouseEvent) {
			if (mcGrid.dataProvider.length>0) {
				if (mcGrid.selectedIndex==-1) mcGrid.dataProvider.removeItemAt(mcGrid.length-1);
				else mcGrid.dataProvider.removeItemAt(mcGrid.selectedIndex);
			}
		}
		
		protected function onType(pEventMouseEvent:MouseEvent) {
			onChange();
			addEventListener(Event.ENTER_FRAME, subType);
		}
		
		protected function subType (pEvent:Event): void {
			trace ("type");
			removeEventListener(Event.ENTER_FRAME, subType);
			if (btnType.selected) btnType.label = "symbol data";
			else btnType.label = "instance data";
			load(callJSFL("load"));
		}

		protected function save(pEvent:Event = null):void {
			trace ("save");
			removeEventListener(Event.ENTER_FRAME,save);
			
			var lData:Array=mcGrid.dataProvider.toArray();
			var lTxt:String="";
			
			for (var i:int=mcGrid.dataProvider.length-1;i>=0;i--) {
				if (mcGrid.dataProvider.getItemAt(i).key==undefined) mcGrid.dataProvider.removeItemAt(i);
			}		
			
			for (i=0;i<mcGrid.dataProvider.length;i++) {
				lTxt+=mcGrid.dataProvider.getItemAt(i).key+"="+mcGrid.dataProvider.getItemAt(i).value+"&";
			}
			
			if (lTxt == "") callJSFL("clear");
			else callJSFL("save",lTxt.substring(0,lTxt.length-1));
		}

		protected function load (pArg:String=""):void {
			mcGrid.dataProvider= new DataProvider();
			if (pArg=="") return;
			var lList=pArg.split("&");
			for (var i:int =0;i<lList.length;i++) {
				var lItem=lList[i].split("=");
				mcGrid.addItem({key:lItem[0], value:lItem[1]});
			}
					
		}
		
		protected function callJSFL (pMethod:String, pArgs:String=""): String {
			var lJsfl:String = "fl.runScript( fl.configURI + 'PersistentData/PersistentData.jsfl','"+pMethod+"','"+btnType.label;
			if (pArgs != "") lJsfl +="','"+pArgs;
			lJsfl +="');";
			
			debug (lJsfl);
			
			return String(MMExecute (lJsfl));
			
		}
		
		protected function debug (pArg:String):void {
			trace ("as3:"+pArg);
			MMExecute ('fl.trace("jsfl: '+pArg+'");');
		}
		
		public function destroy (): void {
			instance = null;
		}

	}
}