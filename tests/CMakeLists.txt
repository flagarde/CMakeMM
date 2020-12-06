cmake_minimum_required(VERSION 3.16...3.19)

project(CMakeMM VERSION "1.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

include(../GetCMakeMM.cmake)

cmmm(VERSION "1.0" GIT_REPOSITORY "flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD)

cmmm_modules_list(URL "https://raw.githubusercontent.com/flagarde/CMakeCM"
                  FILENAME ModulesList
                  DESTINATION "Modules")
include(Messages)

message(INFO "Tests")
