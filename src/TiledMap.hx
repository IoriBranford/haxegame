import h2d.Layers;
import TiledData.MapData;
import h2d.Object;

class TiledMap extends Object {
	public var allLayers(default, null) = new Map<Int, TiledLayer>();
	public var allObjects(default, null) = new Map<Int, TiledObject>();

	var layerStack:Layers;
	var nextLayerId = 1;
	var nextObjectId = 1;

	public static function fromFile(filename:String, spriteDict:SpriteDict, ?parent:Object) {
		var mapData = TiledData.loadMapData(filename);
		return new TiledMap(mapData, spriteDict, parent);
	}

	public function new(?mapData:MapData, ?spriteDict:SpriteDict, ?parent:Object) {
		super(parent);
		layerStack = new Layers(this);
		initFromData(mapData, spriteDict);
	}

	public function initFromData(mapData:MapData, spriteDict:SpriteDict) {
		nextLayerId = mapData.nextlayerid;
		nextObjectId = mapData.nextobjectid;

		spriteDict.addTilesets(mapData.tilesets);

		for (layerData in mapData.layers) {
			var layer = new TiledLayer(layerData, mapData, spriteDict);
			layerStack.add(layer, 0);
			fillAllLayersAndObjects(layer);
		}
	}

	function fillAllLayersAndObjects(layer:TiledLayer) {
		allLayers[layer.id] = layer;
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
