
#ifndef __EXENG_UTIL_MESSAGEBOX_HPP__
#define __EXENG_UTIL_MESSAGEBOX_HPP__

#include <string>
#include <xe/Enum.hpp>
#include <xe/Config.hpp>

namespace xe { namespace util {

	struct MessageBoxIcon : public Enum {
		enum Enum {
			Information,
			Exclamation,
			Error
		};
	};

	class EXENGAPI MessageBox {
	public:
		static void show(const std::string &title, const std::string &message, MessageBoxIcon::Enum icon);

	private:
		MessageBox() = delete;
	};
}}

#endif	// __EXENG_UTIL_MESSAGEBOX_HPP__
