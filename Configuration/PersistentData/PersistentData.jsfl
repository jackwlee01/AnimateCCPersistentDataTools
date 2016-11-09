var DOM=fl.getDocumentDOM();
var SYMBOL_DATA="symbol data";

var elem;
var dataType;

var eventID;

function init () {
	if (eventID!=null) fl.removeEventListener("selectionChanged",eventID);
	eventID = fl.addEventListener("selectionChanged",selectionChanged);
}

function selectionChanged () {
	fl.getSwfPanel("Persistent Data").call("callPanel","");
}

function colorTheme (pType) {
	return fl.getThemeColor(fl.getThemeColorParameters()[0])+","+fl.getThemeColor(fl.getThemeColorParameters()[5]);
}

function setType (pType) {
	
	if (DOM==null) return false;	
	if (DOM.selection.length==0) return false;
	
	dataType=pType;
	
	if (dataType==SYMBOL_DATA) {
		elem = DOM.selection[0].libraryItem;
		if (elem==null) return false;
	} else elem = DOM.selection[0];
	
	return true;
}

function getNames () {
	return dataType==SYMBOL_DATA ? elem.getDataNames() : elem.getPersistentDataNames();
}

function getData (pData) {
	return dataType==SYMBOL_DATA ? elem.getData(pData) : elem.getPersistentData(pData);
}

function setData (pKey, pType,pData) {
	dataType==SYMBOL_DATA ? elem.addData(pKey, pType,pData) : elem.setPersistentData(pKey, pType,pData);
}

function removeData (pData) {
	dataType==SYMBOL_DATA ? elem.removeData(pData) : elem.removePersistentData(pData);
}

function clear (pType) {
	if (setType(pType)) {
		var lList = getNames();
		for (var i=0;i<lList.length;i++) removeData(lList[i]);
	}
}

function load (pType) {
	if (setType(pType)) {
		var lList = getNames();
		var lArg = "";
		for (var i=0;i<lList.length;i++) lArg+=lList[i]+"="+getData(lList[i])+"&";
		return lArg.substring(0,lArg.length-1);
	}
	
	return "non-symbol";
}

function save (pType,pArg) {
	if (setType(pType)) {
		clear(pType);			
		if (pArg=="") return;
		
		var lList=pArg.split("&");		
		
		for (i =0;i<lList.length;i++) {
			var lItem=lList[i].split("=");
			var lKey=lItem[0];
			var lValue=lItem[1];
			
			if (lValue.split(",").length>1) {
				var lArray=lValue.split(",");
				var lType="integerArray";
				for (var j=0;j<lArray.length;j++) {						
					if (isNaN(parseInt(lArray[j]))) {
						lType="string";
						break;
					} else if (parseInt(lArray[j]).toString()==lArray[j]) lArray[j]=parseInt(lArray[j]);
					else {
						lType="doubleArray";
						lArray[j]=parseFloat(lArray[j]);
					}
				}
				if (lType=="string") setData( lKey, "string", lValue);
				else setData( lKey,lType, lArray );
			} else if (parseInt(lValue).toString()==lValue) setData( lKey, "integer", parseInt(lValue) ); 
			else if (parseFloat(lValue).toString()==lValue) setData( lKey, "double", parseFloat(lValue) ); 
			else setData( lKey, "string", lValue);		
		}
	} 	
}