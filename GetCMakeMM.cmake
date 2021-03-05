include_guard(GLOBAL)

function(cmmm)
  include(FetchContent)

  cmake_parse_arguments(CMMM "NO_COLOR" "REPOSITORY;VERSION;VERBOSITY" "" ${ARGN})
  if(NOT DEFINED CMMM_REPOSITORY)
    set(CMMM_REPOSITORY "flagarde/CMakeMM")
  endif()

  if(NOT DEFINED CMMM_VERSION)
    set(CMMM_VERSION "master")
  endif()

  if(${CMMM_VERSION} STREQUAL "master")
    fetchcontent_declare(CMakeMM GIT_REPOSITORY "https://github.com/${CMMM_REPOSITORY}" GIT_TAG "${CMMM_VERSION}" GIT_SHALLOW)
  else()
    fetchcontent_declare(CMakeMM GIT_REPOSITORY "https://github.com/${CMMM_REPOSITORY}" GIT_TAG "v${CMMM_VERSION}" GIT_SHALLOW)
  endif()

  if(NOT DEFINED CMAKEMM_INITIALIZED)
    string(ASCII 27 Esc)
    if(CMMM_NO_COLOR OR WIN32)
      message("-- [CMakeMM] Downloading CMakeMM version \"${CMMM_VERSION}\" from \"https://github.com/${CMMM_REPOSITORY}\" --")
    else()
      message("${Esc}[1;35m-- [CMakeMM] Downloading CMakeMM version \"${CMMM_VERSION}\" from \"https://github.com/${CMMM_REPOSITORY}\" --${Esc}[m")
    endif()
  endif()

  set(FETCHCONTENT_UPDATES_DISCONNECTED_CMAKEMM ON)

  fetchcontent_getproperties(CMakeMM)

  if(NOT cmakemm_POPULATED)
    fetchcontent_populate(CMakeMM)
    list(INSERT CMAKE_MODULE_PATH 0 ${cmakemm_SOURCE_DIR})
    set(CMAKEMM_INITIALIZED "TRUE" CACHE INTERNAL "CMakeMM has been installed")
    include(CMakeMM)
    cmmm_entry(${ARGN})
  endif()
endfunction()
