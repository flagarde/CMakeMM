function(cmmm_changes CHANGELOG_VERSION)
  if(${CMMM_VERSION} VERSION_LESS ${CHANGELOG_VERSION})
    message("${BoldYellow}## [CMakeMM] - Changes in ${CHANGELOG_VERSION}: ##${Reset}")
    foreach(CMMM_CHANGE IN LISTS ARGN)
      message("${BoldYellow}## [CMakeMM] - ${CMMM_CHANGE} ##${Reset}")
    endforeach()
  endif()
endfunction()

function(print_changelog)
  if(NOT ${CMMM_VERSION} STREQUAL ${CMMM_LATEST_VERSION})
    message("${BoldYellow}## [CMakeMM] You are using CMakeMM version ${CMMM_VERSION}. The latest is ${CMMM_LATEST_VERSION}. ##${Reset}")
    message("${BoldYellow}## [CMakeMM] Changes since ${CMMM_VERSION} include the following : ##${Reset}")
  endif()
  changelog()
  if(NOT ${CMMM_VERSION} STREQUAL ${CMMM_LATEST_VERSION})
    message("${BoldYellow}## [CMakeMM] To update, simply change the value of VERSION in cmmm function. ##${Reset}")
    message("${BoldYellow}## [CMakeMM] You can disable these messages by setting IGNORE_NEW_VERSION in cmmm function. ##${Reset}")
  endif()
endfunction()

function(check_bootstrap)
  if(NOT DEFINED CMMM_BOOTSTRAP_VERSION OR CMMM_BOOTSTRAP_VERSION LESS 2)
    message("${BoldYellow}## [CMakeMM] NOTE: GetCMakeMM.cmake has changed ! Please download a new GetCMakeMM.cmake from the CMakeMM repository. ##${Reset}")
  endif()
endfunction()

function(changelog)
  cmmm_changes(1.0
               "Initial Version"
              )
  cmmm_changes(1.1
               "Some cleaning" "use VERBOSITY"
              )
endfunction()
