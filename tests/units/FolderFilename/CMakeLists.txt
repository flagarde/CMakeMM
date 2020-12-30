cmmm_modules_list(GIT_REPOSITORY "TestingRepositories/ModulesListTest/" DESTINATION "Modules" FOLDER "List" FILENAME "ModulesList2")

include(Module4)

if(NOT ${NAME} STREQUAL "Module4.cmake")
  message(FATAL_ERROR "NAME should be \"Module4.cmake\" ! it's ${NAME}")
endif()
