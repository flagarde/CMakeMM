include_guard(GLOBAL)

cmake_policy(VERSION "3.5")

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.21)
  if(PROJECT_IS_TOP_LEVEL)
    enable_testing()
  endif()
elseif()
  if(${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
    enable_testing()
  endif()
endif()

if(NOT COMMAND COLORS)
  # Colorize
  macro(COLORS)
    get_property(CMMM_NO_COLOR GLOBAL PROPERTY CMMM_NO_COLOR)
    if(WIN32 OR DEFINED ENV{CLION_IDE} OR DEFINED ENV{DevEnvDir})
      set(CMMM_NO_COLOR TRUE)
    endif()
    if(NOT ${CMMM_NO_COLOR})
      string(ASCII 27 Esc)
      set(Reset "${Esc}[m")
      set(BoldRed "${Esc}[1;31m")
      set(BoldMagenta "${Esc}[1;35m")
      set(BoldYellow "${Esc}[1;33m")
      set(BoldGreen "${Esc}[1;32m")
    endif()
  endmacro()
endif()

# Do the update check
function(cmmm_changes CHANGELOG_VERSION)
  if(${CMMM_VERSION} VERSION_LESS ${CHANGELOG_VERSION})
    message("${BoldGreen}  - Changes in ${CHANGELOG_VERSION} :${Reset}")
    foreach(CMMM_CHANGE IN LISTS ARGN)
      message("${BoldGreen}    - ${CMMM_CHANGE}${Reset}")
    endforeach()
  endif()
endfunction()

# Print the changelog
function(print_changelog)
  message("${BoldGreen}## [CMakeMM] Using CMakeMM version ${CMMM_VERSION}. The latest is ${CMMM_LATEST_VERSION}.${Reset}")
  message("${BoldGreen}Changes since ${CMMM_VERSION} include the following :${Reset}")
  changelog()
  message("${BoldGreen}To update, simply change the value of VERSION in cmmm function.${Reset}")
  message("${BoldGreen}You can disable these messages by setting IGNORE_NEW_VERSION in cmmm function. ##${Reset}")
endfunction()

# Check updates
function(cmmm_check_updates)
  cmake_parse_arguments(CMMM "IGNORE_NEW_VERSION" "URL;DESTINATION" "" "${ARGN}")

  if(NOT ${CMMM_IGNORE_NEW_VERSION})

    # LatestVersion and Changelog must be up-to-date so must be in main
    set(CMMM_CHANGELOG_FILE "${CMMM_DESTINATION}/Changelog.cmake")
    set(CMMM_CHANGELOG_URL "${CMMM_URL}/main/Changelog.cmake")

    file(DOWNLOAD "${CMMM_CHANGELOG_URL}" "${CMMM_CHANGELOG_FILE}" STATUS CMMM_STATUS TIMEOUT "${CMMM_TIMEOUT}" INACTIVITY_TIMEOUT "${CMMM_INACTIVITY_TIMEOUT}")
    list(GET CMMM_STATUS 0 CMMM_RC)
    list(GET CMMM_STATUS 1 CMMM_MESSAGE)
    if(${CMMM_RC} EQUAL 0)
      include("${CMMM_CHANGELOG_FILE}")
      if(DEFINED CMMM_LATEST_VERSION)
        if(NOT ${CMMM_VERSION} STREQUAL "main")
          if(${CMMM_VERSION} VERSION_LESS ${CMMM_LATEST_VERSION})
            print_changelog()
          endif()
        endif()
      else()
        message("${BoldYellow}** [CMakeMM] Error while downloading file ${CMMM_CHANGELOG_URL} **${Reset}")
      endif()
    else()
      message("${BoldYellow}** [CMakeMM] Error while downloading file ${CMMM_CHANGELOG_URL} : ${CMMM_MESSAGE} **${Reset}")
    endif()

  endif()

endfunction()

# The CMMM entry
macro(CMMM_ENTRY)
  cmake_parse_arguments(CMMM "ALWAYS_DOWNLOAD;NO_COLOR" "TAG;DESTINATION;TIMEOUT;INACTIVITY_TIMEOUT;VERBOSITY;URL" "" "${ARGN}")

  # Redo check here because the user can have a outdated GetCMakeMM
  if(WIN32 OR DEFINED ENV{CLION_IDE} OR DEFINED ENV{DevEnvDir})
    set(CMMM_NO_COLOR TRUE)
  elseif(NOT DEFINED CMMM_NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  endif()

  colors()

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
    "TRACE")

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

  set_property(GLOBAL PROPERTY CMMM_TIMEOUT ${CMMM_TIMEOUT})
  set_property(GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT})

  set_property(GLOBAL PROPERTY CMMM_DESTINATION ${CMMM_DESTINATION})

  cmmm_check_updates(${ARGN})

  set(CMAKEMM_INITIALIZED_${CMMM_TAG} TRUE CACHE INTERNAL "CMakeMM ${CMMM_TAG} is initialized.")

endmacro()

# CMCM

# Module definition
function(cmcm_module ARG_NAME)
  cmake_parse_arguments(ARG "" "REMOTE;LOCAL;VERSION" "ALSO" "${ARGV}")

  colors()

  if(NOT ARG_REMOTE AND NOT ARG_LOCAL)
    message("${BoldRed}!! [CMakeCM] Either LOCAL or REMOTE is required for cmcm_module !!${Reset}")
    message(FATAL_ERROR)
  endif()

  if(NOT ARG_VERSION)
    message("${BoldRed}!! [CMakeCM] Expected a VERSION for cmcm_module !!${Reset}")
    message(FATAL_ERROR)
  endif()

  get_property(CMMM_DESTINATION_PREMODULES GLOBAL PROPERTY CMMM_DESTINATION_PREMODULES)
  file(MAKE_DIRECTORY "${CMMM_DESTINATION_PREMODULES}")

  get_property(CMMM_URL_MODULES GLOBAL PROPERTY CMMM_URL_MODULES)

  if(ARG_REMOTE)
    file(WRITE "${CMMM_DESTINATION_PREMODULES}/${ARG_NAME}" "cmmm_include_module([[${ARG_NAME}]] [[${ARG_REMOTE}]] [[${ARG_VERSION}]] [[${ARG_ALSO}]])\n")
  else()
    file(WRITE "${CMMM_DESTINATION_PREMODULES}/${ARG_NAME}" "cmmm_include_module([[${ARG_NAME}]] [[${CMMM_URL_MODULES}/${ARG_LOCAL}]] [[${ARG_VERSION}]] [[${ARG_ALSO}]])\n")
  endif()

endfunction()

# Include the module
macro(CMMM_INCLUDE_MODULE MODULE_NAME MODULE_URL version also)

  colors()

  get_property(CMMM_DESTINATION_MODULES GLOBAL PROPERTY CMMM_DESTINATION_MODULES)
  get_property(CMMM_URL_MODULES GLOBAL PROPERTY CMMM_URL_MODULES)

  get_filename_component(CMMM_RESOLVED_DIR "${CMMM_DESTINATION_MODULES}" ABSOLUTE)
  get_filename_component(CMMM_RESOLVED "${CMMM_RESOLVED_DIR}/${MODULE_NAME}" ABSOLUTE)

  get_property(CMMM_INSTALLED_DESTINATION GLOBAL PROPERTY CMMM_DESTINATION)
  get_filename_component(CMMM_RESOLVED_STAMP "${CMMM_INSTALLED_DESTINATION}/Whence/${MODULE_NAME}.whence" ABSOLUTE)
  set(CMMM_WHENCE_STRING "${CMMM_URL_MODULES}::${MODULE_URL}.${version}")
  set(DOWNLOAD_MODULE FALSE)
  if(EXISTS "${CMMM_RESOLVED}")
    file(READ "${CMMM_RESOLVED_STAMP}" CMMM_STAMP)
    if(NOT CMMM_STAMP STREQUAL CMMM_WHENCE_STRING)
      set(DOWNLOAD_MODULE TRUE)
    endif()
  else()
    set(DOWNLOAD_MODULE TRUE)
  endif()
  if(DOWNLOAD_MODULE)
    file(MAKE_DIRECTORY "${CMMM_RESOLVED_DIR}")
    message("${BoldMagenta}-- [CMakeMM] Downloading new module ${MODULE_NAME} --${Reset}")
    file(DOWNLOAD "${MODULE_URL}" "${CMMM_RESOLVED}" STATUS DOWNLOAD_STATUS)
    list(GET DOWNLOAD_STATUS 0 CODE)
    list(GET DOWNLOAD_STATUS 1 MESSAGE)
    if(CODE)
      message("${BoldRed}!! [CMakeMM] Error while downloading file from '${MODULE_URL}' to '${CMMM_RESOLVED}' [${CODE}]: ${MESSAGE} !!${Reset}")
      message(FATAL_ERROR)
    endif()
    file(WRITE "${CMMM_RESOLVED_STAMP}" "${CMMM_WHENCE_STRING}")
  endif()
  include("${CMMM_RESOLVED}")
endmacro()

# Download the modules list
function(cmmm_modules_list)
  cmake_parse_arguments(CMMM "ALWAYS_DOWNLOAD" "URL;REPOSITORY;PROVIDER;BRANCH;FOLDER;FILENAME;DESTINATION" "" "${ARGV}")

  colors()

  get_property(CMMM_INACTIVITY_TIMEOUT GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT)
  get_property(CMMM_TIMEOUT GLOBAL PROPERTY CMMM_TIMEOUT)

  # Default modules list name
  if(NOT DEFINED CMMM_FILENAME)
    set(CMMM_FILENAME "ModulesList")
  endif()

  # Set default URL
  if(DEFINED CMMM_URL AND DEFINED CMMM_REPOSITORY)
    message("${BoldRed}!! [CMakeMM] URL and REPOSITORY can not appear at the same time !!${Reset}")
    message(FATAL_ERROR)
  elseif(NOT DEFINED CMMM_URL AND NOT DEFINED CMMM_REPOSITORY)
    message("${BoldRed}!! [CMakeMM] URL or REPOSITORY must be given !!${Reset}")
    message(FATAL_ERROR)
  endif()

  if(DEFINED CMMM_REPOSITORY)
    if(NOT DEFINED CMMM_PROVIDER OR CMMM_PROVIDER STREQUAL "github")
      set(CMMM_URL "https://raw.githubusercontent.com/${CMMM_REPOSITORY}")
    elseif(CMMM_PROVIDER STREQUAL "gitlab")
      set(CMMM_URL "https://gitlab.com/${CMMM_REPOSITORY}/-/raw")
    elseif(CMMM_PROVIDER STREQUAL "gitee")
      set(CMMM_URL "https://gitee.com/flagarde/CMakeMM/raw")
    else()
      if(CMMM_NO_COLOR)
        message("## [CMakeMM] Provider \"${CMMM_PROVIDER}\" unknown. Fall back to \"github\" ##")
      else()
        message("${BoldYellow}## [CMakeMM] Provider \"${CMMM_PROVIDER}\" unknown. Fall back to \"github\" ##${Reset}")
      endif()
      set(CMMM_URL "https://raw.githubusercontent.com/${CMMM_REPOSITORY}")
    endif()
  endif()

  string(FIND ${CMMM_URL} "/" HAS_FLASH REVERSE)
  string(LENGTH ${CMMM_URL} CMMM_URL_LENGTH)
  math(EXPR HAS_FLASH_PLUS_ONE ${HAS_FLASH}+1)
  if("${HAS_FLASH_PLUS_ONE}" STREQUAL "${CMMM_URL_LENGTH}")
    string(SUBSTRING "${CMMM_URL}" 0 "${HAS_FLASH}" CMMM_URL)
  endif()

  if(DEFINED CMMM_REPOSITORY)
    if(NOT DEFINED CMMM_BRANCH)
      set(CMMM_BRANCH "main")
    endif()
    set(CMMM_URL "${CMMM_URL}/${CMMM_BRANCH}")
  endif()

  set_property(GLOBAL PROPERTY CMMM_URL_MODULES "${CMMM_URL}")

  get_property(CMMM_INSTALLED_DESTINATION GLOBAL PROPERTY CMMM_DESTINATION)
  set(CMMM_DESTINATION_PREMODULES "${CMMM_INSTALLED_DESTINATION}/PreModules")

  # Set default modules installation folders
  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION_MODULES "${CMMM_INSTALLED_DESTINATION}/Modules")
  else()
    get_filename_component(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
  endif()

  set_property(GLOBAL PROPERTY CMMM_DESTINATION_MODULES "${CMMM_DESTINATION_MODULES}")
  set_property(GLOBAL PROPERTY CMMM_DESTINATION_PREMODULES "${CMMM_DESTINATION_PREMODULES}")

  # add the CMakeMM installation directory to CMAKE_MODULE_PATH
  list(INSERT CMAKE_MODULE_PATH 0 "${CMMM_DESTINATION_PREMODULES}")
  list(INSERT CMAKE_MODULE_PATH 0 "${CMMM_DESTINATION_MODULES}")
  list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  if(NOT DEFINED CMMM_FOLDER)
    set(CMMM_COMPLET_URL "${CMMM_URL}")
  else()
    set(CMMM_COMPLET_URL "${CMMM_URL}/${CMMM_FOLDER}")
  endif()

  if(${CMMM_ALWAYS_DOWNLOAD} OR NOT EXISTS "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}.cmake")
    message("${BoldMagenta}-- [CMakeMM] Downloading ${CMMM_FILENAME}.cmake\n   From : ${CMMM_COMPLET_URL}/${CMMM_FILENAME}.cmake\n   To   : ${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}.cmake --${Reset}")

    file(DOWNLOAD "${CMMM_COMPLET_URL}/${CMMM_FILENAME}.cmake" "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}Temp.cmake" INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT} STATUS CMAKECM_STATUS TIMEOUT ${CMMM_TIMEOUT})
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      if(NOT EXISTS "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}.cmake")
        file(REMOVE "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}Temp.cmake")
        message(FATAL_ERROR "${BoldRed}[CMakeMM] Error downloading ${CMMM_FILENAME} : ${CMAKECM_MESSAGE}${Reset}")
      else()
        message("${BoldYellow}## [CMakeMM] Error downloading ${CMMM_FILENAME} : ${CMAKECM_MESSAGE} ##${Reset}")
        message("${BoldYellow}## [CMakeMM] Using the one already downloaded ##${Reset}")
        file(REMOVE "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}Temp.cmake")
      endif()
    else()
      file(RENAME "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}Temp.cmake" "${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}.cmake")
    endif()
    message("${BoldGreen}** [CMakeMM] Modules will be installed in \"${CMMM_DESTINATION_MODULES}\" **${Reset}")
  endif()

  # Always regenerate PreModules
  include("${CMMM_INSTALLED_DESTINATION}/${CMMM_FILENAME}.cmake")

endfunction()
