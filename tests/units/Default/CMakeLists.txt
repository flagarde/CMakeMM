cmmm_modules_list(URL "https://raw.githubusercontent.com/TestingRepositories/ModulesListTest/" DESTINATION "Modules")

include(Module)

if(NOT ${NAME} STREQUAL "Module.cmake")
  message(FATAL_ERROR "NAME should be \"Module\" ! it's ${NAME}")
endif()
