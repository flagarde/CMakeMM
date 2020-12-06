cmmm(VERSION "1.3" GIT_REPOSITORY "flagarde/CMakeMM" DESTINATION "CMakeMM" ALWAYS_DOWNLOAD)

cmmm_modules_list(URL "https://raw.githubusercontent.com/TestingRepositories/ModulesListTest/" DESTINATION "Modules")

include(Module)

if(NOT ${NAME} STREQUAL "Module.cmake")
  message(FATAL_ERROR "NAME should be \"Module.cmake\" ! it's ${NAME}")
endif()
