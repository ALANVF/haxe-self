This is a basic implementation of [Self](https://en.wikipedia.org/wiki/Self_(programming_language)) in Haxe, based on [this](https://dada.cs.washington.edu/htbin-post/unrestricted/cecil/cvsweb.cgi/vortex/Cecil/src/contrib/Self/) old implementation in [Cecil](https://en.wikipedia.org/wiki/Cecil_(programming_language)) with a few extra features like floats.

Note that this is a minimal implementation, and does not feature a full standard library. That being said, I've tried designing and documenting this implementation enough that it can be easily extendable by anyone.

## To run this yourself

You will need Haxe 4.2 or newer (I used 4.2.3).

Install `haxe-strings` from haxelib and run `haxe build.hxml` from the project directory.

This should theoretically work on all `sys` targets except Java.