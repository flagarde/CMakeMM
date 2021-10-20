<h1 align="center">
  <a href="https://github.com/flagarde/CMakeMM"><img src="./docs/imgs/logo.png" width="300" title="CMakeMM logo" alt="CMakeMM"></a>

CMakeMM
</h1>
<h4 align="center">CMake Modules Manager.</h4>

<h4 align="center">

![GitHub](https://img.shields.io/github/license/flagarde/CMakeMM) 
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/flagarde/CMakeMM) 
![GitHub repo size](https://img.shields.io/github/repo-size/flagarde/CMakeMM)
![Release](https://github.com/flagarde/CMakeMM/workflows/Release/badge.svg)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/69bc83f9b6a44f52ae5d2790f55d2a0b)](https://www.codacy.com/gh/flagarde/CMakeMM/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=flagarde/CMakeMM&amp;utm_campaign=Badge_Grade)
[![Docs](https://github.com/flagarde/CMakeMM/actions/workflows/Docs.yml/badge.svg)](https://github.com/flagarde/CMakeMM/actions/workflows/Docs.yml)
[![Codespell](https://github.com/flagarde/CMakeMM/actions/workflows/Codespell.yml/badge.svg)](https://github.com/flagarde/CMakeMM/actions/workflows/Codespell.yml)
</h4>

<h1 align="center"><a href="https://flagarde.github.io/CMakeMM/">

```html
📖 Documentation
```
</a></h1>

## Tests

|        | Linux           | MacOS           | Windows           |
|--------|-----------------|-----------------|-------------------|
| Github |[![Linux][lb]][l]|[![MacOS][mb]][m]|[![Windows][wb]][w]|

## ✨ Introduction
This repository's main product is the GetCMakeMM.cmake file in the repository root. It downloads CMakeMM which in turn download the list of modules available for download and consumption.

## ❓ How to use CMakeMM

### 1️⃣ Download `GetCMakeMM.cmake`
To use `CMakeMM` you have to download the latest `GetCMakeMM.cmake` https://github.com/flagarde/CMakeMM/blob/master/GetCMakeMM.cmake and put it in a place CMake can find it.

### 2️⃣ Use `GetCMakeMM.cmake` in your `CMakeLists.txt`
 ```cmake
	set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
	include(GetCMakeMM)
	cmmm(VERSION "2.0"
       REPOSITORY "flagarde/CMakeMM"
       VERBOSITY VERBOSE
       DESTINATION "CMakeMM"
       ALWAYS_DOWNLOAD)
 ```
 
 *Will download `CMakeMM` from the release version `1.0` in flagarde/CMakeMM repository under `CMakeMM` folder.*

**Options :**
- `PROVIDER` : From where to download CMakeMM (github, gitlab or gitee).
- `ALWAYS_DOWNLOAD` : Always download the CMakeMM files.
- `NO_COLOR` : Turn out the color.
- `REPOSITORY` : Repository where to download CMakeMM.
- `VERSION` : Version of CMakeMM to download.
- `DESTINATION` : Where to install CMakeMM.
- `TIMEOUT` : Terminate the operation after a given total time has elapsed.
- `INACTIVITY_TIMEOUT` : Terminate the operation after a period of inactivity.
- `VERBOSITY` : Verbosity of CMakeMM `NOTICE`, `STATUS`, `VERBOSE`, `DEBUG` and `TRACE`.
- `IGNORE_NEW_VERSION` : Ignore new versions of `CMakeMM`.

 ### 3️⃣ Tell to `CMakeMM` where to find the modules list and where to save the modules
 ```cmake
 cmmm_modules_list(URL "https://raw.githubusercontent.com/SDHCAL/SDHCALCMakeModules"
                   BRANCH master
                   FOLDER modules
                   FILENAME ModuleLists
                   DESTINATION "Modules")
 ```
 *Will download the module list file called `ModuleLists.cmake` in folder `modules` on branch `master` from the github depot `https://raw.githubusercontent.com/SDHCAL/SDHCALCMakeModules`*.

**Options :**
- `ALWAYS_DOWNLOAD` : Always download the Modules List.
- `URL` : URL where to download the Modules List (`https://raw.githubusercontent.com/flagarde/CMakeMM` per default).
- `REPOSITORY` : github repository to download the Modules List (`flagarde/CMakeCM` for example).
- `PROVIDER` : From where to download CMakeMM (github, gitlab or gitee).
- `BRANCH` : Branch where to download the Modules List (`master` per default).
- `FOLDER` : Folder where to download the Modules List.
- `FILENAME` : Name of the Modules List file.
- `DESTINATION` : Where to install the Modules.

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

cmmm(VERSION "2.0"
     REPOSITORY "flagarde/CMakeMM"
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
            VERSION 1)
```

The `VERSION` argument is an arbitrary string that is used to invalidate local copies of the module that have been downloaded.

*The path to the LOCAL module is taken from the `root` of the `Git` `branch`, not the relative path of the `FOLDER` argument in `cmmm_modules_list`.*

### ➕ Adding a "Remote" Module

If you have a module that you wish to add, but it is contained in a remote location, you simply need to add the call in the Modules List :

```cmake
cmcm_module(MyAwesomeModule.cmake
            REMOTE https://some-place.example.com/files/path/MyAwesomeModule.cmake
            VERSION 1)
```

The `VERSION` argument is an arbitrary string that is used to invalidate local copies of the module that have been downloaded.

The `REMOTE` is a `URL` to the file to download for the module. In order for your modification to be accepted into the repository, it must meet certain criteria :
  1.  The URL *must* use `https`.
  2.  The URL *must* refer to a stable file location. If using a `Git URL`, it should refer to a specific commit, not to a branch.

[l]: https://github.com/flagarde/CMakeMM/actions/workflows/Linux.yml
[lb]: https://github.com/flagarde/CMakeMM/actions/workflows/Linux.yml/badge.svg

[m]: https://github.com/flagarde/CMakeMM/actions/workflows/MacOS.yml
[mb]: https://github.com/flagarde/CMakeMM/actions/workflows/MacOS.yml/badge.svg

[w]: https://github.com/flagarde/CMakeMM/actions/workflows/Windows.yml
[wb]: https://github.com/flagarde/CMakeMM/actions/workflows/Windows.yml/badge.svg
