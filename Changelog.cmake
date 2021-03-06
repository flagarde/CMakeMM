set(CMMM_LATEST_VERSION 2.0)

function(changelog)
  cmmm_changes(0.9 "Alpha version")
  cmmm_changes(1.0 "Initial version")
  cmmm_changes(1.1 "Default branch is now main not master" "Avoid redownloading modules list")
  cmmm_changes(2.0 "Supress git and FetchContent dependencies" "${BoldRed}!! Please download the new GetCmakeMM.cmake !!${Reset}")
endfunction()
