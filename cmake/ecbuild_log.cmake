# (C) Copyright 1996-2016 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

##############################################################################
#.rst:
#
# Logging
# =======
#
# ecBuild provides macros for logging based on a log level set by the user,
# similar to the Python logging module:
#
# :ecbuild_debug:     logs a ``STATUS`` message if log level <= ``DEBUG``
# :ecbuild_info:      logs a ``STATUS`` message if log level <= ``INFO``
# :ecbuild_warn:      logs a ``WARNING`` message if log level <= ``WARN``
# :ecbuild_error:     logs a ``SEND_ERROR`` message if log level <= ``ERROR``
# :ecbuild_critical:  logs a ``FATAL_ERROR`` message if log level <= ``CRITICAL``
# :ecbuild_deprecate: logs a ``DEPRECATION`` message
#
# Input variables
# ---------------
#
# CMake variables controlling logging behaviour:
#
# ECBUILD_LOG_FILE : path
#   set the log file, defaults to ``${CMAKE_BINARY_DIR}/ecbuild.log``
#
#   All ecBuild log macros write their messages to this log file with a time
#   stamp. Messages emitted by CMake directly cannot be logged to file.
#
# ECBUILD_LOG_LEVEL : string, one of DEBUG, INFO, WARN, ERROR, CRITICAL, OFF
#   set the desired log level, OFF to disable logging altogether
#
# ECBUILD_NO_COLOUR : bool
#   if set, does not colour log output (by default log output is coloured)
#
# ECBUILD_NO_DEPRECATIONS : bool
#   if set, does not output deprecation messages (only set this if you *really*
#   know what you are doing!)
#
# Usage
# -----
#
# The macros ``ecbuild_debug`` and ``ecbuild_info`` can be used to output
# messages which are not printed by default. Many ecBuild macros use this
# facility to log debugging hints. When debugging a CMake run, users can use
# ``-DECBUILD_LOG_LEVEL=DEBUG`` to get detailed diagnostics.
#
##############################################################################

# Define colour escape sequences (https://stackoverflow.com/a/19578320/396967)
if(NOT (WIN32 OR ECBUILD_NO_COLOUR))
  string(ASCII 27 Esc)
  set(ColourReset "${Esc}[m")
  set(ColourBold  "${Esc}[1m")
  set(Red         "${Esc}[31m")
  set(Green       "${Esc}[32m")
  set(Yellow      "${Esc}[33m")
  set(Blue        "${Esc}[34m")
  set(Magenta     "${Esc}[35m")
  set(Cyan        "${Esc}[36m")
  set(White       "${Esc}[37m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldGreen   "${Esc}[1;32m")
  set(BoldYellow  "${Esc}[1;33m")
  set(BoldBlue    "${Esc}[1;34m")
  set(BoldMagenta "${Esc}[1;35m")
  set(BoldCyan    "${Esc}[1;36m")
  set(BoldWhite   "${Esc}[1;37m")
endif()

set(ECBUILD_DEBUG    10)
set(ECBUILD_INFO     20)
set(ECBUILD_WARN     30)
set(ECBUILD_ERROR    40)
set(ECBUILD_CRITICAL 50)

if( NOT DEFINED ECBUILD_LOG_LEVEL )
  set(ECBUILD_LOG_LEVEL ${ECBUILD_INFO})
elseif( NOT ECBUILD_LOG_LEVEL )
  set(ECBUILD_LOG_LEVEL 60)
elseif( ECBUILD_LOG_LEVEL STREQUAL "DEBUG" )
  set(ECBUILD_LOG_LEVEL ${ECBUILD_DEBUG})
elseif( ECBUILD_LOG_LEVEL STREQUAL "INFO" )
  set(ECBUILD_LOG_LEVEL ${ECBUILD_INFO})
elseif( ECBUILD_LOG_LEVEL STREQUAL "WARN" )
  set(ECBUILD_LOG_LEVEL ${ECBUILD_WARN})
elseif( ECBUILD_LOG_LEVEL STREQUAL "ERROR" )
  set(ECBUILD_LOG_LEVEL ${ECBUILD_ERROR})
elseif( ECBUILD_LOG_LEVEL STREQUAL "CRITICAL" )
  set(ECBUILD_LOG_LEVEL ${ECBUILD_CRITICAL})
else()
  message(WARNING "Unknown log level ${ECBUILD_LOG_LEVEL} (valid are DEBUG, INFO, WARN, ERROR, CRITICAL) - using WARN")
  set(ECBUILD_LOG_LEVEL ${ECBUILD_WARN})
endif()

if( NOT DEFINED ECBUILD_LOG_FILE )
  set( ECBUILD_LOG_FILE ${CMAKE_BINARY_DIR}/ecbuild.log )
endif()

##############################################################################

macro( ecbuild_log LEVEL )
  string( REPLACE ";" " " MSG "${ARGN}" )
  string( TIMESTAMP _time )
  file( APPEND ${ECBUILD_LOG_FILE} "${_time} - ${LEVEL} - ${MSG}\n" )
endmacro( ecbuild_log )

##############################################################################

macro( ecbuild_debug )
  string( REPLACE ";" " " MSG "${ARGV}" )
  ecbuild_log(DEBUG "${MSG}")
  if( ECBUILD_LOG_LEVEL LESS 11)
    message(STATUS "${Blue}DEBUG - ${MSG}${ColourReset}")
  endif()
endmacro( ecbuild_debug )

##############################################################################

macro( ecbuild_info )
  string( REPLACE ";" " " MSG "${ARGV}" )
  ecbuild_log(INFO "${MSG}")
  if( ECBUILD_LOG_LEVEL LESS 21)
    message(STATUS "${Green}INFO - ${MSG}${ColourReset}")
  endif()
endmacro( ecbuild_info )

##############################################################################

macro( ecbuild_warn )
  string( REPLACE ";" " " MSG "${ARGV}" )
  ecbuild_log(WARNING "${MSG}")
  if( ECBUILD_LOG_LEVEL LESS 31)
    message(WARNING "${Yellow}WARN - ${MSG}${ColourReset}")
  endif()
endmacro( ecbuild_warn )

##############################################################################

macro( ecbuild_error )
  string( REPLACE ";" " " MSG "${ARGV}" )
  ecbuild_log(ERROR "${MSG}")
  if( ECBUILD_LOG_LEVEL LESS 41)
    message(SEND_ERROR "${BoldRed}ERROR - ${MSG}${ColourReset}")
  endif()
endmacro( ecbuild_error )

##############################################################################

macro( ecbuild_deprecate )
  string(REPLACE ";" " " MSG ${ARGV})
  ecbuild_log(DEPRECATION "${MSG}")
  if( NOT ECBUILD_NO_DEPRECATIONS )
    message(DEPRECATION "${BoldRed}${MSG}${ColourReset}")
  endif()
endmacro( ecbuild_deprecate )

##############################################################################

macro( ecbuild_critical )
  string(REPLACE ";" " " MSG ${ARGV})
  ecbuild_log(FATAL_ERROR "${MSG}")
  if( ECBUILD_LOG_LEVEL LESS 51)
    message(FATAL_ERROR "${BoldMagenta}CRITICAL - ${MSG}${ColourReset}")
  endif()
endmacro( ecbuild_critical )

##############################################################################
# macro for debugging a cmake variable

macro( ecbuild_debug_var VAR )
  ecbuild_log(DEBUG "${VAR} : ${${VAR}}")
  if( ECBUILD_LOG_LEVEL LESS 11)
    message(STATUS "${Blue}DEBUG - ${VAR} : ${${VAR}}${ColourReset}")
  endif()
endmacro()

##############################################################################
# macro for debugging a cmake variable

macro( ecbuild_debug_list VAR )
  ecbuild_log(DEBUG "${VAR} : ${${VAR}}")
  foreach( _elem ${${VAR}} )
    ecbuild_log( DEBUG "  ${_elem}" )
  endforeach()
  if( ECBUILD_LOG_LEVEL LESS 11)
    message( STATUS "${Blue}DEBUG - ${VAR}" )
    foreach( _elem ${${VAR}} )
      message( STATUS "  ${_elem}" )
    endforeach()
    message(STATUS "${ColourReset}")
  endif()
endmacro()

##############################################################################
# macro for debugging a environment variable within cmake

macro( ecbuild_debug_env_var VAR )
  ecbuild_log(DEBUG "ENV ${VAR} : $ENV{${VAR}}")
  if( ECBUILD_LOG_LEVEL LESS 11)
    message(STATUS "${Blue}DEBUG - ENV ${VAR} [$ENV{${VAR}}]${ColourReset}")
  endif()
endmacro()

##############################################################################
# macro for debugging a cmake variable

macro( debug_var VAR )

    message( WARNING "DEPRECATED debug_var() -- ${VAR} [${${VAR}}]" )

endmacro()

##############################################################################
# macro for debugging a cmake list

macro( debug_list VAR )

    message( WARNING "DEPRECATED debug_list() -- ${VAR}:" )
    foreach( _elem ${${VAR}} )
      message( WARNING "  ${_elem}" )
    endforeach()

endmacro()

##############################################################################
# macro for debugging a environment variable within cmake

macro( debug_env_var VAR )

    message( WARNING "DEPRECATED debug_env_var() -- ENV ${VAR} [$ENV{${VAR}}]" )

endmacro()
