cmake_minimum_required( VERSION 3.4 )

## Dump current settings
message( "MY_PROJECT_DESC: " ${MY_PROJECT_DESC} )
message( "MY_PROJECT_NAME: " ${MY_PROJECT_NAME} )
message( "MY_PROJECT_SOURCE_ID: " ${MY_PROJECT_SOURCE_ID} )
message( "MY_PROJECT_SUFFIX: " ${MY_PROJECT_SUFFIX} )
message( "MY_REVISION: " ${MY_REVISION} )
message( "MY_VER: " ${MY_VER} )

project( ${MY_PROJECT_NAME} )

option( BUILD_WITH_SHARED_VCRT "Build library with shared vc runtime library." ON )
option( BUILD_WITH_STATIC_VCRT "Build library without shared vc runtime library." OFF )
option( BUILD_WITH_TEST_RUNNER "Build library and start test runner." OFF )
option( BUILD_WITH_WORKAROUND_ARM64RT "Build library with workaround arm64rt.lib library" OFF )
option( BUILD_WITH_WORKAROUND_OPT_GY "Build library with workaround /Gy compiler option" OFF )
option( BUILD_WITH_WORKAROUND_SOFTINTRIN "Build library with workaround softintrin.lib library" OFF )
option( BUILD_WITH_WORKAROUND_SPECTRE "Build library with workaround spectre mitigation library" OFF )

## Separate MY_VER into MY_VER_MAJOR / MY_VER_MINOR / MY_VER_PATCH / MY_VER_PATCHLEVEL
string( REGEX MATCHALL "[0-9]+" _my_ver_LIST "${MY_VER}" )
list( LENGTH _my_ver_LIST _my_list_len )
list( GET _my_ver_LIST 0 MY_VER_MAJOR )
list( GET _my_ver_LIST 1 MY_VER_MINOR )
list( GET _my_ver_LIST 2 MY_VER_PATCH )
if( _my_list_len EQUAL 4 )
  list( GET _my_ver_LIST 3 MY_VER_PATCHLEVEL )
  message( "Patch level: ${MY_VER_PATCHLEVEL}" )
endif()

string( TIMESTAMP MY_CURRENT_TIMESTAMP "%Y-%m-%d %H:%M:%S UTC" UTC )

## Include local cmake module directory
set( CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH}
    "${CMAKE_SOURCE_DIR}/cmake/modules" )

if( WIN32 )
  ## Apply MSVC project config
  include( use_msvc_project_config )

  include_directories(
      ${CMAKE_SOURCE_DIR}/external
      ${CMAKE_SOURCE_DIR}/sqlite/core
      ${CMAKE_CURRENT_BINARY_DIR} )

  ## Set project sources
  set( MY_PROJECT_HEADERS
      sqlite/core/sqlite3.h
      sqlite/core/sqlite3ext.h
      sqlite/generic/interop.h )
  set( MY_PROJECT_SOURCES
      sqlite/generic/interop.c )

  ## Set dll options
  include( generate_product_dll_version )
  generate_product_dll_version( MY_VERSION_FILES
      NAME ${MY_PROJECT_DESC}
      VERSION_MAJOR ${MY_VER_MAJOR}
      VERSION_MINOR ${MY_VER_MINOR}
      VERSION_PATCH ${MY_VER_PATCH}
      VERSION_REVISION ${MY_REVISION}
      ORIGINAL_FILENAME "${PROJECT_NAME}${MY_PROJECT_SUFFIX}.dll" )

  ## Add additional definitions
  add_definitions(
      -D_CRT_SECURE_NO_WARNINGS
      -D_UNICODE
      -DINTEROP_EXTENSION_FUNCTIONS=1
      -DINTEROP_FTS5_EXTENSION=1
      -DINTEROP_PERCENTILE_EXTENSION=1
      -DINTEROP_PLACEHOLDER=1
      -DINTEROP_REGEXP_EXTENSION=1
      -DINTEROP_SESSION_EXTENSION=1
      -DINTEROP_SHA1_EXTENSION=1
      -DINTEROP_SOURCE_ID="${MY_PROJECT_SOURCE_ID}"
      -DINTEROP_SOURCE_TIMESTAMP="${MY_CURRENT_TIMESTAMP}"
      -DINTEROP_TOTYPE_EXTENSION=1
      -DINTEROP_VERSION="${MY_VER}.${MY_REVISION}"
      -DINTEROP_VIRTUAL_TABLE=1
      -DSQLITE_ENABLE_API_ARMOR=1
      -DSQLITE_ENABLE_COLUMN_METADATA=1
      -DSQLITE_ENABLE_DBPAGE_VTAB=1
      -DSQLITE_ENABLE_DBSTAT_VTAB=1
      -DSQLITE_ENABLE_FTS3=1
      -DSQLITE_ENABLE_LOAD_EXTENSION=1
      -DSQLITE_ENABLE_MATH_FUNCTIONS=1
      -DSQLITE_ENABLE_MEMORY_MANAGEMENT=1
      -DSQLITE_ENABLE_RTREE=1
      -DSQLITE_ENABLE_STAT4=1
      -DSQLITE_ENABLE_STMTVTAB=1
      -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1
      -DSQLITE_SOUNDEX=1
      -DSQLITE_THREADSAFE=1
      -DSQLITE_USE_URI=1 )

  ## Collect all project compile units
  add_library(
      ${PROJECT_NAME} SHARED
      ${MY_PROJECT_HEADERS}
      ${MY_PROJECT_SOURCES}
      ${MY_VERSION_FILES} )
  add_library(
      ${PROJECT_NAME}_static STATIC
      ${MY_PROJECT_HEADERS}
      ${MY_PROJECT_SOURCES}
      ${MY_VERSION_FILES} )

  target_compile_definitions(
      ${PROJECT_NAME}_static PUBLIC
      ${PROJECT_NAME}_STATIC=1 )

  ## Set output name
  set_target_properties(
      ${PROJECT_NAME} PROPERTIES
      OUTPUT_NAME ${PROJECT_NAME}${MY_PROJECT_SUFFIX} )
  set_target_properties(
      ${PROJECT_NAME}_static PROPERTIES
      OUTPUT_NAME ${PROJECT_NAME}${MY_PROJECT_SUFFIX}_static )

  ## Set test sources
  set( MY_TEST_SOURCES
      test_sqlite.cpp )

  ## Collect all test compile units
  add_executable(
      test_${PROJECT_NAME}
      ${MY_TEST_SOURCES}
      ${MY_VERSION_FILES} )
  add_executable(
      test_${PROJECT_NAME}_static
      ${MY_TEST_SOURCES}
      ${MY_VERSION_FILES} )

  ## Set shell sources
  set( MY_SHELL_SOURCES
      sqlite/core/shell.c )

  ## Collect all shell compile units
  add_executable(
      sqlite_shell
      ${MY_SHELL_SOURCES} )
  
  ## Set compile-time dependency libraries
  target_link_libraries(
      sqlite_shell
      ${PROJECT_NAME} )
  target_link_libraries(
      test_${PROJECT_NAME}
      ${PROJECT_NAME} )
  target_link_libraries(
      test_${PROJECT_NAME}_static
      ${PROJECT_NAME}_static )

  if( BUILD_WITH_WORKAROUND_ARM64RT )
    target_link_libraries(
        ${PROJECT_NAME}
        arm64rt.lib )
    target_link_libraries(
        ${PROJECT_NAME}_static
        arm64rt.lib )
  endif()

  if( BUILD_WITH_WORKAROUND_SOFTINTRIN )
    target_link_libraries(
        ${PROJECT_NAME}
        softintrin.lib )
    target_link_libraries(
        ${PROJECT_NAME}_static
        softintrin.lib )
  endif()

  if( BUILD_WITH_TEST_RUNNER )
    enable_testing()
    add_test(
        catch2test
        ${PROJECT_BINARY_DIR}/test_${PROJECT_NAME} )
    add_test(
        catch2test_static
        ${PROJECT_BINARY_DIR}/test_${PROJECT_NAME}_static )
  endif()
endif()
