
#ifndef __EXENG_GRAPHICS_MESHSUBSETBASE_HPP__
#define __EXENG_GRAPHICS_MESHSUBSETBASE_HPP__

#include <exeng/graphics/MeshSubset.hpp>
#include <memory>
#include <vector>

namespace exeng { namespace graphics {
    class MeshSubsetBase : public MeshSubset {
    public:
        MeshSubsetBase(std::vector<std::unique_ptr<Buffer>> vertexBuffers, const VertexFormat &vertexFormat);

        virtual VertexFormat getVertexFormat() const override;
        virtual IndexFormat::Enum getIndexFormat() const override;

        virtual int getBufferCount() const override;
        virtual Buffer* getBuffer(const int index) override;
        virtual const Buffer* getBuffer(const int index) const override;

        virtual Buffer* getIndexBuffer() override;
        virtual const Buffer* getIndexBuffer() const override;

    protected:
        std::vector<std::unique_ptr<Buffer>> buffers;
        std::unique_ptr<Buffer> indexBuffer;
        VertexFormat vertexFormat;
        IndexFormat::Enum indexFormat = IndexFormat::Index32;
    };

    inline MeshSubsetBase::MeshSubsetBase(std::vector<std::unique_ptr<Buffer>> buffers_, const VertexFormat &vertexFormat_) : 
        buffers(std::move(buffers_)), vertexFormat(vertexFormat_), indexFormat(IndexFormat::Index32)  {
    }

    inline int MeshSubsetBase::getBufferCount() const {
        return this->buffers.size();
    }

    inline Buffer* MeshSubsetBase::getBuffer(const int index) {
        return this->buffers[index].get();
    }

    inline const Buffer* MeshSubsetBase::getBuffer(const int index) const {
        return this->buffers[index].get();
    }

    inline Buffer* MeshSubsetBase::getIndexBuffer() {
        return this->indexBuffer.get();
    }

    inline const Buffer* MeshSubsetBase::getIndexBuffer() const {
        return this->indexBuffer.get();
    }

    inline VertexFormat MeshSubsetBase::getVertexFormat() const {
        return this->vertexFormat;
    }

    inline IndexFormat::Enum MeshSubsetBase::getIndexFormat() const {
        return this->indexFormat;
    }
}}

#endif
