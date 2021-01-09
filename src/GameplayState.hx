import hxd.Key;
import h2d.Layers;
import h2d.Object;

class GameplayState extends AppState {
	final ViewWidth = 640;
	final ViewHeight = 360;
	final ScrollAreaWidth = 1024.0;
	var bgScrollLayers:Layers;
	var bgScrollSpeeds:Array<Float>;
	var fgScrollLayerLeft:Object;
	var fgScrollLayerRight:Object;
	var flySpeed = 5.0;

	override function init() {
		var s2d = Main.app.s2d;
		s2d.scaleMode = ScaleMode.LetterBox(ViewWidth, ViewHeight, true);

		bgScrollLayers = new Layers(s2d);
		bgScrollSpeeds = new Array<Float>();

		var mapDoc = new TiledDocument("tropical_island.json");
		var bg = mapDoc.namedLayers["bg"];
		if (bg == null)
			throw "no bg";
		if (bg.sublayers == null)
			throw "bg not a layer group";

		for (i in 0...bg.sublayers.length) {
			var sublayer = bg.sublayers[i];
			var layerObject = new Object();
			layerObject.x = sublayer.x;
			layerObject.y = sublayer.y;
			bgScrollLayers.add(layerObject, i);
			mapDoc.makeLayerTileGroups(sublayer, layerObject);

			var dx:Float = sublayer.properties["dx"];
			bgScrollSpeeds.push(dx);
		}

		var start = mapDoc.namedLayers["start"];
		fgScrollLayerLeft = new Object(s2d);
		mapDoc.makeLayerTileGroups(start, fgScrollLayerLeft);
	}

	override function dispose() {}

	function scroll(object:Object, speed:Float) {
		if (object == null)
			return;

		object.x += speed;
		if (object.x < -ScrollAreaWidth)
			object.x += 2 * ScrollAreaWidth;
	}

	override function fixedUpdate() {
		if (!Key.isDown(Key.SPACE))
			return;
		for (i in 0...bgScrollSpeeds.length) {
			var scrollLayer = bgScrollLayers.getLayer(i);
			if (scrollLayer == null)
				continue;
			for (object in scrollLayer) {
				scroll(object, bgScrollSpeeds[i]);
			}
		}
		scroll(fgScrollLayerLeft, -flySpeed);
		scroll(fgScrollLayerRight, -flySpeed);
	}

	override function update(dfu:Float) {}
}
