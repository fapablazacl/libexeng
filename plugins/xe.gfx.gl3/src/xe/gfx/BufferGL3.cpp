
#include "BufferGL3.hpp"
#include "BufferStatusGL3.hpp"
#include "DebugGL3.hpp"
#include <stdexcept>

namespace xe { namespace gfx { namespace gl3 {

    BufferGL3::BufferGL3(const int size, GLenum target) {
		this->cacheBuffer = std::make_unique<HeapBuffer>(size);
		this->target = target;

		::glGenBuffers(1, &this->bufferId);
        ::glBindBuffer(this->target, this->bufferId);
        ::glBufferData(this->target, size, nullptr, GL_DYNAMIC_DRAW);

		::glBindBuffer(this->target, 0);

		assert(this->bufferId);

		GL3_CHECK();
	}

    BufferGL3::~BufferGL3() {
		assert(this);
		assert(this->bufferId);

		::glDeleteBuffers(1, &this->bufferId);
	}

    void* BufferGL3::lock(BufferLockMode::Enum mode) {
        
        
        
        
        return nullptr;
    }

    void BufferGL3::unlock() {
        
    }

    const void* BufferGL3::lock() const {
        return nullptr;
    }

    void BufferGL3::unlock() const {
        
    }

	int BufferGL3::getSize() const {
		assert(this);
		assert(this->cacheBuffer.get());

		return this->cacheBuffer->getSize();
	}

	int BufferGL3::getHandle() const {
		assert(this);

		return this->bufferId;
	}

    void BufferGL3::write(const void *data, const int size, const int dataOffset, const int bufferOffset) {
		assert(this);
		assert(this->cacheBuffer.get());

		// BufferStatus status(this->target);

		::glBindBuffer(this->target, this->bufferId);
		::glBufferSubData(this->target, bufferOffset, size, data);
		::glBindBuffer(this->target, 0);

		this->cacheBuffer->write(data, size, dataOffset, bufferOffset);

		GL3_CHECK();
	}

    void BufferGL3::read(void* data, const int size, const int dataOffset, const int bufferOffset) const {
		assert(this);

		this->cacheBuffer->read(data, size, dataOffset, bufferOffset);

		// GL3_CHECK();
	}

	TypeInfo BufferGL3::getTypeInfo() const {
		assert(this);
		
        return TypeId<BufferGL3>();
    }
}}}
