
# Simple C++ Wrapper over libxml2

find_package(libxml2 REQUIRED)

IF(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64") 
    ADD_DEFINITIONS(-fPIC) 
ENDIF()

INCLUDE_DIRECTORIES(${LIBXML2_INCLUDE_DIRS})

ADD_LIBRARY(xmlpp Document.hpp Document.cpp NodeRef.hpp NodeRef.cpp)

SET_PROPERTY(TARGET xmlpp PROPERTY CXX_STANDARD 14)
