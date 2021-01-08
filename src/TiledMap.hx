import h2d.Layers;
import Tiled.MapData;
import h2d.Object;

class TiledMap extends Layers {
	public var allLayers(default, null) = new Map<String, TiledLayer>();
	public var allObjects(default, null) = new Map<Int, TiledObject>();

	var nextLayerId = 1;
	var nextObjectId = 1;

	public static function fromFile(filename:String, ?parent:Object) {
		var mapData = Tiled.loadMapData(filename);
		return new TiledMap(mapData, parent);
	}

	public function new(?mapData:MapData, ?parent:Object) {
		super(parent);
		initFromData(mapData);
	}

	public function initFromData(mapData:MapData) {
		nextLayerId = mapData.nextlayerid;
		nextObjectId = mapData.nextobjectid;

		for (i in 0...mapData.layers.length) {
			var layer = new TiledLayer(mapData.layers[i], mapData);
			add(layer, i);
			fillAllLayersAndObjects(layer);
		}
	}

	function fillAllLayersAndObjects(layer:TiledLayer) {
		if (layer.name != null && layer.name != "")
			allLayers[layer.name] = layer;

		if (layer.layers != null) {
			for (layer in layer.layers) {
				fillAllLayersAndObjects(layer);
			}
		}

		if (layer.objects != null) {
			for (object in layer.objects) {
				allObjects[object.id] = object;
			}
		}
	}
	/* TBD Are these needed?
		public function removeLayer(id:Int) {
			var layer = allLayers[id];
			if (layer != null) {
				layer.parent.removeChild(layer);
				allLayers.remove(id);
			}
			return layer;
		}

		public function removeObject(id:Int) {
			var object = allObjects[id];
			if (object != null) {
				object.parent.removeChild(object);
				allObjects.remove(id);
			}
			return object;
		}
	 */
}
