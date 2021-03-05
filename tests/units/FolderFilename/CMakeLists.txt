cmake_minimum_required(VERSION 3.16...3.19)

# include latest version
include(../../../GetCMakeMM.cmake)

project(TestCMakeMM VERSION "1.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

cmmm(VERSION "master" REPOSITORY "flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD)

cmmm_modules_list(GIT_REPOSITORY "TestingRepositories/ModulesListTest" DESTINATION "Modules" FOLDER "List" FILENAME "ModulesList2")

include(Module4)

if(NOT ${NAME} STREQUAL "Module4.cmake")
  message(FATAL_ERROR "NAME should be \"Module4.cmake\" ! it's ${NAME}")
endif()
