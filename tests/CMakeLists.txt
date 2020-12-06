cmake_minimum_required(VERSION 3.16...3.19)

project(CMakeMM VERSION "1.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

include(../GetCMakeMM.cmake)

add_subdirectory(units)
