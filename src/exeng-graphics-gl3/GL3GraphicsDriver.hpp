/**
 * @file GL3GraphicsDriver.hpp
 * @brief Definition of the GL3 Graphics Driver class.
 */


/*
 * Copyright (c) 2013 Felipe Apablaza.
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution.
 */

#ifndef __EXENG_GRAPHICS_GL3_GRAPHICSDRIVER_HPP__
#define __EXENG_GRAPHICS_GL3_GRAPHICSDRIVER_HPP__

#include <list>

#include <exeng/graphics/GraphicsDriverBase.hpp>
#include <exeng/graphics/VertexFormat.hpp>

#include "GL3Texture.hpp"
#include "GL3VertexBuffer.hpp"
#include "GL3IndexBuffer.hpp"
#include "GL3ShaderProgram.hpp"

namespace exeng {
    namespace graphics {
        namespace gl3 {
            
            /**
             * @brief GraphicsDriver implemented using OpenGL 3.x
             */
            class GL3GraphicsDriver : public GraphicsDriverBase {    
            public:  
                GL3GraphicsDriver();
                
                virtual ~GL3GraphicsDriver();
                
                virtual void initialize(const DisplayMode &displayMode);
                
                virtual void terminate();
                
                virtual bool isInitialized() const;
                
                virtual void beginFrame(const Color &color, ClearFlags::Flags flags) ;
                
                virtual void endFrame();
                
                virtual void setVertexBuffer(const VertexBuffer* vertexBuffer);
                
                virtual void setIndexBuffer(const IndexBuffer* indexBuffer);
                
                virtual void setMaterial(const Material* material);
                
                virtual VertexBuffer* createVertexBuffer(const VertexFormat &vertexFormat, int vertexCount);
                
                virtual IndexBuffer* createIndexBuffer( IndexFormat IndexFormat, int IndexCount  );
                
                virtual Texture* createTexture(TextureType TextureType, const exeng::math::Vector3f& TextureSize);
                
                virtual void setTransform(Transform transform, const exeng::math::Matrix4f& matrix);
                
                virtual void setViewport(const exeng::math::Rectf& viewport);
                
                virtual void render(exeng::graphics::Primitive::Enum primitiveType, int vertexCount);
                
                virtual void pollEvents();
                
                virtual void addEventHandler(exeng::input::IEventHandler *handler);
                
                virtual void removeEventHandler(exeng::input::IEventHandler *handler);
                
                virtual void setDisplayMode(const DisplayMode &displayMode);
                
                virtual DisplayMode getDisplayMode() const;
                
                virtual void restoreDisplayMode();
                
                virtual const VertexBuffer* getVertexBuffer() const;
                
                virtual const IndexBuffer* getIndexBuffer() const;
                
                virtual Shader* createShader( ShaderType type );
                
                virtual ShaderProgram* createShaderProgram( );
                
                virtual void setShaderProgram(const ShaderProgram *program);
                
                /**
                 * @brief preRenderMaterial
                 * @param Apply the render states of the material
                 */
                void preRenderMaterial(const Material &material);
                
                /**
                 * @brief postRenderMaterial
                 * @param Restore render state to originals
                 */
                void postRenderMaterial(const Material &material);
                
            private:
                std::list<exeng::input::IEventHandler*> eventHandlers;
                
                const GL3VertexBuffer *vertexBuffer;
                const GL3ShaderProgram *shaderProgram;
                
                bool initialized;
                
            private:
                static int initializedCount;
            };
        }
    }
}

#endif  // __EXENG_GRAPHICS_GL3_GRAPHICSDRIVER_HPP__
