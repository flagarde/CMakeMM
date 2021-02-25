include_guard(GLOBAL)

if(NOT COMMAND colors)
  # Colorize
  macro(colors)
    if(NOT WIN32)
        string(ASCII 27 Esc)
        set(Reset "${Esc}[m")
        set(BoldRed "${Esc}[1;31m")
        set(BoldMagenta "${Esc}[1;35m")
        set(BoldYellow "${Esc}[1;33m")
        set(BoldGreen "${Esc}[1;32m")
    endif()
  endmacro()
endif()

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

  file(DOWNLOAD "${CMMM_GIT_URL_RELEASE}/${CMMM_URL}" "${CMMM_DESTINATION_TMP}" STATUS CMMM_STATUS TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
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
  if(${CMMM_VERSION} VERSION_LESS ${CHANGELOG_VERSION})
    message("${BoldYellow}## [CMakeMM] - Changes in ${CHANGELOG_VERSION} : ##${Reset}")
    foreach(CMMM_CHANGE IN LISTS ARGN)
      message("${BoldYellow}## [CMakeMM] - ${CMMM_CHANGE} ##${Reset}")
    endforeach()
  endif()
endfunction()

function(print_changelog)
  if(NOT ${CMMM_VERSION} STREQUAL "master" AND NOT ${CMMM_VERSION} STREQUAL "main")
    if(NOT ${CMMM_VERSION} STREQUAL ${CMMM_LATEST_VERSION})
      message("${BoldYellow}## [CMakeMM] Using CMakeMM version ${CMMM_VERSION}. The latest is ${CMMM_LATEST_VERSION}. ##${Reset}")
      message("${BoldYellow}## [CMakeMM] Changes since ${CMMM_VERSION} include the following : ##${Reset}")
      changelog()
      message("${BoldYellow}## [CMakeMM] To update, simply change the value of VERSION in cmmm function. ##${Reset}")
      message("${BoldYellow}## [CMakeMM] You can disable these messages by setting IGNORE_NEW_VERSION in cmmm function. ##${Reset}")
    endif()
  endif()
endfunction()

function(check_bootstrap)
  if(NOT DEFINED CMMM_BOOTSTRAP_VERSION OR CMMM_BOOTSTRAP_VERSION LESS 1)
    message("${BoldYellow}## [CMakeMM] GetCMakeMM.cmake has changed ! Please download a new GetCMakeMM.cmake from the CMakeMM repository. ##${Reset}")
  endif()
endfunction()

function(cmmm_check_updates)
  cmake_parse_arguments(CMMM "IGNORE_NEW_VERSION" "" "" ${ARGN})
  get_property(CMMM_GIT_REPOSITORY GLOBAL PROPERTY CMMM_GIT_REPOSITORY)
  set(CMMM_GIT_URL "https://cdn.jsdelivr.net/gh/${CMMM_GIT_REPOSITORY}@master")
  # LatestVersion and Changelog must be up-to-date so must be in master
  set(CMMM_LATEST_VERSION_URL "${CMMM_GIT_URL}/LatestVersion.cmake")
  set(CMMM_LATEST_VERSION_FILE "${CMMM_DESTINATION}/LatestVersion.cmake")
  file(DOWNLOAD "${CMMM_LATEST_VERSION_URL}" "${CMMM_LATEST_VERSION_FILE}" STATUS CMMM_STATUS TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
  set(CMMM_CHANGELOG_FILE "${CMMM_DESTINATION}/Changelog.cmake")
  list(GET CMMM_STATUS 0 CMMM_RC)
  if(${CMMM_RC} EQUAL 0)
    include("${CMMM_LATEST_VERSION_FILE}")
    if(${CMMM_VERSION} VERSION_LESS ${CMMM_LATEST_VERSION})
      if(NOT ${CMMM_IGNORE_NEW_VERSION})
        set(CMMM_CHANGELOG_URL "${CMMM_GIT_URL}/Changelog.cmake")
        file(DOWNLOAD "${CMMM_CHANGELOG_URL}" "${CMMM_CHANGELOG_FILE}" STATUS CMMM_STATUS TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
        list(GET CMMM_STATUS 0 CMMM_RC)
        if(${CMMM_RC} EQUAL 0)
          include("${CMMM_CHANGELOG_FILE}")
          print_changelog()
          check_bootstrap()
        else()
          message("${BoldYellow}** Error while downloading file ${CMMM_CHANGELOG_URL} **${Reset}")
        endif()
      endif()
    endif()
  else()
    message("${BoldYellow}** Error while downloading file ${CMMM_LATEST_VERSION_URL} **${Reset}")
  endif()
endfunction()

macro(cmmm)
  cmake_parse_arguments(CMMM "ALWAYS_DOWNLOAD;NO_COLOR" "GIT_REPOSITORY;VERSION;DESTINATION;TIMEOUT;INACTIVITY_TIMEOUT;VERBOSITY" "" ${ARGN})

  if(NOT ${CMMM_NO_COLOR})
    colors()
  endif()
  set_property(GLOBAL PROPERTY CMMM_NO_COLOR ${CMMM_NO_COLOR})

  list(
    INSERT
    VERBOSITY
    0
    "FATAL_ERROR"
    "SEND_ERROR"
    "WARNING"
    "AUTHOR_WARNING"
    "DEPRECATION"
    "NOTICE"
    "STATUS"
    "VERBOSE"
    "DEBUG"
    "TRACE"
    )
  if(DEFINED CMMM_VERBOSITY)
    list(FIND VERBOSITY ${CMMM_VERBOSITY} FOUND)
    if(${FOUND} STREQUAL "-1")
      message("${BoldYellow}## [CMakeMM] VERBOSITY ${CMMM_VERBOSITY} unknown. VERBOSITY set to STATUS. ##${Reset}")
      set(CMMM_VERBOSITY "STATUS")
    endif()
  elseif(DEFINED CMAKE_MESSAGE_LOG_LEVEL)
    list(FIND VERBOSITY ${CMAKE_MESSAGE_LOG_LEVEL} FOUND)
    if(${FOUND} STREQUAL "-1")
      message("${BoldYellow}## [CMakeMM] VERBOSITY ${CMAKE_MESSAGE_LOG_LEVEL} unknown. VERBOSITY set to STATUS. ##${Reset}")
      set(CMMM_VERBOSITY "STATUS")
    else()
      set(CMMM_VERBOSITY ${CMAKE_MESSAGE_LOG_LEVEL})
    endif()
  else()
    set(CMMM_VERBOSITY "STATUS")
  endif()
  set_property(GLOBAL PROPERTY CMMM_VERBOSITY ${CMMM_VERBOSITY})

  if(NOT DEFINED CMMM_TIMEOUT)
    set(CMMM_TIMEOUT 10)
  endif()
  set_property(GLOBAL PROPERTY CMMM_TIMEOUT ${CMMM_TIMEOUT})

  if(NOT DEFINED CMMM_INACTIVITY_TIMEOUT)
    set(CMMM_INACTIVITY_TIMEOUT 5)
  endif()
  set_property(GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})

  if(NOT DEFINED CMMM_GIT_REPOSITORY)
    set(CMMM_GIT_REPOSITORY "flagarde/CMakeMM")
    list(APPEND ARGN URL ${CMMM_GIT_REPOSITORY})
  endif()
  set_property(GLOBAL PROPERTY CMMM_GIT_REPOSITORY ${CMMM_GIT_REPOSITORY})

  set(CMMM_GIT_URL_RELEASE "https://github.com/${CMMM_GIT_REPOSITORY}/releases/download/v${CMMM_VERSION}")
  set_property(GLOBAL PROPERTY CMMM_GIT_URL_RELEASE ${CMMM_GIT_URL_RELEASE})

  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/CMakeMM")
  else()
    get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  set(CMMM_DESTINATION "${CMMM_DESTINATION}/${CMMM_VERSION}")
  set_property(GLOBAL PROPERTY CMMM_DESTINATION ${CMMM_DESTINATION})

  # add the CMakeMM installation directory to CMAKE_MODULE_PATH
  list(INSERT CMAKE_MODULE_PATH 0 "${CMMM_DESTINATION}")
  list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  # This will trigger a warning if GetCMakeMM.cmake is not up-to-date ^^^ DO NOT CHANGE THIS LINE vvv
  set(CMMM_BOOTSTRAP_VERSION GET_CMAKEMM_VERSION)
  # ^^^ DO NOT CHANGE THIS LINE ^^^

  cmmm_check_updates()
  include(CMakeMM)

endmacro()
