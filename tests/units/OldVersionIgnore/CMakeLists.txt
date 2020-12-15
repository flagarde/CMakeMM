cmmm(VERSION "1.0" GIT_REPOSITORY "flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD)

cmmm_modules_list(URL "https://raw.githubusercontent.com/TestingRepositories/ModulesListTest/" DESTINATION "Modules" IGNORE_NEW_VERSION)

include(Module)

if(NOT ${NAME} STREQUAL "Module.cmake")
  message(FATAL_ERROR "NAME should be \"Module.cmake\" ! it's ${NAME}")
endif()
