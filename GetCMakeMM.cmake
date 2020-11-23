# Some part of Colors.cmake here to Colorize the output before it has been downloaded
macro(set_colors CMMM_NO_COLOR)
  if(NOT WIN32)
    if(NOT ${CMMM_NO_COLOR})
      string(ASCII 27 Esc)
      set(Reset "${Esc}[m")
      set(BoldRed "${Esc}[1;31m")
      set(BoldMagenta "${Esc}[1;35m")
      set(BoldYellow "${Esc}[1;33m")
      set(BoldGreen "${Esc}[1;32m")
    endif()
  endif()
endmacro()

function(cmmm)
  cmake_parse_arguments(CMMM "ALWAYS_DOWNLOAD;NO_COLOR" "GIT_REPOSITORY;VERSION;DESTINATION;TIMEOUT;INACTIVITY_TIMEOUT;VERBOSITY" "" ${ARGN})

  set_colors(${CMMM_NO_COLOR})
  set_property(GLOBAL PROPERTY CMMM_NO_COLOR ${CMMM_NO_COLOR})

  if(DEFINED CMMM_VERBOSITY)
    if(NOT CMMM_VERBOSITY STREQUAL NOTICE AND NOT CMMM_VERBOSITY STREQUAL STATUS AND NOT CMMM_VERBOSITY STREQUAL VERBOSE AND NOT CMMM_VERBOSITY STREQUAL DEBUG AND NOT CMMM_VERBOSITY STREQUAL TRACE)
      message("${BoldYellow}## [CMakeMM] VERBOSITY ${CMMM_VERBOSITY} unknown. VERBOSITY set to STATUS. ##${Reset}")
      set(CMMM_VERBOSITY "STATUS")
    endif()
  else()
    set(CMMM_VERBOSITY "STATUS")
  endif()
  set_property(GLOBAL PROPERTY CMMM_VERBOSITY ${CMMM_VERBOSITY})

  # Parse arguments
  if(NOT DEFINED CMMM_VERSION)
    message("${BoldRed}!! [CMakeMM] VERSION unknown. Please provide a version !!${Reset}")
    message(FATAL_ERROR)
  endif()

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

  #add the CMakeMM installation directory to CMAKE_MODULE_PATH
  list(INSERT CMAKE_MODULE_PATH 0 "${CMMM_DESTINATION}")
  list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  # Guard against multiple processes trying to use the PMM dir simultaneously
  file(LOCK "${CMMM_DESTINATION}" DIRECTORY GUARD PROCESS TIMEOUT 0 RESULT_VARIABLE CMMM_LOCK)
  if(NOT ${CMMM_LOCK} STREQUAL "0")
    if(${CMMM_VERBOSITY} STREQUAL VERBOSE)
      message("${BoldYellow}## [CMakeMM] Didn't lock the directory ${CMMM_DESTINATION} successfully (${CMMM_LOCK}). We'll continue as best we can. ##${Reset}")
    endif()
  else()
    if(${CMMM_VERBOSITY} STREQUAL DEBUG)
      message("${BoldGreen}** [CMakeMM] Locked the directory ${CMMM_DESTINATION} successfully. **${Reset}")
    endif()
  endif()

  # The file that we first download
  set(CMMM_ENTRY_FILE "${CMMM_DESTINATION}/Entry.cmake")

  # Downloading entry.cmake
  if(NOT EXISTS "${CMMM_ENTRY_FILE}" OR ${CMMM_ALWAYS_DOWNLOAD})
    message("${BoldMagenta}-- [CMakeMM] Downloading CMakeMM version ${CMMM_VERSION}\n             From : ${CMMM_GIT_URL_RELEASE}\n             To : ${CMMM_ENTRY_FILE} --${Reset}")
    file(DOWNLOAD "${CMMM_GIT_URL_RELEASE}/Entry.cmake" "${CMMM_ENTRY_FILE}.tmp" STATUS CMMM_STATUS TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
    list(GET CMMM_STATUS 0 CMMM_RC)
    list(GET CMMM_STATUS 1 CMMM_MSG)
    if(${CMMM_RC})
      if(NOT EXISTS ${CMMM_ENTRY_FILE})
        message("${BoldRed}!! Failed to download PMM Entry.cmake file: ${CMMM_MSG} !!${Reset}")
        message(FATAL_ERROR)
      else()
        message("${BoldYellow}## Failed to download PMM Entry.cmake file: ${CMMM_MSG} ##${Reset}")
        message("${BoldYellow}## Using last downloaded version ##${Reset}")
      endif()
    else()
      file(RENAME "${CMMM_ENTRY_FILE}.tmp" "${CMMM_ENTRY_FILE}")
    endif()
  endif()

  # This will trigger a warning if GetCMakeMM.cmake is not up-to-date
  # ^^^ DO NOT CHANGE THIS LINE vvv
  set(CMMM_BOOTSTRAP_VERSION GET_CMAKEMM_VERSION)
  # ^^^ DO NOT CHANGE THIS LINE ^^^

  # Include Entry.cmake
  include("${CMMM_ENTRY_FILE}")

  # Use Entry
  cmmm_entry(${ARGN})

  # Unlock the lock
  file(LOCK "${CMMM_DESTINATION}" DIRECTORY RESULT_VARIABLE CMMM_LOCK RELEASE)
  if(NOT ${CMMM_LOCK} STREQUAL "0")
    if(${CMMM_VERBOSITY} STREQUAL VERBOSE)
      message("${BoldYellow}## [CMakeMM] Didn't unlock the directory ${CMMM_DESTINATION} successfully (${CMMM_LOCK}). We'll continue as best we can. ##${Reset}")
    endif()
  else()
    if(${CMMM_VERBOSITY} STREQUAL DEBUG)
      message("${BoldGreen}** [CMakeMM] Unlocked the directory ${CMMM_DESTINATION} successfully. **${Reset}")
    endif()
  endif()
endfunction()
