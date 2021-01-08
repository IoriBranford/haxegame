import Tiled.Property;
import h2d.Layers;
import h2d.Tile;
import h2d.SpriteBatch;
import h2d.SpriteBatch.BatchElement;
import h2d.Bitmap;
import h2d.Object;
import Tiled.MapData;
import Tiled.LayerData;

class TiledLayer extends Layers {
	public var id(default, null):Int;
	public var properties(default, null):Map<String, Property>;
	public var layers(default, null):Map<Int, TiledLayer>;
	public var objects(default, null):Map<Int, TiledObject>;

	var bitmap:Bitmap;
	var spriteBatch:SpriteBatch;
	var chunkGrid:Array<SpriteBatch>;
	var elementGrid:Array<BatchElement>;
	var ySorted = false;

	public function new(?layerData:LayerData, ?mapData:MapData, ?parent:Object) {
		super(parent);
		initFromData(layerData, mapData);
	}

	public static function spriteBatchFromData(columns:Int, rows:Int, data:Array<Int>, mapData:MapData) {
		if (rows * columns > data.length)
			throw "rows*columns > data.length";
		var spritebatch:SpriteBatch = null;
		for (gid in data) {
			var tile = Tiled.tiles.getLayerTile(gid);
			if (tile != null) {
				spritebatch = new SpriteBatch(Tile.fromTexture(tile.getTexture()));
				break;
			}
		}

		if (spritebatch == null)
			return null;

		var cellWidth = mapData.tilewidth;
		var cellHeight = mapData.tileheight;
		var i = 0;
		for (r in 1...rows + 1) {
			for (c in 0...columns) {
				var gid = data[i++];
				if (gid == 0)
					continue;
				var tile = Tiled.tiles.getLayerTile(gid);
				var element = new BatchElement(null);
				element.x = c * cellWidth;
				element.y = r * cellHeight;
				element.t = tile;
				spritebatch.add(element);
			}
		}
		return spritebatch;
	}

	public function initFromData(layerData:LayerData, mapData:MapData) {
		id = layerData.id;
		name = layerData.name;
		x = layerData.offsetx;
		y = layerData.offsety;
		properties = layerData.propertyDict;

		if (layerData.layers != null) {
			layers = new Map<Int, TiledLayer>();
			for (i in 0...layerData.layers.length) {
				var layer = new TiledLayer(layerData.layers[i], mapData);
				layers[layer.id] = layer;
				add(layer, i);
			}
		}

		if (layerData.image != null) {
			var tile = hxd.Res.load(layerData.image).toTile();
			bitmap = new Bitmap(tile, this);
		}

		if (layerData.chunks != null) {
			for (chunk in layerData.chunks) {
				var chunkBatch = spriteBatchFromData(chunk.width, chunk.height, chunk.data, mapData);
				if (chunkBatch != null) {
					chunkBatch.x = chunk.x * mapData.tilewidth;
					chunkBatch.y = chunk.y * mapData.tileheight;
					addChild(chunkBatch);
				}
			}
		} else if (layerData.data != null) {
			var data:Array<Int> = layerData.data;
			var spriteBatch = spriteBatchFromData(mapData.width, mapData.height, data, mapData);
			if (spriteBatch != null) {
				addChild(spriteBatch);
			}
		}

		if (layerData.objects != null) {
			ySorted = layerData.draworder == "topdown";
			objects = new Map<Int, TiledObject>();
			for (objectData in layerData.objects) {
				var object = new TiledObject(objectData);
				objects[object.id] = object;
				add(object, 0);
			}
		}
	}
}
