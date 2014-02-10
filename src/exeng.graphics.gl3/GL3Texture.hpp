/**
 * @file GL3Texture.hpp
 * @brief Definition of the OpenGL 3 Texture class
 */


/*
 * Copyright (c) 2013 Felipe Apablaza.
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution.
 */


#ifndef __EXENG_GRAPHICS_GL3_GL3TEXTURE_HPP__
#define __EXENG_GRAPHICS_GL3_GL3TEXTURE_HPP__

#include <exeng/HeapBuffer.hpp>
#include <exeng/graphics/Texture.hpp>
#include "GL3.hpp"

namespace exeng {
namespace graphics {
namespace gl3 {

class GL3Texture : public Texture {
public:
    GL3Texture(ResourceFactory *factory, 
               TextureType type, 
               exeng::math::Vector3i size, 
               const ColorFormat &colorFormat);
    
    virtual ~GL3Texture();

    virtual void* lock();
    
    virtual void* lock(TextureCubeMapFace Face);
    
    virtual void unlock();
    
    virtual TextureType getType() const;
    
    virtual ColorFormat getColorFormat() const;
    
    virtual exeng::math::Vector3i getSize() const;
    
    virtual void release();
    
    inline GLuint getTextureId() const {
        return this->textureId;
    }
    
    virtual TypeInfo getTypeInfo() const;
    
private:
    GLuint textureId;
    TextureType type;
    ColorFormat colorFormat;
    exeng::math::Vector3i size;
    HeapBuffer buffer;
    void* textureData;
    GLenum textureTarget;
    GLenum internalFormat;
};

}
}
}

#endif  //__EXENG_GRAPHICS_GL3_TEXTURE_HPP__