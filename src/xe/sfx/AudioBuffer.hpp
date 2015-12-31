/**
 * @file
 * @desc
 */
 
 /*
 * Copyright (c) 2013 Felipe Apablaza.
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution.
 */


#ifndef __EXENG_AUDIO_BUFFER_HPP__
#define __EXENG_AUDIO_BUFFER_HPP__

#include <xe/Object.hpp>

namespace xe { namespace sfx {

	struct AudioBufferFormat {};

	class EXENGAPI Buffer : public Object {
	public:
		virtual ~Buffer() {};
		virtual AudioBufferFormat getFormat() const = 0;
	};
}}

#endif	//__EXENG_AUDIO_BUFFER_HPP__