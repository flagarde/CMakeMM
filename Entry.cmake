function(cmmm_download)
  cmake_parse_arguments(CMMM "" "URL;DESTINATION" "" "${ARGN}")
  get_property(CMMM_GIT_URL_RELEASE GLOBAL PROPERTY CMMM_GIT_URL_RELEASE)
  set(CMMM_DESTINATION_TMP "${CMMM_DESTINATION}.tmp")

  # Guard against multiple processes trying to use the PMM dir simultaneously
  file(LOCK "${CMMM_DESTINATION}.lock" GUARD PROCESS TIMEOUT 0 RESULT_VARIABLE CMMM_LOCK)
  if(NOT ${CMMM_LOCK} STREQUAL "0")
    if(${CMMM_VERBOSITY} STREQUAL VERBOSE)
      message("${BoldYellow}## [CMakeMM] Fail to lock the directory ${CMMM_DESTINATION} (${CMMM_LOCK}). ##${Reset}")
    endif()
  else()
    if(${CMMM_VERBOSITY} STREQUAL DEBUG)
      message("${BoldGreen}** [CMakeMM] Directory ${CMMM_DESTINATION} locked successfully. **${Reset}")
    endif()
  endif()

  message("${BoldMagenta}-- [CMakeMM] Downloading ${CMMM_URL}\n   From : ${CMMM_GIT_URL_RELEASE}/${CMMM_URL}\n   To   : ${CMMM_DESTINATION} --${Reset}")

  file(DOWNLOAD "${CMMM_GIT_URL_RELEASE}/${CMMM_URL}" "${CMMM_DESTINATION_TMP}" STATUS CMMM_STATUS  TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
  list(GET CMMM_STATUS 0 CMMM_RC)
  list(GET CMMM_STATUS 1 CMMM_MSG)
  if(CMMM_RC)
    file(REMOVE "${CMMM_DESTINATION_TMP}")
    if(NOT EXISTS "${CMMM_DESTINATION}")
      message("${BoldRed}!! Error while downloading file '${CMMM_URL}' to '${CMMM_DESTINATION}' [${CMMM_RC}]: ${CMMM_MSG} !!${Reset}")
      message(FATAL_ERROR)
    endif()
  else()
    file(RENAME "${CMMM_DESTINATION_TMP}" "${CMMM_DESTINATION}")
  endif()

  # Unlock the lock
  file(LOCK "${CMMM_DESTINATION}.lock" RESULT_VARIABLE CMMM_LOCK RELEASE)
  if(NOT ${CMMM_LOCK} STREQUAL "0")
    if(${CMMM_VERBOSITY} STREQUAL VERBOSE)
      message("${BoldYellow}## [CMakeMM] Fail to unlock the directory ${CMMM_DESTINATION} (${CMMM_LOCK}). ##${Reset}")
    endif()
  else()
    if(${CMMM_VERBOSITY} STREQUAL DEBUG)
      message("${BoldGreen}** [CMakeMM] Directory ${CMMM_DESTINATION} unlocked successfully. **${Reset}")
    endif()
  endif()
endfunction()

macro(cmmm_check_and_include_file CMMM_FILENAME)
  get_filename_component(CMMM_FILE_DESTINATION "${CMMM_DESTINATION}/${CMMM_FILENAME}" ABSOLUTE)
  if(NOT EXISTS "${CMMM_FILE_DESTINATION}" OR CMMM_ALWAYS_DOWNLOAD)
    cmmm_download(URL "${CMMM_FILENAME}" DESTINATION "${CMMM_FILE_DESTINATION}")
  endif()
  include("${CMMM_FILE_DESTINATION}")
endmacro()

# Do the update check.

function(cmmm_changes CHANGELOG_VERSION)
  message("${BoldYellow}## [CMakeMM] - Changes in ${CHANGELOG_VERSION} : ##${Reset}")
  foreach(CMMM_CHANGE IN LISTS ARGN)
    message("${BoldYellow}## [CMakeMM] - ${CMMM_CHANGE} ##${Reset}")
  endforeach()
endfunction()

function(print_changelog)
  if(NOT ${CMMM_VERSION} STREQUAL ${CMMM_LATEST_VERSION})
    message("${BoldYellow}## [CMakeMM] Using CMakeMM version ${CMMM_VERSION}. The latest is ${CMMM_LATEST_VERSION}. ##${Reset}")
    message("${BoldYellow}## [CMakeMM] Changes since ${CMMM_VERSION} include the following : ##${Reset}")
    changelog()
    message("${BoldYellow}## [CMakeMM] To update, simply change the value of VERSION in cmmm function. ##${Reset}")
    message("${BoldYellow}## [CMakeMM] You can disable these messages by setting IGNORE_NEW_VERSION in cmmm function. ##${Reset}")
  endif()
endfunction()

function(check_bootstrap)
  if(NOT DEFINED CMMM_BOOTSTRAP_VERSION OR CMMM_BOOTSTRAP_VERSION LESS 1)
    message("${BoldYellow}## [CMakeMM] GetCMakeMM.cmake has changed ! Please download a new GetCMakeMM.cmake from the CMakeMM repository. ##${Reset}")
  endif()
endfunction()

function(cmmm_check_updates)
  cmake_parse_arguments(CMMM "IGNORE_NEW_VERSION" "" "" ${ARGN})
  get_property(CMMM_GIT_REPOSITORY GLOBAL PROPERTY CMMM_GIT_URL_RELEASE)
  set(CMMM_GIT_URL "https://raw.githubusercontent.com/${CMMM_GIT_URL_RELEASE}/master/")
  # LatestVersion and Changelog must be up-to-date so must be in master
  set(CMMM_LATEST_VERSION_URL "${CMMM_GIT_URL}/LatestVersion.cmake")
  set(CMMM_LATEST_VERSION_FILE "${CMMM_DESTINATION}/LatestVersion.cmake")
  file(DOWNLOAD "${CMMM_LATEST_VERSION_URL}" "${CMMM_LATEST_VERSION_FILE}" STATUS CMMM_STATUS TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
  set(CMMM_CHANGELOG_FILE "${CMMM_DESTINATION}/Changelog.cmake")
  list(GET CMMM_STATUS 0 CMMM_RC)
  if(CMMM_RC EQUAL 0)
    include("${CMMM_LATEST_VERSION_FILE}")
    if(${CMMM_VERSION} VERSION_LESS ${CMMM_LATEST_VERSION})
      if(NOT ${CMMM_IGNORE_NEW_VERSION})
        set(CMMM_CHANGELOG_URL  "${CMMM_GIT_URL}/Changelog.cmake")
        cmmm_download(URL "${CMMM_CHANGELOG_URL}" DESTINATION "${CMMM_CHANGELOG_FILE}")
        include("${CMMM_CHANGELOG_FILE}")
        print_changelog()
        check_bootstrap()
      endif()
    endif()
  elseif(NOT CMMM_IGNORE_NEW_VERSION AND EXISTS "${CMMM_CHANGELOG_FILE}")
    message("${BoldYellow}** Failed to check for updates (Couldn't download ${CMMM_LATEST_VERSION_URL}) **${Reset}")
  endif()
endfunction()

function(cmmm_entry)
  cmmm_check_updates()
  cmmm_check_and_include_file(CMakeMM.cmake)
endfunction()
