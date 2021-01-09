import h2d.Tile;
import format.gz.Reader;
import haxe.io.BytesInput;
import haxe.crypto.Base64;
import haxe.zip.Uncompress;
import haxe.io.Path;
import haxe.Json;

typedef Position = {
	x:Float,
	y:Float,
}

typedef Size = {
	width:Float,
	height:Float,
}

typedef Property = {
	name:String,
	type:String,
	value:Any,
}

typedef TextData = {
	// app will use these
	font:h2d.Font,
	text:String,
	halign:String,
	valign:String,
	wrap:Bool,
	color:String,

	// not these
	fontfamily:String,
	pixelsize:Int,
	bold:Bool,
	italic:Bool,
	underline:Bool,
	strikeout:Bool,
	kerning:Bool,
}

typedef Chunk = {
	// app will use these
	tiles:Array<Tile>,
	x:Int,
	y:Int,
	width:Int,
	height:Int,

	// not this
	data:Any,
}

typedef LayerData = {
	// app will use these
	tiles:Array<Tile>,
	chunks:Array<Chunk>,
	layers:Array<LayerData>,
	objects:Array<ObjectData>,

	// likely use these
	name:String,
	offsetx:Float,
	offsety:Float,
	width:Int,
	height:Int,
	draworder:String,
	// might use these
	id:Int,
	type:String,
	visible:Bool,
	opacity:Float,
	propertyDict:Map<String, Any>,
	// not these
	x:Int,
	y:Int,
	properties:Array<Property>,
	compression:String,
	data:Any,
	encoding:String,
	image:String,
}

typedef ObjectData = {
	// app will use these
	> Position,
	tile:Tile,
	animation:Array<{
		tile:Tile,
		duration:Int,
	}>,
	polygon:Array<Position>,
	polyline:Array<Position>,
	tileset:TilesetData,
	text:TextData,
	width:Float,
	height:Float,

	// might use these
	rotation:Float,
	name:String,
	type:String,
	id:Int,
	ellipse:Bool,
	point:Bool,
	visible:Bool,
	propertyDict:Map<String, Any>,
	// probably not this
	template:String,
	// not these
	properties:Array<Property>,
	gid:Int,
}

typedef Terrain = {
	name:String,
	tile:Int,
	properties:Array<Property>,
	propertyDict:Map<String, Any>,
}

typedef FrameData = {
	tileid:Int,
	duration:Int,
}

typedef TileData = {
	// likely use this
	animation:Array<FrameData>,
	// might use these
	objectgroup:LayerData,
	id:Int,
	type:String,
	probability:Float,
	propertyDict:Map<String, Any>,
	terrain:Array<Int>,
	// not this
	properties:Array<Property>,
}

typedef TilesetData = {
	// app will likely use this
	h2dTiles:Array<Tile>,
	tileAnimations:Array<{
		tile:Tile,
		duration:Int
	}>,
	// might use these
	propertyDict:Map<String, Any>,
	name:String,
	objectalignment:String,
	terrains:Array<Terrain>,
	tilecount:Int,
	tileheight:Int,
	tileoffset:{x:Int, y:Int},
	tilewidth:Int,
	// not these
	columns:Int,
	firstgid:Int,
	backgroundcolor:String,
	transparentcolor:String,
	margin:Int,
	spacing:Int,
	tiledversion:String,
	type:String,
	tiles:Array<TileData>,
	source:String,
	image:String,
	imageheight:Int,
	imagewidth:Int,
	properties:Array<Property>,
	version:Float,
}

typedef MapData = {
	// app will use these
	layers:Array<LayerData>,
	tiles:Map<String, Tile>,

	// likely use these
	orientation:String,
	backgroundcolor:String,
	width:Int,
	height:Int,
	tileheight:Int,
	tilewidth:Int,
	hexsidelength:Int,
	infinite:Bool,
	// might use these
	tilesets:Array<TilesetData>,
	propertyDict:Map<String, Any>,
	nextlayerid:Int,
	nextobjectid:Int,
	renderorder:String,
	staggeraxis:String,
	staggerindex:String,
	tiledversion:String,
	// not these
	tileArray:Array<Tile>,
	properties:Array<Property>,
	compressionlevel:Int,
	type:String,
	version:Float,
}

typedef TemplateData = {
	tileset:TilesetData,
	object:ObjectData,
}

class Tiled {
	public static var tiles(default, null) = new TiledTiles();

	static var dataCache = new Map<String, Any>();

	public static function loadMapData(filename:String):MapData {
		if (dataCache.exists(filename))
			return dataCache.get(filename);
		var data = parseMap(hxd.Res.load(filename).toText(), Path.directory(filename));
		dataCache.set(filename, data);
		return data;
	}

	public static function loadTilesetData(filename:String):TilesetData {
		if (dataCache.exists(filename))
			return dataCache.get(filename);
		var data = parseTileset(hxd.Res.load(filename).toText(), Path.directory(filename));
		tiles.addTileset(data);
		dataCache.set(filename, data);
		return data;
	}

	public static function loadTemplate(filename:String):TemplateData {
		if (dataCache.exists(filename))
			return dataCache.get(filename);
		var data = parseTemplate(hxd.Res.load(filename).toText(), Path.directory(filename));
		dataCache.set(filename, data);
		return data;
	}

	public static function clearCached() {
		dataCache = new Map<String, Any>();
		tiles = new TiledTiles();
	}

	static function _fntFileName(fontfamily:String, pixelsize:Int = 16, bold:Bool = false, italic:Bool = false) {
		var fontfile = fontfamily;
		if (bold)
			fontfile += " bold";
		if (italic)
			fontfile += " italic";
		return fontfile + ' ' + pixelsize + ".fnt";
	}

	public static function fntFileName(text:TextData) {
		return _fntFileName(text.fontfamily, text.pixelsize, text.bold, text.italic);
	}

	static function initText(text:TextData) {
		hxd.Res.load(fntFileName(text));
	}

	static function findGidBounds(data:Array<Int>) {
		var min = 0x20000000;
		var max = 0;

		for (gid in data) {
			var unflipped = gid & 0x1fffffff;
			if (max < unflipped)
				max = unflipped;
			if (min > unflipped)
				min = unflipped;
		}
		return {min: min, max: max};
	}

	static function propertyDict(properties:Array<Property>) {
		var dict = new Map<String, Any>();
		if (properties != null) {
			for (property in properties) {
				dict[property.name] = property.value;
			}
		}
		return dict;
	}

	static function decodeData(data:Any, compression:String) {
		var string:String = data;
		var bytes = Base64.decode(string);
		switch (compression) {
			case "zlib":
				bytes = Uncompress.run(bytes);
			case "gzip":
				bytes = new Reader(new BytesInput(bytes)).read().data;
			case null:

			default:
				throw compression + " not yet supported";
		}
		var array = new Array<Int>();
		for (i in 0...bytes.length >> 2) {
			array.push(bytes.getInt32(i << 2));
		}
		return array;
	}

	static function initLayer(layer:LayerData, cwd:String) {
		if (layer == null)
			return;
		layer.propertyDict = propertyDict(layer.properties);
		if (layer.layers != null) {
			for (layer in layer.layers) {
				initLayer(layer, cwd);
			}
		}

		if (layer.chunks != null) {
			if (layer.encoding == "base64") {
				for (chunk in layer.chunks) {
					chunk.data = decodeData(chunk.data, layer.compression);
				}
			}
		} else if (layer.data != null) {
			if (layer.encoding == "base64")
				layer.data = decodeData(layer.data, layer.compression);
		}

		if (layer.objects != null) {
			for (object in layer.objects) {
				initObject(object, cwd);
			}
		}

		if (layer.image != null) {
			layer.image = Path.join([cwd, layer.image]);
			hxd.Res.load(layer.image);
		}
	}

	static function initObject(object:ObjectData, cwd:String) {
		if (object == null)
			return;

		var properties = propertyDict(object.properties);
		object.propertyDict = properties;

		if (object.template != null) {
			object.template = Path.join([cwd, object.template]);
			var template = loadTemplate(object.template);
			if (object.gid == 0)
				object.gid = template.object.gid;
			if (object.name == null || object.name == "")
				object.name = template.object.name;
			if (object.type == null || object.type == "")
				object.type = template.object.type;
			object.visible = template.object.visible;
			object.point = template.object.point;
			object.ellipse = template.object.ellipse;
			object.tileset = template.tileset;
			var templateProperties = template.object.properties;
			for (property in templateProperties) {
				if (!properties.exists(property.name))
					properties[property.name] = property;
			}
		}
	}

	static function initTileset(tileset:TilesetData, cwd:String) {
		if (tileset == null)
			return null;

		tileset.propertyDict = propertyDict(tileset.properties);
		if (tileset.source != null) {
			var source = Path.join([cwd, tileset.source]);
			tileset = loadTilesetData(source);
			tileset.source = source;
		} else {
			var oldtiles = tileset.tiles;
			if (oldtiles != null) {
				var tiles = new Array<TileData>();
				tiles.resize(tileset.tilecount);
				for (tile in oldtiles) {
					tiles[tile.id] = tile;
					tile.propertyDict = propertyDict(tile.properties);
					initLayer(tile.objectgroup, cwd);
				}
				tileset.tiles = tiles;
			}

			tileset.image = Path.join([cwd, tileset.image]);
		}
		return tileset;
	}

	static function parseMap(text:String, cwd:String):MapData {
		var map:MapData = Json.parse(text);
		map.propertyDict = propertyDict(map.properties);
		for (i in 0...map.tilesets.length) {
			map.tilesets[i] = initTileset(map.tilesets[i], cwd);
		}
		for (layer in map.layers) {
			initLayer(layer, cwd);
		}
		return map;
	}

	static function parseTileset(text:String, cwd:String):TilesetData {
		return initTileset(Json.parse(text), cwd);
	}

	static function parseTemplate(text:String, cwd:String):TemplateData {
		var template:TemplateData = Json.parse(text);
		template.tileset = initTileset(template.tileset, cwd);
		initObject(template.object, cwd);
		return template;
	}
}
