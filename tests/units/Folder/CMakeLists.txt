cmmm_modules_list(URL "https://raw.githubusercontent.com/TestingRepositories/ModulesListTest/" DESTINATION "Modules" FOLDER "List")

include(Module3)

if(NOT ${NAME} STREQUAL "Module3.cmake")
  message(FATAL_ERROR "NAME should be \"Module3.cmake\" ! it's ${NAME}")
endif()
