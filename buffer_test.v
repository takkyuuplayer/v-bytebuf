module bytebuf

fn test_bytes() {
	b1 := new([]byte{})

	assert b1.bytes() == []

	mut b2 := new([byte(1), 2, 3])

	assert b2.bytes() == [byte(1), 2, 3]

	b2.off = 1

	assert b2.bytes() == [byte(2), 3]
}

fn test_string() {
	b1 := new([]byte{})

	assert b1.str() == ''

	mut b2 := new([byte(`a`), `b`, `c`])

	assert b2.str() == 'abc'

	b2.off = 1

	assert b2.str() == 'bc'
}

fn test_len() {
	b1 := Buffer{}

	assert b1.len() == 0

	mut b2 := Buffer{
		buf: [byte(`a`), `b`, `c`]
	}

	assert b2.len() == 3

	b2.off = 1

	assert b2.len() == 2
}

fn test_cap() {
	b1 := new([]byte{})

	assert b1.cap() == 0

	mut b2 := new([byte(`a`), `b`, `c`])

	assert b2.cap() == 3

	b2.off = 1

	assert b2.cap() == 3
}

fn test_reset() {
	mut b1 := new([byte(`a`), `b`, `c`])
	b1.off = 1
	b1.reset()

	assert b1 == Buffer{}
}

fn test_write() ? {
	mut b1 := new([]byte{})
	b1.write('abc'.bytes())?

	assert b1.str() == 'abc'
	assert b1.buf.len == 3
	assert b1.buf.cap == 64

	b1.write('def'.bytes())?

	assert b1.str() == 'abcdef'
	assert b1.buf.len == 6
	assert b1.buf.cap == 64

	b1.write('xyz'.bytes().repeat(100))?

	assert b1.str() == 'abcdef' + 'xyz'.repeat(100)
	assert b1.buf.len == 306
}
