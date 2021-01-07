import TiledData.MapData;
import h2d.Object;

class TiledMap extends Object {
	public var layers(default, null) = new Map<Int, TiledLayer>();
	public var objects(default, null) = new Map<Int, TiledObject>();

	var nextLayerId = 1;
	var nextObjectId = 1;

	public static function fromFile(filename:String, spriteDict:SpriteDict, ?parent:Object) {
		var mapData = TiledData.loadMapData(filename);
		return new TiledMap(mapData, spriteDict, parent);
	}

	public function new(?mapData:MapData, ?spriteDict:SpriteDict, ?parent:Object) {
		super(parent);
		initFromData(mapData, spriteDict);
	}

	public function initFromData(mapData:MapData, spriteDict:SpriteDict) {
		nextLayerId = mapData.nextlayerid;
		nextObjectId = mapData.nextobjectid;

		spriteDict.addTilesets(mapData.tilesets);

		for (layerData in mapData.layers) {
			var layer = new TiledLayer(layerData, mapData, spriteDict, this);
			addLayersAndObjects(layer);
		}
	}

	function addLayersAndObjects(layer:TiledLayer) {
		layers[layer.id] = layer;
		if (layer.layers != null) {
			for (layer in layer.layers) {
				addLayersAndObjects(layer);
			}
		}
		if (layer.objects != null) {
			for (object in layer.objects) {
				objects[object.id] = object;
			}
		}
	}
	/* TBD Are these needed?
		public function removeLayer(id:Int) {
			var layer = layers[id];
			if (layer != null) {
				layer.parent.removeChild(layer);
				layers.remove(id);
			}
			return layer;
		}

		public function removeObject(id:Int) {
			var object = objects[id];
			if (object != null) {
				object.parent.removeChild(object);
				objects.remove(id);
			}
			return object;
		}
	 */
}
