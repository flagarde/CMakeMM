cmake_minimum_required(VERSION 3.15)

project(CMakeMM VERSION "2.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

option(BUILD_TESTS "Build the tests." OFF)
option(BUILD_DOCS "Build the docs." OFF)

include("${CMAKE_CURRENT_SOURCE_DIR}/GetCMakeMM.cmake")

if(BUILD_DOCS)
  # Download itself and use the modules to build the documentations.
  cmmm()
  cmmm_modules_list(REPOSITORY "flagarde/CMakeCM")
  include(Documentations)
endif()

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()
