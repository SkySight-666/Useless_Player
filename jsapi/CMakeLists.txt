cmake_minimum_required(VERSION 3.10)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

if(NOT DEFINED ENV{CROSS_TOOLCHAIN_PREFIX})
  message(FATAL_ERROR "CROSS_TOOLCHAIN_PREFIX environment variable is not set")
endif()

set(CMAKE_C_COMPILER "$ENV{CROSS_TOOLCHAIN_PREFIX}gcc")
set(CMAKE_CXX_COMPILER "$ENV{CROSS_TOOLCHAIN_PREFIX}g++")

execute_process(
  COMMAND ${CMAKE_C_COMPILER} -print-sysroot
  OUTPUT_VARIABLE GCC_NATIVE_SYSROOT
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_SYSROOT "${GCC_NATIVE_SYSROOT}")

if(NOT "${CMAKE_SYSROOT}" STREQUAL "")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot=${CMAKE_SYSROOT}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --sysroot=${CMAKE_SYSROOT}")
endif()

project(player_native C CXX)

set(IOT_UI_SDK_PATH "${CMAKE_SOURCE_DIR}/iot-miniapp-sdk")
set(MID_LIB_NAME iot_sdk_lib)
set(LIB_NAME player_native)

include_directories(
  ${CMAKE_SOURCE_DIR}/src
  ${CMAKE_SOURCE_DIR}/include
  ${IOT_UI_SDK_PATH}/include
)

set(CMAKE_CXX_STANDARD 17)
add_compile_options(-Wall -Werror=return-type -Wno-psabi)

file(GLOB_RECURSE LIB_SOURCES ${IOT_UI_SDK_PATH}/src/*.cpp)
add_library(${MID_LIB_NAME} STATIC ${LIB_SOURCES})
target_compile_options(${MID_LIB_NAME} PRIVATE -w)
target_include_directories(${MID_LIB_NAME} PUBLIC ${IOT_UI_SDK_PATH}/include)
set_target_properties(${MID_LIB_NAME} PROPERTIES POSITION_INDEPENDENT_CODE ON)

file(GLOB_RECURSE SOURCES ${CMAKE_SOURCE_DIR}/src/*.cpp)
add_library(${LIB_NAME} SHARED ${SOURCES})

target_link_libraries(${LIB_NAME} PRIVATE
  ${MID_LIB_NAME}
  pthread
  dl
  -Wl,-unresolved-symbols=ignore-all
)
