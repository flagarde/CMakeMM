set(CMMM_LATEST_VERSION 2.3)

# Changelog list
function(changelog)
  cmmm_changes(0.9 "Alpha version")
  cmmm_changes(1.0 "Initial version")
  cmmm_changes(1.1 "Default branch is now main not master" "Avoid re-downloading modules list")
  cmmm_changes(2.0 "Suppress git and FetchContent dependencies" "${BoldRed}!! Please download the new GetCmakeMM.cmake !!${Reset}")
  cmmm_changes(2.1 "Suppress colors for visual studio and CLion" "${BoldRed}!! Please download the new GetCmakeMM.cmake !!${Reset}")
  cmmm_changes(2.2 "Improve suppress colors for visual studio and CLion" "Improve changelog")
  cmmm_changes(2.3 "Turn USE_FOLDERS to ON by default. Add enable_testing() automatically is CMakeMM is included on top level.")
endfunction()
