/**
 *  Export settings:
 *      Output:
 *          JSON Data:
 *              Array
 *              Meta: Tags (for animations)
 *              Item filename: "{layer} {frame}"
 *
 *  Caveats:
 *      Known issues with linked cels and trimmed cels:
 *          Wrong json with linked, trimmed cels
 *              https://github.com/aseprite/aseprite/issues/2600
 *          Exporting JSON gives incorrect frame values for some linked cels
 *              https://github.com/aseprite/aseprite/issues/2548
 */

import haxe.io.Path;
import haxe.Json;
import h2d.Tile;

typedef Size = {
	w:Int,
	h:Int
}

typedef Rect = {
	> Size,
	x:Int,
	y:Int,
}

typedef CelData = {
	filename:String,
	frame:Rect,
	rotated:Bool,
	trimmed:Bool,
	spriteSourceSize:Rect,
	sourceSize:Size,
	duration:Int
}

typedef TagData = {
	name:String,
	from:Int,
	to:Int,
	direction:String
}

typedef AseData = {
	frames:Array<CelData>,
	meta:{
		image:String, size:Size, frameTags:Array<TagData>
	}
}

typedef Cel = {
	name:String,
	tile:Tile,
	x:Int,
	y:Int,
}

typedef Frame = {
	cels:Array<Cel>,
	millis:Int
}

class AseDocument {
	public var width(default, null) = 1;
	public var height(default, null) = 1;
	public var frames(default, null) = new Array<Frame>();
	public var anims(default, null) = new Map<String, Array<Int>>();
	public var imageTile(default, null):Tile;

	public function new(filename:String) {
		var text = hxd.Res.load(filename).toText();
		var data:AseData = Json.parse(text);

		var imageFile = Path.join([Path.directory(filename), data.meta.image]);
		imageTile = hxd.Res.load(imageFile).toTile();
		width = data.meta.size.w;
		height = data.meta.size.h;

		var r = ~/(.+)\s+([0-9]+)/;
		for (celData in data.frames) {
			if (!r.match(celData.filename))
				throw 'Can\'t parse frame ${celData.filename}';

			var layerName = r.matched(1);
			var dest = celData.spriteSourceSize;
			var src = celData.frame;
			var cel = {
				name: layerName,
				x: dest.x,
				y: dest.y,
				tile: imageTile.sub(src.x, src.y, src.w, src.h),
			};

			var frameIndex = Std.parseInt(r.matched(2));

			if (frameIndex >= frames.length)
				frames.resize(frameIndex + 1);

			if (frames[frameIndex] == null) {
				frames[frameIndex] = {
					cels: new Array<Cel>(),
					millis: 0
				};
			}

			var frame = frames[frameIndex];
			frame.millis = celData.duration;
			frame.cels.push(cel);
		}

		for (tagData in data.meta.frameTags) {
			var anim = new Array<Int>();
			anims[tagData.name] = anim;

			var from = tagData.from;
			var to = tagData.to;
			var count = 1 + to - from;
			switch (tagData.direction) {
				case "forward":
					for (i in 0...count)
						anim.push(from + i);
				case "reverse":
					for (i in 0...count)
						anim.push(to - i);
				case "pingpong":
					for (i in 0...count)
						anim.push(from + i);
					for (i in 1...count)
						anim.push(to - i);
			}
		}
	}
}
