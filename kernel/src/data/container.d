module data.container;

import data.range;
import memory.allocator;

interface IContainer(E) : OutputRange!E {
	bool remove(size_t index);
	E get(size_t index);
	ref E opIndex(size_t index);
	const(E) opIndex(size_t index) const;

	@property size_t length() const;
	alias opDollar = length;

	void opIndexAssign(E val, size_t index);
	//	RandomFiniteAssignable!E opIndex();
	E[] opIndex();
	E[] opSlice(size_t start, size_t end);

	int opApply(scope int delegate(const E) cb) const;
	int opApply(scope int delegate(ref E) cb);
	int opApply(scope int delegate(size_t, const E) cb) const;
	int opApply(scope int delegate(size_t, ref E) cb);
}

class Vector(E) : IContainer!E {
public:
	this(IAllocator allocator) {
		_allocator = allocator;
	}

	void put(E value) {
		if (_length == _capacity)
			_expand();
		_list[_length++] = value;
	}

	bool remove(size_t index) {
		if (index >= _length)
			return false;

		static if (is(typeof(_list[0].__dtor())))
			_list[index].__dtor();

		for (; index < _length - 1; index++)
			_list[index] = _list[index + 1];
		_list[index] = E.init;
		_length--;
		return true;
	}

	E get(size_t index) {
		assert(index < _length);
		return _list[index];
	}

	ref E opIndex(size_t index) {
		assert(index < _length);
		return _list[index];
	}

	const(E) opIndex(size_t index) const {
		assert(index < _length);
		return cast(const E)_list[index];
	}

	@property size_t length() const {
		return _length;
	}

	void opIndexAssign(E val, size_t index) {
		assert(index < _length);
		_list[index] = val;
	}

	E[] opIndex() {
		return _list[0 .. _length];
	}

	E[] opSlice(size_t start, size_t end) {
		return opIndex()[start .. end];
	}

	int opApply(scope int delegate(const E) cb) const {
		int res;
		for (size_t i = 0; i < _length; i++) {
			res = cb(_list[i]);
			if (res)
				break;
		}
		return res;
	}

	int opApply(scope int delegate(ref E) cb) {
		int res;
		for (size_t i = 0; i < _length; i++) {
			res = cb(_list[i]);
			if (res)
				break;
		}
		return res;
	}

	int opApply(scope int delegate(size_t, const E) cb) const {
		int res;
		for (size_t i = 0; i < _length; i++) {
			res = cb(i, _list[i]);
			if (res)
				break;
		}
		return res;
	}

	int opApply(scope int delegate(size_t, ref E) cb) {
		int res;
		for (size_t i = 0; i < _length; i++) {
			res = cb(i, _list[i]);
			if (res)
				break;
		}
		return res;
	}

private:
	enum _growFactor = 16;
	IAllocator _allocator;

	E[] _list;
	size_t _length;
	size_t _capacity;

	void _expand() {
		_allocator.expandArray(_list, _growFactor);
		_capacity += _growFactor;
	}
}