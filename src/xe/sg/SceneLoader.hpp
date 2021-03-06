/**
 * @file SceneLoader.hpp
 * @brief Declare the SceneLoader abstract class.
 */


/*
 * Copyright (c) 2013 Felipe Apablaza.
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution.
 */

#ifndef __EXENG_SCENEGRAPH_SCENELOADER_HPP__
#define __EXENG_SCENEGRAPH_SCENELOADER_HPP__

#include <xe/Config.hpp>
#include <xe/sg/Scene.hpp>

#include <xe/Forward.hpp>
#include <xe/sys/Forward.hpp>
#include <xe/sg/Forward.hpp>
#include <xe/gfx/Forward.hpp>

namespace xe { namespace sg {
	class EXENGAPI SceneLoader {
	public:
		explicit SceneLoader(Core *core);

		virtual ~SceneLoader();
		virtual ScenePtr load(const std::string &file) = 0;
		virtual bool isSupported(const std::string &file) = 0;

		Core* getCore();

	private:
		Core *core = nullptr;
	};
}}

#endif
