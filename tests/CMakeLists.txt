cmake_minimum_required(VERSION 3.16...3.19)

project(TestCMakeMM VERSION "1.0" DESCRIPTION "CMake Modules Manager" HOMEPAGE_URL "https://github.com/flagarde/CMakeMM" LANGUAGES NONE)

execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/OldVersion" "-B" "${CMAKE_BINARY_DIR}/units/OldVersion")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/OldVersionIgnore" "-B" "${CMAKE_BINARY_DIR}/units/OldVersionIgnore")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/Default" "-B" "${CMAKE_BINARY_DIR}/units/Default")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/Filename" "-B" "${CMAKE_BINARY_DIR}/units/Filename")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/Folder" "-B" "${CMAKE_BINARY_DIR}/units/Folder")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/FolderFilename/" "-B" "${CMAKE_BINARY_DIR}/units/FolderFilename")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/BranchDefault" "-B" "${CMAKE_BINARY_DIR}/units/BranchDefault")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/BranchFilename" "-B" "${CMAKE_BINARY_DIR}/units/BranchFilename")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/BranchFolder" "-B" "${CMAKE_BINARY_DIR}/units/BranchFolder")
execute_process(COMMAND ${CMAKE_COMMAND} "-S" "${CMAKE_CURRENT_SOURCE_DIR}/units/BranchFolderFilename" "-B" "${CMAKE_BINARY_DIR}/units/BranchFolderFilename")
