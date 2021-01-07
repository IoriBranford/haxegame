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
	fontfamily:String,
	pixelsize:Int,
	wrap:Bool,
	color:String,
	bold:Bool,
	italic:Bool,
	underline:Bool,
	strikeout:Bool,
	kerning:Bool,
	halign:String,
	valign:String,
	text:String,
}

typedef GidBounds = {min:Int, max:Int};

typedef Chunk = {
	x:Int,
	y:Int,
	width:Int,
	height:Int,
	data:Any,
	gidbounds:GidBounds
}

typedef LayerData = {
	id:Int,
	name:String,
	type:String,
	offsetx:Float,
	offsety:Float,
	visible:Bool,
	opacity:Float,
	tintcolor:String,
	properties:Array<Property>,
	propertyDict:Map<String, Property>,

	chunks:Array<Chunk>,
	compression:String,
	data:Any,
	encoding:String,
	startx:Int,
	starty:Int,
	width:Int,
	height:Int,
	objects:Array<ObjectData>,
	draworder:String,
	image:String,
	transparentcolor:String,
	layers:Array<LayerData>,
	x:Int,
	y:Int,
	gidbounds:GidBounds
}

typedef ObjectData = {
	> Position,
	width:Float,
	height:Float,
	id:Int,
	name:String,
	type:String,
	rotation:Float,
	gid:Int,
	visible:Bool,
	ellipse:Bool,
	point:Bool,
	polygon:Array<Position>,
	polyline:Array<Position>,
	text:TextData,
	template:String,
	properties:Array<Property>,
	propertyDict:Map<String, Property>,
	tileset:TilesetData,
}

typedef Terrain = {
	name:String,
	tile:Int,
	properties:Array<Property>,
	propertyDict:Map<String, Property>,
}

typedef FrameData = {
	tileid:Int,
	duration:Int,
}

typedef TileData = {
	id:Int,
	type:String,
	probability:Float,
	animation:Array<FrameData>,
	objectgroup:LayerData,
	terrain:Array<Int>,
	properties:Array<Property>,
	propertyDict:Map<String, Property>,
}

typedef TilesetData = {
	backgroundcolor:String,
	// Hex-formatted color (#RRGGBB or #AARRGGBB) (optional)
	columns:Int,
	// The number of tile columns in the tileset
	firstgid:Int,
	// GID corresponding to the first tile in the set
	// grid 				:Grid 	,// (optional)
	image:String,
	// Image used for tiles in this set
	imageheight:Int,
	// Height of source image in pixels
	imagewidth:Int,
	// Width of source image in pixels
	margin:Int,
	// Buffer between image edge and first tile (pixels)
	name:String,
	// Name given to this tileset
	objectalignment:String,
	// Alignment to use for tile objects (unspecified (default), topleft, top, topright, left, center, right, bottomleft, bottom or bottomright) (since 1.4)
	properties:Array<Property>,
	propertyDict:Map<String, Property>,
	// Array of Properties
	source:String,
	// The external file that contains this tilesets data
	spacing:Int,
	// Spacing between adjacent tiles in image (pixels)
	terrains:Array<Terrain>,
	// Array of Terrains (optional)
	tilecount:Int,
	// The number of tiles in this tileset
	tiledversion:String,
	// 	The Tiled version used to save the file
	tileheight:Int,
	// Maximum height of tiles in this set
	tileoffset:{x:Int, y:Int},
	tiles:Array<TileData>,
	// Array of Tiles (optional)
	tilewidth:Int,
	// Maximum width of tiles in this set
	transparentcolor:String,
	// Hex-formatted color (#RRGGBB) (optional)
	type:String,
	// tileset (for tileset files, since 1.0)
	version:Float,
	// The JSON format version
	// wangsets:array,
	// Array of Wang sets (since 1.1.5)
}

typedef MapData = {
	backgroundcolor:String,
	// Hex-formatted color (#RRGGBB or #AARRGGBB) (optional)
	compressionlevel:Int,
	// The compression level to use for tile layer data (defaults to -1, which means to use the algorithm default)
	height:Int,
	// Number of tile rows
	hexsidelength:Int,
	// Length of the side of a hex tile in pixels (hexagonal maps only)
	infinite:Bool,
	// Whether the map has infinite dimensions
	layers:Array<LayerData>,
	// Array of Layers
	nextlayerid:Int,
	// Auto-increments for each layer
	nextobjectid:Int,
	// Auto-increments for each placed object
	orientation:String,
	// orthogonal, isometric, staggered or hexagonal
	properties:Array<Property>,
	propertyDict:Map<String, Property>,
	// Array of Properties
	renderorder:String,
	// right-down (the default), right-up, left-down or left-up (currently only supported for orthogonal maps)
	staggeraxis:String,
	// x or y (staggered / hexagonal maps only)
	staggerindex:String,
	// odd or even (staggered / hexagonal maps only)
	tiledversion:String,
	// The Tiled version used to save the file
	tileheight:Int,
	// Map grid height
	tilesets:Array<TilesetData>,
	// Array of Tilesets
	tilewidth:Int,
	// Map grid width
	type:String,
	// map (since 1.0)
	version:Float,
	// The JSON format version
	width:Int,
	// Number of tile columns
}

typedef TemplateData = {
	tileset:TilesetData,
	object:ObjectData,
}

class TiledData {
	static function _fntFileName(fontfamily:String, pixelsize:Int = 16, bold:Bool = false, italic:Bool = false) {
		var fontfile = fontfamily;
		if (bold)
			fontfile += " bold";
		if (italic)
			fontfile += " italic";
		return fontfile + ' ' + pixelsize + ".fnt";
	}

	static function fntFileName(text:TextData) {
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
		if (properties == null)
			return null;
		var dict = new Map<String, Property>();
		for (property in properties) {
			dict[property.name] = property;
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

	static function initLayer(layer:LayerData, cwd:String = "") {
		if (layer == null)
			return;
		layer.propertyDict = propertyDict(layer.properties);
		if (layer.layers != null) {
			for (layer in layer.layers) {
				initLayer(layer);
			}
		}

		if (layer.chunks != null) {
			if (layer.encoding == "base64") {
				for (chunk in layer.chunks) {
					chunk.data = decodeData(chunk.data, layer.compression);
				}
			}
			for (chunk in layer.chunks) {
				chunk.gidbounds = findGidBounds(chunk.data);
			}
		} else if (layer.data != null) {
			if (layer.encoding == "base64")
				layer.data = decodeData(layer.data, layer.compression);

			layer.gidbounds = findGidBounds(layer.data);
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

		object.propertyDict = propertyDict(object.properties);

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
		}
	}

	static function initTileset(tileset:TilesetData, cwd:String = "") {
		if (tileset == null)
			return null;

		tileset.propertyDict = propertyDict(tileset.properties);
		if (tileset.source != null) {
			var firstgid = tileset.firstgid;
			var source = Path.join([cwd, tileset.source]);
			tileset = loadTilesetData(source);
			tileset.source = source;
			tileset.firstgid = firstgid;
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

	static function parseMap(text:String, cwd:String = ""):MapData {
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

	static function parseTileset(text:String, cwd:String = ""):TilesetData {
		return initTileset(Json.parse(text), cwd);
	}

	static function parseTemplate(text:String, cwd:String = ""):TemplateData {
		var template:TemplateData = Json.parse(text);
		template.tileset = initTileset(template.tileset, cwd);
		initObject(template.object, cwd);
		return template;
	}

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

	public static function clearDataCache() {
		dataCache = new Map<String, Any>();
	}
}
