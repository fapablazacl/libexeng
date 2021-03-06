
#include "SceneRendererGeneric.hpp"

#include <cassert>
#include <xe/sg/Scene.hpp>
#include <xe/sg/SceneNode.hpp>
#include <xe/sg/Renderable.hpp>

namespace xe { namespace sg {

	SceneRendererGeneric::SceneRendererGeneric(xe::sg::Pipeline *renderer) {
		this->setRenderer(renderer);
	}

	void SceneRendererGeneric::setScene(xe::sg::Scene* scene) {
		assert(scene);
		this->scene = scene;
	}

	xe::sg::Scene* SceneRendererGeneric::getScene() {
		return this->scene;
	}

	const xe::sg::Scene* SceneRendererGeneric::getScene() const {
		return this->scene;
	}

	xe::sg::Pipeline* SceneRendererGeneric::getRenderer() {
		return this->renderer;
	}

	const xe::sg::Pipeline* SceneRendererGeneric::getRenderer() const {
		return this->renderer;
	}

	void SceneRendererGeneric::setRenderer(xe::sg::Pipeline* renderer) {
		this->renderer = renderer;
	}

	void SceneRendererGeneric::renderScene() {
		assert(scene);

		xe::sg::TransformationStack transformStack;

		transformStack.reset(xe::identity<float, 4>());

		this->renderer->beginFrame(this->getScene()->getBackColor());
		this->renderNode(&transformStack, this->getScene()->getRootNode());
		this->renderer->endFrame();
	}

	void SceneRendererGeneric::renderNode(xe::sg::TransformationStack *transformStack, xe::sg::SceneNode* node) {
        assert(transformStack);
		assert(node);

		// std::cout << "SceneRendererGeneric::renderNode(" << node->getName() << ")" << std::endl;

		transformStack->push(node->getTransform());

		xe::sg::Pipeline *renderer = this->getRenderer();
		renderer->setModel(transformStack->top());

		xe::sg::Renderable *renderable = node->getRenderable();
		if (renderable) {
			renderable->renderWith(renderer);
		}

		for (int i=0; i<node->getChildCount(); i++) {
			xe::sg::SceneNode *child = node->getChild(i);
			assert(child);
			this->renderNode(transformStack, child);
		}

		transformStack->pop();
	}
}}
