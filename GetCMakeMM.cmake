macro(set_colors CMMM_NO_COLOR)
  # Some part of Colors.cmake here to Colorize the output before it has been downloaded
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
  cmake_parse_arguments(CMMM "VERBOSE;DEBUG;ALWAYS_DOWNLOAD;NO_COLOR" "URL;VERSION;DESTINATION;TIMEOUT;INACTIVITY_TIMEOUT" "" ${ARGN})

  set_colors(${CMMM_NO_COLOR})
  set_property(GLOBAL PROPERTY CMMM_NO_COLOR ${CMMM_NO_COLOR})
  set_property(GLOBAL PROPERTY CMMM_VERBOSE ${CMMM_VERBOSE})
  set_property(GLOBAL PROPERTY CMMM_DEBUG ${CMMM_DEBUG})

  # Parse arguments
  if(NOT DEFINED CMMM_VERSION)
    set(CMMM_VERSION "master")
    list(APPEND ARGN VERSION ${CMMM_VERSION})
  endif()

  if(NOT DEFINED CMMM_TIMEOUT)
    set(CMMM_TIMEOUT 10)
    list(APPEND ARGN TIMEOUT ${CMMM_TIMEOUT})
  endif()
  set_property(GLOBAL PROPERTY CMMM_TIMEOUT ${CMMM_TIMEOUT})

  if(NOT DEFINED CMMM_INACTIVITY_TIMEOUT)
    set(CMMM_INACTIVITY_TIMEOUT 5)
    list(APPEND ARGN INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
  endif()
  set_property(GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})

  if(NOT DEFINED CMMM_URL)
    set(CMMM_URL "https://raw.githubusercontent.com/flagarde/CMakeMM")
    list(APPEND ARGN URL ${CMMM_URL})
  else()
    string(FIND ${CMMM_URL} "/" HAS_FLASH REVERSE)
    string(LENGTH ${CMMM_URL} CMMM_URL_LENGTH)
    math(EXPR HAS_FLASH_PLUS_ONE ${HAS_FLASH}+1)
    if(${HAS_FLASH_PLUS_ONE} STREQUAL ${CMMM_URL_LENGTH})
      string(SUBSTRING ${CMMM_URL} 0 ${HAS_FLASH} CMMM_URL_CHANGED)
      list(REMOVE_ITEM ARGN URL ${CMMM_URL})
      list(APPEND ARGN URL ${CMMM_URL_CHANGED})
      set(CMMM_URL ${CMMM_URL_CHANGED})
    endif()
  endif()
  set_property(GLOBAL PROPERTY CMMM_URL ${CMMM_URL})

  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/CMakeMM")
  else()
    get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  set(CMMM_DESTINATION "${CMMM_DESTINATION}/${CMMM_VERSION}")
  list(APPEND ARGN DESTINATION ${CMMM_DESTINATION})
  set_property(GLOBAL PROPERTY CMMM_DESTINATION ${CMMM_DESTINATION})

  #add the CMakeMM installation directory to CMAKE_MODULE_PATH
  list(INSERT CMAKE_MODULE_PATH 0 "${CMMM_DESTINATION}")
  list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  # Guard against multiple processes trying to use the PMM dir simultaneously
  file(LOCK "${CMMM_DESTINATION}" DIRECTORY GUARD PROCESS TIMEOUT 0 RESULT_VARIABLE CMMM_LOCK)
  if(NOT ${CMMM_LOCK} STREQUAL "0")
    if(CMMM_VERBOSE)
      message("${BoldYellow}## [CMakeMM] Didn't lock the directory ${CMMM_DESTINATION} successfully (${CMMM_LOCK}). We'll continue as best we can. ##${Reset}")
    endif()
  else()
    if(CMMM_DEBUG)
      message("${BoldGreen}** [CMakeMM] Locked the directory ${CMMM_DESTINATION} successfully. **${Reset}")
    endif()
  endif()

  # The file that we first download
  set(CMMM_ENTRY_FILE "${CMMM_DESTINATION}/Entry.cmake")

  # Downloading entry.cmake
  if(NOT EXISTS "${CMMM_ENTRY_FILE}" OR ${CMMM_ALWAYS_DOWNLOAD})
    if(${CMMM_VERBOSE} OR ${CMMM_DEBUG})
      message("${BoldMagenta}-- [CMakeMM] Downloading CMakeMM version ${CMMM_VERSION}\n             From : ${CMMM_URL}/${CMMM_VERSION}\n             To : ${CMMM_ENTRY_FILE} --${Reset}")
    endif()
    file(DOWNLOAD "${CMMM_URL}/${CMMM_VERSION}/Entry.cmake" "${CMMM_ENTRY_FILE}.tmp" STATUS CMMM_STATUS TIMEOUT ${CMMM_TIMEOUT} INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})
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
  set(CMMM_BOOTSTRAP_VERSION 1)
  # ^^^ DO NOT CHANGE THIS LINE ^^^

  # Include Entry.cmake
  include("${CMMM_ENTRY_FILE}")

  # Use Entry
  cmmm(${ARGN})

  # Unlock the lock
  file(LOCK "${CMMM_DESTINATION}" DIRECTORY RESULT_VARIABLE CMMM_LOCK RELEASE)
  if(NOT ${CMMM_LOCK} STREQUAL "0")
    if(CMMM_VERBOSE)
      message("${BoldYellow}## [CMakeMM] Didn't unlock the directory ${CMMM_DESTINATION} successfully (${CMMM_LOCK}). We'll continue as best we can. ##${Reset}")
    endif()
  else()
    if(CMMM_DEBUG)
      message("${BoldGreen}** [CMakeMM] Unlocked the directory ${CMMM_DESTINATION} successfully. **${Reset}")
    endif()
  endif()
endfunction()
