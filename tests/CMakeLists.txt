cmake_minimum_required(VERSION 3.10...3.19)

project(CMakeCMTests VERSION 1 DESCRIPTION "Tests for CMakeCM" HOMEPAGE_URL "https://github.com/flagarde/CMakeCM" LANGUAGES CXX)

enable_testing()

file(GLOB sub-dir LIST_DIRECTORIES TRUE RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/units/" "${CMAKE_CURRENT_SOURCE_DIR}/units/*")


foreach(test ${sub-dir})
  message(STATUS "Adding test : ${test}")
  add_test(NAME ${test} COMMAND ${CMAKE_COMMAND} -DMODULES_PATH=${CMAKE_CURRENT_SOURCE_DIR}/../modules/ -S "${CMAKE_CURRENT_SOURCE_DIR}/units/${test}" -B "${CMAKE_CURRENT_BINARY_DIR}/${test}")
endforeach()

add_custom_target(TestsVerbose COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C Debug --progress --verbose -j10)
add_custom_target(Tests COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C Debug --progress -j10)
