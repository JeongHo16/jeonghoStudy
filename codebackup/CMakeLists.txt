# -*- mode: cmake; -*-
cmake_minimum_required(VERSION 3.0)

project (QP_controller)

# include ../Common.cmake
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../taesooLib/Samples")
get_filename_component(CAR_SAMPLE_DIR ${CMAKE_SOURCE_DIR} PATH)
get_filename_component(PROJ_ROOT_DIR ${CAR_SAMPLE_DIR} PATH)
set(TAESOOLIB_DIR "${PROJ_ROOT_DIR}/taesooLib")
set(SAMPLE_DIR "${PROJ_ROOT_DIR}/taesooLib/Samples")
set(BUILD_CONSOLE OFF CACHE BOOL "BuildConsole option")

if (APPLE)
	include(FindPkgConfig)
	pkg_search_module(PYTHON3 REQUIRED python3)
	message(${PYTHON3_LIBDIR})
endif()

if (WIN32)
	message(${TAESOOLIB_DIR})
	include(Common_fast) 

	set(LUNA_GEN "${TAESOOLIB_DIR}/MainLib/WrapperLua/luna_gen.lua")
else()
	if(BUILD_CONSOLE)
		add_definitions(-DSEGA)				
		add_definitions(-DNO_GUI -DNO_OGRE)  
		set(NO_GUI TRUE)
	endif()

	set(useShared TRUE)
	set(NoDevil TRUE)
	set(NoFreeImage FALSE)
	set(NoLapack TRUE)
	set(NoUMFpack TRUE)

	include(Common_baselib) 
	if(BUILD_CONSOLE)
    	add_subdirectory(../../taesooLib/BaseLib "${CMAKE_SOURCE_DIR}/../build/BaseLib/build_shared_console_${CMAKE_BUILD_TYPE}" )
    else()
    	add_subdirectory(../../taesooLib/BaseLib "${CMAKE_SOURCE_DIR}/../build/BaseLib/build_shared_${CMAKE_BUILD_TYPE}" )
    endif()

	if(BUILD_CONSOLE)
    	add_subdirectory(../../taesooLib/MainLib "${CMAKE_SOURCE_DIR}/../build/MainLib/build_shared_console_${CMAKE_BUILD_TYPE}" )
    else()
    	add_subdirectory(../../taesooLib/MainLib "${CMAKE_SOURCE_DIR}/../build/MainLib/build_shared_${CMAKE_BUILD_TYPE}" )
    endif()

	include(Common_mainlib) 

	# PhysicsLib settings
	set(NoAISTsim TRUE) # use TRL_LCP instead!
	set(NoGMBSsim TRUE) # use TRL_LCP instead!
	set(NoUTsim TRUE) # use TRL_LCP instead!
	set(NoBulletSim TRUE) # use TRL_LCP instead!

	if(BUILD_CONSOLE)
    	add_subdirectory(../../taesooLib/PhysicsLib "${CMAKE_SOURCE_DIR}/../build/PhysicsLib/build_shared_console_${CMAKE_BUILD_TYPE}" )
    	add_subdirectory(../../taesooLib/ClassificationLib "${CMAKE_SOURCE_DIR}/../build/ClassificationLib/build_shared_console_${CMAKE_BUILD_TYPE}" )
    else()
    	add_subdirectory(../../taesooLib/PhysicsLib "${CMAKE_SOURCE_DIR}/../build/PhysicsLib/build_shared_${CMAKE_BUILD_TYPE}" )
    	add_subdirectory(../../taesooLib/ClassificationLib "${CMAKE_SOURCE_DIR}/../build/ClassificationLib/build_shared_${CMAKE_BUILD_TYPE}" )
    endif()

endif()

set(BUILD_EXE OFF CACHE BOOL "BuildExe option")

add_definitions(-D_USRDLL)
add_definitions(-DMAINLIBPYTHON_EXPORTS)
add_definitions(-DML_LIBRARY)

add_definitions(-DNUITRACKSDK_DIR)
set(NUITRACK_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/NuitrackSDK/Nuitrack/include ${CMAKE_CURRENT_SOURCE_DIR}/NuitrackSDK/Nuitrack/include/middleware)
set(NUITRACK_LIBRARY_PATH ${CMAKE_CURRENT_SOURCE_DIR}/NuitrackSDK/Nuitrack/lib/linux64)

include_directories (	
	${PYTHON3_INCLUDE_DIRS}
	"/usr/include/python3.6"
	"/usr/include/python3.7m"
	"/usr/include/python3.8"
	"/usr/local/lib/python3.6/dist-packages/numpy/core/include" #numpy headers
	"/usr/local/lib/python3.8/site-packages/numpy/core/include"
	.
	../../taesooLib/Samples/scripts
	${NUITRACK_INCLUDE_PATH}
	)
link_directories(${NUITRACK_LIBRARY_PATH})
set(LIBS nuitrack jsoncpp)

set(src_python
# 	python only
  "MainlibPython.cpp"
  "MainlibPython.h"
  "PythonExtendWin.cpp"
  "PythonExtendWin.h"
  "./main.cpp"
  )
set(src
  "${TAESOOLIB_DIR}/Samples/classification/cma/cmaes.c"
  "${TAESOOLIB_DIR}/Samples/classification/cma/CMAwrap.cpp"
  "${TAESOOLIB_DIR}/Samples/classification/cma/CMAwrap.h"
  )
set(src11 )

set(luna_script "${CMAKE_SOURCE_DIR}")

add_custom_command(
	OUTPUT "${luna_script}/luna_QP.cpp"
	DEPENDS "${luna_script}/luna_QP.lua" "${LUNA_GEN}" 
	PRE_BUILD
	COMMAND lua "${LUNA_GEN}" "${luna_script}/luna_QP.lua"
)

if(UNIX)
	#SET_SOURCE_FILES_PROPERTIES( ${src11} PROPERTIES COMPILE_FLAGS "--std=c++0x")
endif()

if(WIN32)
	
else()
	set(TAESOO_LIBS
		BaseLib
		MainLib
		PhysicsLib
		ClassificationLib
		)
endif()

if(BUILD_EXE)
	# build an executable that runs without python dependencies
	# for example, cd ../work; ./nopython aaa.lua
	set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CAR_SAMPLE_DIR}/work )

	add_executable(nopython 
		main_standalone.cpp
		${src}
		${src11}
		"${CMAKE_SOURCE_DIR}/luna_QP.cpp" # important. without this, luna_gen doesn't run.
		${gmbs_src}
		)
	target_link_libraries(nopython 
		${TAESOO_LIBS}
		${FLTK_LIBS}
		${IMAGE_LIBS}
		${OGRE_LIBS}
		dl
		#boost_python3
		#boost_numpy
		pthread
		)
	message(${OGRE_LIBS})
else()

	set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CAR_SAMPLE_DIR}/work )


	set(usePybind11 TRUE)
	add_definitions(-DUSE_PYBIND11)
	add_subdirectory(pybind11)
	pybind11_add_module(libmainlib 
		${src}
		${src11}
		${src_python}
		"${CMAKE_SOURCE_DIR}/luna_QP.cpp" # important. without this, luna_gen doesn't run.
		${gmbs_src}
		)

	if(BUILD_CONSOLE)
		target_link_libraries(libmainlib PUBLIC
			${TAESOO_LIBS}
			${IMAGE_LIBS}
			#boost_numpy
			)
	else()
		target_link_libraries(libmainlib PUBLIC
			${TAESOO_LIBS}
			${FLTK_LIBS}
			${IMAGE_LIBS}
			${OGRE_LIBS}
			#boost_numpy
			${LIBS}
			)
	endif()
	if(APPLE)
	else()
		target_link_libraries(libmainlib PUBLIC dl)
	endif()

endif()

if(WIN32)
  add_custom_command(TARGET OgreFltk
                       POST_BUILD
                       COMMAND lua "${CMAKE_CURRENT_SOURCE_DIR}/build.lua" install)
endif()
