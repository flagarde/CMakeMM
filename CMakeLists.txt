cmake_minimum_required(VERSION 3.15)

project(CMakeMM VERSION "2.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

option(BUILD_TESTS "Build the tests." OFF)

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()
