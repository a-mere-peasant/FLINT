# - Find NetCDF
# Find the native NetCDF includes and library
#
#  NETCDF_INCLUDE_DIR  - user modifiable choice of where netcdf headers are
#  NETCDF_LIBRARY      - user modifiable choice of where netcdf libraries are
#
# Your package can require certain interfaces to be FOUND by setting these
#
#  NETCDF_CXX         - require the C++ interface and link the C++ library
#  NETCDF_F77         - require the F77 interface and link the fortran library
#  NETCDF_F90         - require the F90 interface and link the fortran library
#
# Or equivalently by calling FindNetCDF with a COMPONENTS argument containing one or
# more of "CXX;F77;F90".
#
# When interfaces are requested the user has access to interface specific hints:
#
#  NETCDF_${LANG}_INCLUDE_DIR - where to search for interface header files
#  NETCDF_${LANG}_LIBRARY     - where to search for interface libraries
#
# This module returns these variables for the rest of the project to use.
#
#  NETCDF_FOUND          - True if NetCDF found including required interfaces (see below)
#  NETCDF_LIBRARIES      - All netcdf related libraries.
#  NETCDF_INCLUDE_DIRS   - All directories to include.
#  NETCDF_HAS_INTERFACES - Whether requested interfaces were found or not.
#  NETCDF_${LANG}_INCLUDE_DIRS/NETCDF_${LANG}_LIBRARIES - C/C++/F70/F90 only interface
#
# Normal usage would be:
#  set (NETCDF_F90 "YES")
#  find_package (NetCDF REQUIRED)
#  target_link_libraries (uses_everthing ${NETCDF_LIBRARIES})
#  target_link_libraries (only_uses_f90 ${NETCDF_F90_LIBRARIES})

#search starting from user editable cache var
if (NETCDF_INCLUDE_DIR AND NETCDF_LIBRARY)
  # Already in cache, be silent
  set (NETCDF_FIND_QUIETLY TRUE)
endif ()

set(USE_DEFAULT_PATHS "NO_DEFAULT_PATH")
if(NETCDF_USE_DEFAULT_PATHS)
  set(USE_DEFAULT_PATHS "")
endif()

find_path (NETCDF_INCLUDE_DIR netcdf.h
  PATHS 
	"${NETCDF_DIR}/Debug/include"
	"C:/Development/Software/NetCDF/Debug/include"
)
#set(NETCDF_INCLUDE_DIR ${NETCDF_INCLUDE_DIR_DEBUG})
mark_as_advanced (NETCDF_INCLUDE_DIR)
set (NETCDF_C_INCLUDE_DIRS ${NETCDF_INCLUDE_DIR})

find_library (NETCDF_LIBRARY_DEBUG NAMES netcdf
  PATHS 
	"${NETCDF_DIR}/Debug/lib"
	"C:/Development/Software/NetCDF/Debug/lib"
  HINTS "${NETCDF_INCLUDE_DIR}/Debug/../lib")
#mark_as_advanced (NETCDF_LIBRARY_DEBUG)
#set (NETCDF_C_LIBRARIES ${NETCDF_LIBRARY_DEBUG})

find_library (NETCDF_LIBRARY_RELEASE NAMES netcdf
  PATHS 
	"${NETCDF_DIR}/Release/lib"
	"C:/Development/Software/NetCDF/Release/lib"
  HINTS "${NETCDF_INCLUDE_DIR}/Release/../lib")
#mark_as_advanced (NETCDF_LIBRARY_RELEASE)
#set (NETCDF_C_LIBRARIES ${NETCDF_LIBRARY_RELEASE})

set (NETCDF_LIBRARY	    debug		${NETCDF_LIBRARY_DEBUG}
						optimized	${NETCDF_LIBRARY_RELEASE}
	CACHE STRING "NETCDF_LIBRARY libraries")
mark_as_advanced(NETCDF_LIBRARY)
set (NETCDF_C_LIBRARIES ${NETCDF_LIBRARY})

#start finding requested language components
set (NetCDF_libs "")
set (NetCDF_includes "${NETCDF_INCLUDE_DIR}")

get_filename_component (NetCDF_lib_dirs "${NETCDF_LIBRARY}" PATH)
set (NETCDF_HAS_INTERFACES "YES") # will be set to NO if we're missing any interfaces

macro (NetCDF_check_interface lang header libs)
  if (NETCDF_${lang})
    #search starting from user modifiable cache var
    find_path (NETCDF_${lang}_INCLUDE_DIR NAMES ${header}
      HINTS "${NETCDF_INCLUDE_DIR}"
      HINTS "${NETCDF_${lang}_ROOT}/include"
      ${USE_DEFAULT_PATHS})

    find_library (NETCDF_${lang}_LIBRARY NAMES ${libs}
      HINTS "${NetCDF_lib_dirs}"
      HINTS "${NETCDF_${lang}_ROOT}/lib"
      ${USE_DEFAULT_PATHS})

    mark_as_advanced (NETCDF_${lang}_INCLUDE_DIR NETCDF_${lang}_LIBRARY)

    #export to internal varS that rest of project can use directly
    set (NETCDF_${lang}_LIBRARIES ${NETCDF_${lang}_LIBRARY})
    set (NETCDF_${lang}_INCLUDE_DIRS ${NETCDF_${lang}_INCLUDE_DIR})

    if (NETCDF_${lang}_INCLUDE_DIR AND NETCDF_${lang}_LIBRARY)
      list (APPEND NetCDF_libs ${NETCDF_${lang}_LIBRARY})
      list (APPEND NetCDF_includes ${NETCDF_${lang}_INCLUDE_DIR})
    else ()
      set (NETCDF_HAS_INTERFACES "NO")
      message (STATUS "Failed to find NetCDF interface for ${lang}")
    endif ()
  endif ()
endmacro ()

macro (NetCDF_check_interface_config lang config header libs)
  if (NETCDF_${lang})
    #search starting from user modifiable cache var
    find_path (NETCDF_${lang}_INCLUDE_DIR_${config} NAMES ${header}
	  PATHS 
		"${NETCDF_CXX_DIR}/${Config}/include"
		"C:/Development/Software/NCXX/${config}/include"
      HINTS "${NETCDF_INCLUDE_DIR}/${config}"
      HINTS "${NETCDF_${lang}_ROOT}/${config}/include"
      #${USE_DEFAULT_PATHS}
	  )

    find_library (NETCDF_${lang}_LIBRARY_${config} NAMES ${libs}
	  PATHS 
		"${NETCDF_CXX_DIR}/${config}/lib"
		"C:/Development/Software/NCXX/${config}/lib"
      HINTS "${NetCDF_lib_dirs}/${config}"
      HINTS "${NETCDF_${lang}_ROOT}/${config}/lib"
      #${USE_DEFAULT_PATHS}
	  )

    mark_as_advanced (NETCDF_${lang}_INCLUDE_DIR_${config} NETCDF_${lang}_LIBRARY_${config})

    if (NETCDF_${lang}_INCLUDE_DIR_${config} AND NETCDF_${lang}_LIBRARY_${config})
	#
    else ()
      set (NETCDF_HAS_INTERFACES "NO")
      message (STATUS "Failed to find NetCDF interface for ${lang}")
    endif ()
  endif ()
endmacro ()

macro (NetCDF_set_interface_config lang config_release config_debug)
  if (NETCDF_${lang})

    set (NETCDF_${lang}_LIBRARIES	    debug		${NETCDF_${lang}_LIBRARY_${config_debug}}
										optimized	${NETCDF_${lang}_LIBRARY_${config_release}}
										CACHE STRING "NETCDF_${lang}_LIBRARIES")

    set (NETCDF_${lang}_INCLUDE_DIRS	${NETCDF_${lang}_INCLUDE_DIR_${config_debug}} 
										CACHE STRING "NETCDF_${lang}_INCLUDE_DIRS")

	list (APPEND NetCDF_libs ${NETCDF_${lang}_LIBRARIES})
	list (APPEND NetCDF_includes ${NETCDF_${lang}_INCLUDE_DIRS})
  endif ()
endmacro ()


list (FIND NetCDF_FIND_COMPONENTS "CXX" _nextcomp)
if (_nextcomp GREATER -1)
  set (NETCDF_CXX 1)
endif ()
list (FIND NetCDF_FIND_COMPONENTS "F77" _nextcomp)
if (_nextcomp GREATER -1)
  set (NETCDF_F77 1)
endif ()
list (FIND NetCDF_FIND_COMPONENTS "F90" _nextcomp)
if (_nextcomp GREATER -1)
  set (NETCDF_F90 1)
endif ()

NetCDF_check_interface_config (CXX Debug ncVar.h netcdf-cxx4)
NetCDF_check_interface_config (CXX Release ncVar.h netcdf-cxx4)
NetCDF_set_interface_config (CXX Release Debug)

#NetCDF_check_interface (CXX netcdfcpp.h netcdf_c++)
NetCDF_check_interface (F77 netcdf.inc  netcdff)
NetCDF_check_interface (F90 netcdf.mod  netcdff)

#export accumulated results to internal varS that rest of project can depend on
list (APPEND NetCDF_libs "${NETCDF_C_LIBRARIES}")
set (NETCDF_LIBRARIES ${NetCDF_libs})
set (NETCDF_INCLUDE_DIRS ${NetCDF_includes})

# handle the QUIETLY and REQUIRED arguments and set NETCDF_FOUND to TRUE if
# all listed variables are TRUE
include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (NetCDF
  DEFAULT_MSG NETCDF_LIBRARIES NETCDF_INCLUDE_DIRS NETCDF_HAS_INTERFACES)