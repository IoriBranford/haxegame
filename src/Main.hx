class Main extends hxd.App {
	var fixedUpdateCounter = 0.0;
	var fixedUpdateRate = 60.0;
	var appState:AppState;

	public var nextState:AppState = null;

	public static var app(default, null):Main;

	override function new() {
		super();
	}

	override function init() {
		app = this;
		hxd.Res.initEmbed();
		appState = new GameplayState();
		appState.init();
	}

	override function update(dt:Float) {
		var dfu = dt * fixedUpdateRate;
		fixedUpdateCounter += dfu;
		var fixedUpdateCount = Math.floor(fixedUpdateCounter);
		fixedUpdateCounter %= 1;

		for (i in 0...fixedUpdateCount) {
			appState.fixedUpdate();
		}
		appState.update(dfu);

		if (nextState != null) {
			appState.dispose();
			appState = nextState;
			appState.init();
		}
	}

	static function main() {
		new Main();
	}
}
