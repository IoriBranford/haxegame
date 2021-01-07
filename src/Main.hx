import hxd.Key;

class Main extends hxd.App {
	var fixedUpdateCounter = 0.0;
	var fixedUpdateRate = 60.0;
	var map:TiledMap;

	override function init() {
		hxd.Res.initEmbed();
		var spriteDict = new SpriteDict();
		map = TiledMap.fromFile("stage_inebriator.json", spriteDict, s2d);
		// var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		// tf.maxWidth = 640;
		// tf.text = Std.string(mapData);
		/*
			function update() {
				// after gameplay logic determines next position and state:
				var some_layer = map.layers[some_layerid]
				var object = map.objects[objectid]
				object.setVisible(true)
				object.setParent(some_layer)
				var animation = tiles.getAnimation("player,idle")
				object.setAnim(animation.frames, animation.speed)
				object.setPosition(x, y)
			}
		 */
	}

	function fixedUpdate() {
		var left = if (Key.isDown(Key.LEFT)) 1 else 0;
		var right = if (Key.isDown(Key.RIGHT)) 1 else 0;
		var up = if (Key.isDown(Key.UP)) 1 else 0;
		var down = if (Key.isDown(Key.DOWN)) 1 else 0;

		var speed = 4;
		map.x += speed * (left - right);
		map.y += speed * (up - down);
	}

	override function update(dt:Float) {
		var dfu = dt * fixedUpdateRate;
		fixedUpdateCounter += dfu;
		var fixedUpdateCount = Math.floor(fixedUpdateCounter);
		fixedUpdateCounter %= 1;
		for (i in 0...fixedUpdateCount) {
			fixedUpdate();
		}
	}

	static function main() {
		new Main();
	}
}
