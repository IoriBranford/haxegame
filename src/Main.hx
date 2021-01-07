class Main extends hxd.App {
	override function init() {
		hxd.Res.initEmbed();
		var spriteDict = new SpriteDict();
		var map = TiledMap.fromFile("stage_inebriator.json", spriteDict, s2d);
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

	static function main() {
		new Main();
	}
}
