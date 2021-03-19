cmake_minimum_required(VERSION 3.15)

project(CMakeMM VERSION "1.1" DESCRIPTION "" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

option(CMAKEMM_TEST "Run tests" OFF)

if(CMAKEMM_TEST)
  add_subdirectory(tests)
endif()
