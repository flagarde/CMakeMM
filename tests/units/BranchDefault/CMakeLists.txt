cmmm_modules_list(GIT_REPOSITORY "TestingRepositories/ModulesListTest/" DESTINATION "Modules" BRANCH "main")

include(Module)

if(NOT ${NAME} STREQUAL "Module.cmake")
  message(FATAL_ERROR "NAME should be \"Module.cmake\" ! it's ${NAME}")
endif()
