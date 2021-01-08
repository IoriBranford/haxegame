import hxd.Key;

class GameplayState extends AppState {
	var map:TiledMap;

	override function init() {
		map = TiledMap.fromFile("stage_inebriator.json", Main.app.s2d);
	}

	override function dispose() {
		Tiled.clearCached();
	}

	override function fixedUpdate() {
		var left = if (Key.isDown(Key.LEFT)) 1 else 0;
		var right = if (Key.isDown(Key.RIGHT)) 1 else 0;
		var up = if (Key.isDown(Key.UP)) 1 else 0;
		var down = if (Key.isDown(Key.DOWN)) 1 else 0;

		var speed = 4;
		map.x += speed * (left - right);
		map.y += speed * (up - down);
	}

	override function update(dfu:Float) {}
}
