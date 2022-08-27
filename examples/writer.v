import examples.bytebuf

fn main() {
	mut buf := bytebuf.Buffer{}
	buf.write('abc'.bytes())?

	println(buf.str()) // Output: abc
}
