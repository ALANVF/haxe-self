import runtime.Eval;

class Main {
	static function main() {
		final stdin = Sys.stdin();

		runtime.Globals.build();
		runtime.Primitives.build();

		Sys.setCwd("./self");
		Eval.evalFile("./stdlib.self");

		while(true) {
			Sys.print("> ");
			final code = stdin.readLine();

			if(code == "quit") break;
			
			try {
				final res = Eval.evalCode(code);
				
				Sys.println("");
				Sys.println(res.print(""));
			} catch(eof: Eof) {
				Sys.println("Syntax error: EOF reached");
			} catch(err: String) {
				if(err.startsWith("Syntax error")) {
					Sys.println(err);
				} else {
					Sys.println('Error: $err');
				}
			}
		}
	}
}
