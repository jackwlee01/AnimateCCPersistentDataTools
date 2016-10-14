package com.github.mathieuanthoine 
{
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mathieu Anthoine
	 */
	public class Main extends MovieClip 
	{
		
		protected static var instance: Main;

		public static function getInstance (): Main {
			return instance;
		}		
	
		public function Main() 
		{
			super();
			if (instance != null) {
				throw new Error("There's already a singleton of Main");
				return;
			}
			instance = this;
			
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		protected function init (pEvent:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(Panel.getInstance());
		}
		
		public function destroy (): void {
			instance = null;
		}

	}
}