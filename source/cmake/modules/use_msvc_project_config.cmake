#
#
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

if( MSVC )
  string(APPEND CMAKE_CXX_FLAGS " /EHsc")
endif()

if( BUILD_WITH_SHARED_VCRT )
  ## Presets:
  ##   Use /MD build instead of /MT to be dependent on msvcrtXXX.dll
  foreach( flag_var
      CMAKE_C_FLAGS
      CMAKE_C_FLAGS_DEBUG
      CMAKE_C_FLAGS_RELEASE
      CMAKE_C_FLAGS_MINSIZEREL
      CMAKE_C_FLAGS_RELWITHDEBINFO
      CMAKE_CXX_FLAGS
      CMAKE_CXX_FLAGS_DEBUG
      CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_MINSIZEREL
      CMAKE_CXX_FLAGS_RELWITHDEBINFO )
    if( ${flag_var} MATCHES "/MT" )
      string( REGEX REPLACE "/MT" "/MD" ${flag_var} "${${flag_var}}" )
    endif()
  endforeach()
endif()

if( BUILD_WITH_STATIC_VCRT )
  ## Presets:
  ##   Use /MT build instead of /MD to avoid msvcrtXXX.dll
  foreach( flag_var
      CMAKE_C_FLAGS
      CMAKE_C_FLAGS_DEBUG
      CMAKE_C_FLAGS_RELEASE
      CMAKE_C_FLAGS_MINSIZEREL
      CMAKE_C_FLAGS_RELWITHDEBINFO
      CMAKE_CXX_FLAGS
      CMAKE_CXX_FLAGS_DEBUG
      CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_MINSIZEREL
      CMAKE_CXX_FLAGS_RELWITHDEBINFO )
    if( ${flag_var} MATCHES "/MD" )
      string( REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}" )
    endif()
  endforeach()
endif()

if( BUILD_WITH_WORKAROUND_OPT_GY )
  ## Presets:
  ##   Use /Gy for enabling function-level linking
  check_c_compiler_flag( -Gy HAS_GY_C )
  if( HAS_GY_C )
    string(APPEND CMAKE_C_FLAGS " /Gy")
  endif()
  check_cxx_compiler_flag( -Gy HAS_GY_CXX )
  if( HAS_GY_CXX )
    string(APPEND CMAKE_CXX_FLAGS " /Gy")
  endif()
endif()

if( BUILD_WITH_WORKAROUND_SPECTRE )
  ## Presets:
  ##   Use /Qspectre for Spectre mitigation
  check_cxx_compiler_flag( -Qspectre HAS_QSPECTRE )
  if( HAS_QSPECTRE )
    string(APPEND CMAKE_CXX_FLAGS " /Qspectre")
  endif()
endif()

## Use /Z7 build instead of /Zi to avoid vcXXX.pdb
foreach( flag_var
    CMAKE_C_FLAGS
    CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE
    CMAKE_C_FLAGS_MINSIZEREL
    CMAKE_C_FLAGS_RELWITHDEBINFO
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_CXX_FLAGS_MINSIZEREL
    CMAKE_CXX_FLAGS_RELWITHDEBINFO )
  if( ${flag_var} MATCHES "/Zi" )
    string( REGEX REPLACE "/Zi" "/Z7" ${flag_var} "${${flag_var}}" )
  endif()
endforeach()
