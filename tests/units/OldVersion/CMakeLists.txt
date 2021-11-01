cmake_minimum_required(VERSION 3.16...3.19)

# include latest version
include(${GET_CMAKEMM_PATH}/GetCMakeMM.cmake)

project(TestCMakeMM LANGUAGES NONE)

cmmm(VERSION "2.1" REPOSITORY "flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD)

cmmm_modules_list(REPOSITORY "TestingRepositories/ModulesListTest/" DESTINATION "Modules")

include(Module)

if(NOT ${NAME} STREQUAL "Module.cmake")
  message(FATAL_ERROR "NAME should be \"Module.cmake\" ! it's ${NAME}")
endif()
