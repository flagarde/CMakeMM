# 📦 CMakeMM ![GitHub](https://img.shields.io/github/license/flagarde/CMakeMM) ![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/flagarde/CMakeMM) ![GitHub repo size](https://img.shields.io/github/repo-size/flagarde/CMakeMM) ![Release GetCMakeMM](https://github.com/flagarde/CMakeMM/workflows/Release%20GetCMakeMM/badge.svg) ![Release CMakeMM](https://github.com/flagarde/CMakeMM/workflows/Release%20CMakeMM/badge.svg) #

CMake Modules Manager.

## ✨ Introduction
This repository's main product is the GetCMakeMM.cmake file in the repository root. It downloads CMakeMM which in turn download the list of modules available for download and consumption.

## ❓ How to use CMakeMM ?

### 1️⃣ Download `GetCMakeMM.cmake`
To use `CMakeMM` you have to download the latest `GetCMakeMM.cmake` https://github.com/flagarde/CMakeMM/releases and put it in a place CMake can find it.

### 2️⃣ Use `GetCMakeMM.cmake` in your `CMakeLists.txt`.
 ```cmake
	set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
	include(GetCMakeMM)
	cmmm(VERSION "1.0" 
       GIT_REPOSITORY "flagarde/CMakeMM"
       VERBOSE 
       DESTINATION "CMakeMM" 
       ALWAYS_DOWNLOAD)
 ```
 *Will download `CMakeMM` from the release version `1.0` in flagarde/CMakeMM repository under `CMakeMM` folder.*
 
 #### Options :
 `ALWAYS_DOWNLOAD` : Always download the CMakeMM files.
 
 `NO_COLOR` : Turn out the color.
 
 `GIT_REPOSITORY` : Repository where to download CMakeMM.
 
 `VERSION` : Version of CMakeMM to download.
 
 `DESTINATION` : Where to install CMakeMM.
 
 `TIMEOUT` : Terminate the operation after a given total time has elapsed.
 
 `INACTIVITY_TIMEOUT` : Terminate the operation after a period of inactivity.
 
 `VERBOSITY` : Verbosity of CMakeMM `NOTICE`, `STATUS`, `VERBOSE`, `DEBUG` and `TRACE`.
 
 ### 3️⃣ Tell to `CMakeMM` where to find the modules list and where to save the modules
 ```cmake
 cmmm_modules_list(URL "https://raw.githubusercontent.com/SDHCAL/SDHCALCMakeModules" 
                   BRANCH master
                   FOLDER modules
                   FILENAME ModuleLists
                   DESTINATION "Modules")
 ```
 *Will donwload the module list file called `ModuleLists.cmake` in folder `modules` on branch `master` from the github depot `https://raw.githubusercontent.com/SDHCAL/SDHCALCMakeModules`*. 
 
 #### Options :
 `ALWAYS_DOWNLOAD` : Always download the Modules List.
 
 `URL` : URL where to download the Modules List (`https://raw.githubusercontent.com/flagarde/CMakeMM` per default).
 
 `BRANCH` : Branch where to download the Modules List (`master` per default).
 
 `FOLDER` : Folder where to download the Modules List.
 
 `FILENAME` : Name of the Modules List file.
 
 `DESTINATION` : Where to install the Modules.
 
 ### 4️⃣ Include the modules you need
  ```cmake
  include(MyWonderfulModule)
  ```
*Will download the module `MyWonderfulModule.cmake` is it's not present in the `CMAKE_MODULE_PATH` folders or `Modules` folder, then include it. Otherwise it will just include it.*
  
## ⚗  Example
CMakeLists.txt :
```cmake
cmake_minimum_required(VERSION 3.10...3.17.2 FATAL_ERROR)
project(MySoftware 
        VERSION "0.0.1.0" 
        DESCRIPTION "MySoftware" 
        HOMEPAGE_URL "https://github.com/SDHCAL/MySoftware"
        LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GetCMakeMM)

cmmm(VERSION "1.0" 
     GIT_REPOSITORY "flagarde/CMakeMM"
     VERBOSE
     DESTINATION "CMakeMM"
     ALWAYS_DOWNLOAD)

cmmm_modules_list(URL "https://raw.githubusercontent.com/SDHCAL/SDHCALCMakeModules"
                  BRANCH main
                  DESTINATION "Modules")

# Now download the modules
include(Colors)
```
## 📝 Create a Modules List

Modules can be `LOCALE` or `REMOTE` :

### ➕ Adding a "Local" Module

Local modules are contained within the repository given by `URL` in `cmmm_modules_list`. If you do not wish to own a separate repository to contain the module, this is the recommended way to do so.

To start, add a module in the repository. This will be the module that will be included by the user. It should consist of a single CMake file.

After adding the module, add a call to `cmcm_module` in the Modules List.

Suppose you add a `SuperCoolModule.cmake` to `modules`. The resulting call in `modules/ModulesList.cmake` will look something like this :

```cmake
cmcm_module(SuperCoolModule.cmake
            LOCAL modules/SuperCoolModule.cmake
            VERSION 1
           )
```

The `VERSION` argument is an arbitrary string that is used to invalidate local copies of the module that have been downloaded.

### ➕ Adding a "Remote" Module

If you have a module that you wish to add, but it is contained in a remote location, you simply need to add the call in the Modules List :

```cmake
cmcm_module(MyAwesomeModule.cmake
            REMOTE https://some-place.example.com/files/path/MyAwesomeModule.cmake
            VERSION 1
           )
```

The `VERSION` argument is an arbitrary string that is used to invalidate local copies of the module that have been downloaded.

The `REMOTE` is a `URL` to the file to download for the module. In order for your modification to be accepted into the repository, it must meet certain criteria:

1. The URL *must* use `https`.
2. The URL *must* refer to a stable file location. If using a `Git URL`, it should refer to a specific commit, not to a branch.
