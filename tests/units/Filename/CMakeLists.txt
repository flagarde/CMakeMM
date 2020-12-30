cmmm_modules_list(GIT_REPOSITORY "TestingRepositories/ModulesListTest/" DESTINATION "Modules" FILENAME "ModulesList2")

include(Module2)

if(NOT ${NAME} STREQUAL "Module2.cmake")
  message(FATAL_ERROR "NAME should be \"Module2.cmake\" ! it's ${NAME}")
endif()
