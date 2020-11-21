cmake_minimum_required(VERSION 3.16...3.19)

project(CMakeMM VERSION "1.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

include(../../../GetCMakeMM.cmake)

cmmm(VERSION "1.1" URL "https://raw.githubusercontent.com/flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD VERBOSITY DEBUG)

cmmm_modules_list(URL "https://raw.githubusercontent.com/flagarde/CMakeCM" DESTINATION "Modules")

include(Messages)

message(INFO "Tests")
