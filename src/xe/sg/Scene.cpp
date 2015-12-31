
/**
 * @file Scene.cpp
 * @brief Scene class implementation.
 */


/*
 * Copyright (c) 2013 Felipe Apablaza.
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution.
 */

#include "Scene.hpp"

#include <list>
#include <map>
#include <memory>
#include <sstream>
#include <xe/Vector.hpp>
#include <xe/Exception.hpp>
#include <xe/sg/SceneNode.hpp>
#include <xe/sg/Camera.hpp>
#include <xe/sg/Light.hpp>

namespace xe { namespace sg {
    using namespace xe;
    using namespace xe::gfx;
    using namespace xe::sg;

    struct Scene::Private {
        Vector4f backColor = {0.0f, 0.0f, 0.0f, 1.0f};
        
        std::list<SceneNode*> cameraNodes;
        std::list<SceneNode*> lightNodes;

        SceneNode rootNode;
        
        std::list<std::unique_ptr<Light>> lights;
        std::list<std::unique_ptr<Camera>> cameras;

		// Core *core = nullptr;

		Private() : rootNode("root") {
		}
    };
    
    Scene::Scene(/*Core *core*/) {
		this->impl = new Scene::Private();
		// this->impl->core = core;
	}

    Scene::~Scene() {
		delete this->impl;
	}
    
    SceneNode* Scene::getRootNode() {
        assert(this->impl != nullptr);
        return &this->impl->rootNode;
    }

    const SceneNode* Scene::getRootNode() const {
        assert(this->impl != nullptr);
        return &this->impl->rootNode;
    }
    
    void Scene::setBackColor(const Vector4f &color) {
        assert(this->impl != nullptr);
        this->impl->backColor = color;
    }

    Vector4f Scene::getBackColor() const {
        assert(this->impl != nullptr);
        return this->impl->backColor;
    }

    Camera* Scene::createCamera() {
        assert(this->impl != nullptr);

        Camera* camera = new Camera();

        this->impl->cameras.push_back(std::unique_ptr<Camera>(camera));

        return camera;
    }

    Light* Scene::createLight() {
        assert(this->impl != nullptr);

        Light* light = new Light();

        this->impl->lights.push_back(std::unique_ptr<Light>(light));
        
        return light;
    }

    SceneNode* Scene::createSceneNode(const std::string &nodeName, SceneNodeData* nodeData) 
    {
        assert(this->impl != nullptr);
        
        std::list<SceneNode*> *nodes = nullptr;
        
        SceneNode *sceneNode = this->getRootNode()->addChild(nodeName);
        sceneNode->setData(nodeData);
        
        if (nodeData->getTypeInfo() == TypeId<Camera>()) {
            nodes = &this->impl->cameraNodes;
        }
        
        if (nodeData->getTypeInfo() == TypeId<Light>()) {
            nodes = &this->impl->lightNodes;
        }
        
        if (nodes) {
            nodes->push_back(sceneNode);
        }
        
        return sceneNode;
    }

	Camera* Scene::getCamera(int index) const {
#if defined(EXENG_DEBUG)
		if (index < 0 || index >= this->getCameraCount()) {
			EXENG_THROW_EXCEPTION("Camera index out of bounds.");
		}
#endif
		auto cameraIt = this->impl->cameras.begin();
		std::advance(cameraIt, index);

		return cameraIt->get();
	}

	int Scene::getCameraCount() const {
		return this->impl->cameras.size();
	}
}}