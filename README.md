# v-bytebuf

![CI](https://github.com/takkyuuplayer/v-bytebuf/workflows/CI/badge.svg)

Port of Go's bytes.Buffer

```
import takkyuuplayer.bytebuf

fn main() {
	mut buf := bytebuf.Buffer{}
	buf.write('abc'.bytes()) ?

	println(buf.str()) // Output: abc
}
```
