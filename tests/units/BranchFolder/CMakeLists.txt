cmake_minimum_required(VERSION 3.16...3.19)

# include latest version
include(${GET_CMAKEMM_PATH}/GetCMakeMM.cmake)

project(TestCMakeMM LANGUAGES NONE)

cmmm(VERSION "main" REPOSITORY "flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD)

cmmm_modules_list(REPOSITORY "TestingRepositories/ModulesListTest/" DESTINATION "Modules" FOLDER "List" BRANCH "main")

include(Module3)

if(NOT ${NAME} STREQUAL "Module3.cmake")
  message(FATAL_ERROR "NAME should be \"Module3.cmake\" ! it's ${NAME}")
endif()
