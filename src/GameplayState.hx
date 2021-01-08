class GameplayState extends AppState {
	var map:TiledMap;
	var scrolls = new Array<Scroll>();
	final ViewWidth = 640;
	final ViewHeight = 360;
	final ScrollAreaWidth = 1024.0;

	override function init() {
		var s2d = Main.app.s2d;
		s2d.scaleMode = ScaleMode.LetterBox(ViewWidth, ViewHeight, true);
		map = TiledMap.fromFile("tropical_island.json", s2d);

		var bg = map.allLayers["bg"];
		var scrollObjects = new Array<TiledLayer>();
		for (layer in bg.layers) {
			scrollObjects.push(layer);
		}
		var scroll = new Scroll(ScrollAreaWidth, scrollObjects);
		scrolls.push(scroll);
	}

	override function dispose() {
		Tiled.clearCached();
	}

	override function fixedUpdate() {
		for (scroll in scrolls) {
			scroll.fixedUpdate();
		}
	}

	override function update(dfu:Float) {}
}
