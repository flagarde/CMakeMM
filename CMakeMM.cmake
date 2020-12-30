function(cmcm_module ARG_NAME)
  cmake_parse_arguments(ARG "" "REMOTE;LOCAL;VERSION" "ALSO" "${ARGV}")
  get_property(CMMM_NO_COLOR GLOBAL PROPERTY CMMM_NO_COLOR)
  if(NOT ${CMMM_NO_COLOR})
    colors()
  endif()
  if(NOT ARG_REMOTE AND NOT ARG_LOCAL)
    message("${BoldRed}!! [CMakeCM] Either LOCAL or REMOTE is required for cmmm_module !!${Reset}")
    message(FATAL_ERROR)
  endif()
  if(NOT ARG_VERSION)
    message("${BoldRed}!! [CMakeCM] Expected a VERSION for cmmm_module !!${Reset}")
    message(FATAL_ERROR)
  endif()
  file(MAKE_DIRECTORY "${CMMM_INSTALL_DESTINATION}")
  get_property(CMMM_URL_MODULES GLOBAL PROPERTY CMMM_URL_MODULES)
  if(ARG_REMOTE)
    file(WRITE "${CMMM_INSTALL_DESTINATION}/${ARG_NAME}" "cmmm_include_module([[${ARG_NAME}]] [[${ARG_REMOTE}]] [[${ARG_VERSION}]] [[${ARG_ALSO}]])\n")
  else()
    file(WRITE "${CMMM_INSTALL_DESTINATION}/${ARG_NAME}" "cmmm_include_module([[${ARG_NAME}]] [[${CMMM_URL_MODULES}/${ARG_LOCAL}]] [[${ARG_VERSION}]] [[${ARG_ALSO}]])\n")
  endif()
endfunction()

macro(cmmm_include_module MODULE_NAME MODULE_URL version also)
  get_property(CMMM_NO_COLOR GLOBAL PROPERTY CMMM_NO_COLOR)
  if(NOT ${CMMM_NO_COLOR})
    colors()
  endif()

  get_property(CMMM_INSTALL_DESTINATION GLOBAL PROPERTY CMMM_DESTINATION)
  get_property(CMMM_DESTINATION_MODULES GLOBAL PROPERTY CMMM_DESTINATION_MODULES)
  get_property(CMMM_URL_MODULES GLOBAL PROPERTY CMMM_URL_MODULES)

  get_filename_component(CMMM_RESOLVED_DIR "${CMMM_DESTINATION_MODULES}" ABSOLUTE)
  get_filename_component(CMMM_RESOLVED "${CMMM_RESOLVED_DIR}/${MODULE_NAME}" ABSOLUTE)
  get_filename_component(CMMM_RESOLVED_STAMP "${CMMM_INSTALL_DESTINATION}/${MODULE_NAME}.whence" ABSOLUTE)
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
    message("${BoldMagenta}-- [CMakeCM] Downloading new module ${MODULE_NAME} --${Reset}")
    file(DOWNLOAD "${MODULE_URL}" "${CMMM_RESOLVED}" STATUS DOWNLOAD_STATUS)
    list(GET DOWNLOAD_STATUS 0 CODE)
    list(GET DOWNLOAD_STATUS 1 MESSAGE)
    if(CODE)
      message("${BoldRed}!! [CMakeCM] Error while downloading file from '${MODULE_URL}' to '${CMMM_RESOLVED}' [${CODE}]: ${MESSAGE} !!${Reset}")
      message(FATAL_ERROR)
    endif()
    file(WRITE "${CMMM_RESOLVED_STAMP}" "${CMMM_WHENCE_STRING}")
  endif()
  include("${CMMM_RESOLVED}")
endmacro()

function(cmmm_modules_list)
  cmake_parse_arguments(CMMM "ALWAYS_DOWNLOAD" "URL;GIT_REPOSITORY;BRANCH;FOLDER;FILENAME;DESTINATION" "" "${ARGV}")

  get_property(CMMM_NO_COLOR GLOBAL PROPERTY CMMM_NO_COLOR)
  if(NOT ${CMMM_NO_COLOR})
    colors()
  endif()

  get_property(CMMM_INACTIVITY_TIMEOUT GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT)
  get_property(CMMM_TIMEOUT GLOBAL PROPERTY CMMM_TIMEOUT)

  # Default modules list name
  if(NOT DEFINED CMMM_FILENAME)
    set(CMMM_FILENAME "ModulesList")
  endif()

  # Set default URL
  if(DEFINED CMMM_URL AND DEFINED CMMM_GIT_REPOSITORY)
    message("${BoldRed}!! [CMakeMM] URL and GIT_REPOSITORY can not appear at the same time !!${Reset}")
    message(FATAL_ERROR)
  elseif(NOT DEFINED CMMM_URL AND NOT DEFINED CMMM_GIT_REPOSITORY)
    message("${BoldRed}!! [CMakeMM] URL or GIT_REPOSITORY must be given !!${Reset}")
    message(FATAL_ERROR)
  endif()

  if(DEFINED CMMM_GIT_REPOSITORY)
    set(CMMM_URL "https://cdn.jsdelivr.net/gh/${CMMM_GIT_REPOSITORY}")
  endif()

  string(FIND ${CMMM_URL} "/" HAS_FLASH REVERSE)
  string(LENGTH ${CMMM_URL} CMMM_URL_LENGTH)
  math(EXPR HAS_FLASH_PLUS_ONE ${HAS_FLASH}+1)
  if(${HAS_FLASH_PLUS_ONE} STREQUAL ${CMMM_URL_LENGTH})
    string(SUBSTRING ${CMMM_URL} 0 ${HAS_FLASH} CMMM_URL)
  endif()

  if(DEFINED CMMM_GIT_REPOSITORY)
    if(NOT DEFINED CMMM_BRANCH)
      set(CMMM_BRANCH "master")
    endif()
    set(CMMM_URL "${CMMM_URL}@${CMMM_BRANCH}")
  endif()

  set_property(GLOBAL PROPERTY CMMM_URL_MODULES "${CMMM_URL}")

  get_property(CMMM_INSTALL_DESTINATION GLOBAL PROPERTY CMMM_DESTINATION)
  # Set default modules installation folders
  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION_MODULES "${CMMM_INSTALL_DESTINATION}/Modules")
  else()
    get_filename_component(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  set_property(GLOBAL PROPERTY CMMM_DESTINATION_MODULES ${CMMM_DESTINATION_MODULES})

  if(NOT DEFINED CMMM_FOLDER)
    set(CMMM_COMPLET_URL "${CMMM_URL}")
  else()
    set(CMMM_COMPLET_URL "${CMMM_URL}/${CMMM_FOLDER}")
  endif()

  message("${BoldMagenta}-- [CMakeMM] Downloading ${CMMM_FILENAME}.cmake\n   From : ${CMMM_COMPLET_URL}/${CMMM_FILENAME}.cmake\n   To   : ${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake --${Reset}")

  file(DOWNLOAD "${CMMM_COMPLET_URL}/${CMMM_FILENAME}.cmake" "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}Temp.cmake" INACTIVITY_TIMEOUT ${CMMM_INACTIVITY_TIMEOUT} STATUS CMAKECM_STATUS TIMEOUT ${CMMM_TIMEOUT})
  list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
  list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
  if(${CMAKECM_CODE})
    if(NOT EXISTS "${CMMM_DESTINATION_MODULES}/ModulesList.cmake")
      message("${BoldRed}!! [CMakeCM] Error downloading ${CMMM_FILENAME} : ${CMAKECM_MESSAGE} !!${Reset}")
      file(REMOVE "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}Temp.cmake")
      message(FATAL_ERROR)
    else()
      message("${BoldYellow}## [CMakeCM] Error downloading ${CMMM_FILENAME} : ${CMAKECM_MESSAGE} ##${Reset}")
      message("${BoldYellow}## [CMakeCM] Using the one already downloaded ##${Reset}")
      file(REMOVE "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}Temp.cmake")
      include("${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake")
    endif()
  elseif(${CMMM_ALWAYS_DOWNLOAD} OR NOT EXISTS "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake")
    file(RENAME "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}Temp.cmake" "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake")
    include("${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake")
  elseif(NOT ${CMMM_ALWAYS_DOWNLOAD})
    file(SHA256 "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}Temp.cmake" ModulesListTemp)
    file(SHA256 "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake" ModulesList)
    if(NOT ${ModulesListTemp} STREQUAL ${ModulesList})
      message("${BoldYellow}## [CMakeCM] ModulesList has been uploaded but ALWAYS_DOWNLOAD is set in cmmm_modules_list ##${Reset}")
    endif()
    file(REMOVE "${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}Temp.cmake")
    include("${CMMM_DESTINATION_MODULES}/${CMMM_FILENAME}.cmake")
  endif()

  message("${BoldGreen}** [CMakeCM] Modules will be installed in \"${CMMM_DESTINATION_MODULES}\" **${Reset}")
endfunction()
