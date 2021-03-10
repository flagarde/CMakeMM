include_guard(GLOBAL)

function(cmmm)
  include(FetchContent)

  cmake_parse_arguments(CMMM "NO_COLOR" "REPOSITORY;VERSION;VERBOSITY;PROVIDER" "" ${ARGN})
  if(NOT DEFINED CMMM_PROVIDER)
    set(CMMM_PROVIDER "https://github.com")
  elseif("${CMMM_PROVIDER}" STREQUAL "github")
    set(CMMM_PROVIDER "https://github.com")
  elseif("${CMMM_PROVIDER}" STREQUAL "gitlab")
    set(CMMM_PROVIDER "https://gitlab.com")
  elseif("${CMMM_PROVIDER}" STREQUAL "gitee")
    set(CMMM_PROVIDER "https://gitee.com")
  else()
    string(ASCII 27 Esc)
    if(CMMM_NO_COLOR OR WIN32)
      message("-- [CMakeMM] Provider \"${CMMM_PROVIDER}\" unknown. Fall back to \"github\" --")
    else()
      message("${Esc}[1;35m-- [CMakeMM] Provider \"${CMMM_PROVIDER}\" unknown. Fall back to \"github\" --${Esc}[m")
    endif()
      set(CMMM_PROVIDER "https://github.com")
  endif()
  
  if(NOT DEFINED CMMM_REPOSITORY)
    set(CMMM_REPOSITORY "flagarde/CMakeMM")
  endif()

  if(NOT DEFINED CMMM_VERSION)
    set(CMMM_VERSION "master")
  endif()

  if(${CMMM_VERSION} STREQUAL "master")
    fetchcontent_declare(CMakeMM GIT_REPOSITORY "${CMMM_PROVIDER}/${CMMM_REPOSITORY}" GIT_TAG "${CMMM_VERSION}" GIT_SHALLOW)
  else()
    fetchcontent_declare(CMakeMM GIT_REPOSITORY "${CMMM_PROVIDER}/${CMMM_REPOSITORY}" GIT_TAG "v${CMMM_VERSION}" GIT_SHALLOW)
  endif()

  if(NOT DEFINED CMAKEMM_INITIALIZED)
    string(ASCII 27 Esc)
    if(CMMM_NO_COLOR OR WIN32)
      message("-- [CMakeMM] Downloading CMakeMM version \"${CMMM_VERSION}\" from \"${CMMM_PROVIDER}/${CMMM_REPOSITORY}\" --")
    else()
      message("${Esc}[1;35m-- [CMakeMM] Downloading CMakeMM version \"${CMMM_VERSION}\" from \"${CMMM_PROVIDER}/${CMMM_REPOSITORY}\" --${Esc}[m")
    endif()
  endif()

  set(FETCHCONTENT_UPDATES_DISCONNECTED_CMAKEMM ON)

  fetchcontent_getproperties(CMakeMM)

  if(NOT cmakemm_POPULATED)
    fetchcontent_populate(CMakeMM)
    list(INSERT CMAKE_MODULE_PATH 0 ${cmakemm_SOURCE_DIR})
    set(CMAKEMM_INITIALIZED "TRUE" CACHE INTERNAL "CMakeMM has been installed")
    include(CMakeMM)
    cmmm_entry(${ARGN} PROVIDER ${CMMM_PROVIDER})
  endif()
endfunction()
