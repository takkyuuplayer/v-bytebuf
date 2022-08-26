module bytebuf

// small_buffer_size is an initial allocation minimal capacity.
const small_buffer_size = 64

const max_int = int(~u32(0) >> 1)

pub const err_too_large = error('bytebuf.Buffer: too large')

// A bytebuf.Buffer is a variable-sized buffer of bytes with Write methods.
// No Read methods yet!
// The zero value for Buffer is an empty buffer ready to use.
pub struct Buffer {
mut:
	off int
	buf []byte
}

pub fn (b Buffer) bytes() []byte {
	return b.buf[b.off..]
}

pub fn (b Buffer) str() string {
	return b.buf[b.off..].bytestr()
}

pub fn (b Buffer) len() int {
	return b.buf.len - b.off
}

pub fn (b Buffer) cap() int {
	return b.buf.cap
}

pub fn (mut b Buffer) reset() {
	b.buf = b.buf[..0]
	b.off = 0
}

fn (mut b Buffer) try_grow_by_reslice(n int) ?int {
	l := b.buf.len
	if n <= b.buf.cap - l {
		unsafe { b.buf.grow_len(n) }
		return l
	}
	return error('not possible')
}

fn (mut b Buffer) try_grow(n int) ?int {
	m := b.len()
	// If buffer is empty, reset to recover space.
	if m == 0 && b.off != 0 {
		b.reset()
	}
	// Try to grow by means of a reslice.
	if i := b.try_grow_by_reslice(n) {
		return i
	}
	if b.buf == [] && n <= bytebuf.small_buffer_size {
		b.buf = []byte{len: n, cap: bytebuf.small_buffer_size}
		return 0
	}
	c := b.buf.len
	if n <= c / 2 - m {
		// We can slide things down instead of allocating a new
		// slice. We only need m+n <= c to slide, but
		// we instead let capacity get twice as large so we
		// don't spend all our time copying.
		copy(mut b.buf, b.buf[b.off..])
	} else if c > bytebuf.max_int - c - n {
		return bytebuf.err_too_large
	} else {
		// Not enough space anywhere, we need to allocate.
		mut buf := []byte{len: 2 * c + n}
		copy(mut buf, b.buf[b.off..])
		b.buf = buf
	}
	// Restore b.off and b.buf.len
	b.off = 0
	b.buf = b.buf[..(m + n)]
	return m
}

fn (mut b Buffer) grow(n int) ? {
	if n < 0 {
		return error('bytebuf.Buffer.grow: negative count')
	}
	m := b.try_grow(n)?
	b.buf = b.buf[..m]
}

pub fn (mut b Buffer) write(p []byte) ?int {
	m := b.try_grow_by_reslice(p.len) or { b.try_grow(p.len)? }
	return copy(mut b.buf[m..], p)
}

// new creates and initializes a new Buffer using buf as its
// initial contents. The new Buffer takes ownership of buf, and the
// caller should not use buf after this call. NewBuffer is intended to
// prepare a Buffer to read existing data. It can also be used to set
// the initial size of the internal buffer for writing. To do that,
// buf should have the desired capacity but a length of zero.
//
// In most cases, new(Buffer) (or just declaring a Buffer variable) is
// sufficient to initialize a Buffer.
pub fn new(buf []byte) Buffer {
	return Buffer{
		buf: buf
	}
}
