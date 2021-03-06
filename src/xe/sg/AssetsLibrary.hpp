
#ifndef __EXENG_SCENEGRAPH_ASSETLIBRARY_HPP__
#define __EXENG_SCENEGRAPH_ASSETLIBRARY_HPP__

#include <string>
#include <memory>
#include <xe/Config.hpp>
#include <xe/Buffer.hpp>

namespace xe { namespace sg {

	class EXENGAPI AssetLibrary {
	public:
		AssetLibrary();
		~AssetLibrary();

		void addAsset(const std::string &fileId, void* data, const int dataSize);
		void addAsset(const std::string &fileId, BufferPtr assetData);
		Buffer* getAsset(const std::string &fileId);
		const Buffer* getAsset(const std::string &fileId) const;

	private:
		struct Private;
		Private *impl = nullptr;
	};

	typedef std::unique_ptr<AssetLibrary> AssetLibraryPtr;
}}

#endif	// __EXENG_SCENEGRAPH_ASSETLIBRARY_HPP__
