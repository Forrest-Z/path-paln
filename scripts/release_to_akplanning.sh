#!/bin/bash

PROJECT_DIR=`pwd`

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -m|--module)
    MODULE=$2
    shift # past argument
    shift # past value
    ;;
    -t|--type)
    TYPE=$2
    shift # past argument
    shift # past value
    ;;
    -p|--platform)
    PLATFORM=$2
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

BUILD_MODULE=${MODULE}
BUILD_TYPE=${TYPE:-release}
BUILD_PLATFORM=${PLATFORM:-x86_64}

DEST_INCLUDE=$PROJECT_DIR/include
DEST_CONTROLLER_INCLUDE=$DEST_INCLUDE/controller
DEST_DATA_INCLUDE=$DEST_INCLUDE/data
DEST_DETECTOR_INCLUDE=$DEST_INCLUDE/detector
DEST_MAP_INCLUDE=$DEST_INCLUDE/map
DEST_PLANNER_INCLUDE=$DEST_INCLUDE/planner
DEST_UTILS_INCLUDE=$DEST_INCLUDE/utils
DEST_BIN=$PROJECT_DIR/bin/$BUILD_PLATFORM/$BUILD_TYPE
DEST_LIB=$PROJECT_DIR/lib/$BUILD_PLATFORM/$BUILD_TYPE

mkdir -p $DEST_CONTROLLER_INCLUDE
mkdir -p $DEST_DATA_INCLUDE
mkdir -p $DEST_DETECTOR_INCLUDE
mkdir -p $DEST_MAP_INCLUDE
mkdir -p $DEST_PLANNER_INCLUDE
mkdir -p $DEST_UTILS_INCLUDE
mkdir -p $DEST_BIN
mkdir -p $DEST_LIB

SRC=$PROJECT_DIR/src
SRC_CONTROLLER=$SRC/controller
SRC_DATA=$SRC/data
SRC_DETECTOR=$SRC/detector
SRC_MAP=$SRC/map
SRC_PLANNER=$SRC/planner
SRC_UTILS=$SRC/utils

################### controller ##################

SRC_CONTROLLER_INCLUDE=$SRC_CONTROLLER/include
SRC_TASK=$SRC_CONTROLLER/task
SRC_SPEED_CONTROLLER=$SRC_CONTROLLER/speed_controller
SRC_LOCAL_PLANNER=$SRC_CONTROLLER/local_planner
SRC_LOCAL_PLANNER_INCLUDE=$SRC_LOCAL_PLANNER/include
SRC_ROTATE_PLANNER=$SRC_LOCAL_PLANNER/rotate_planner
SRC_BASIC_PLANNER=$SRC_LOCAL_PLANNER/basic_planner
SRC_MPC_PLANNER=$SRC_LOCAL_PLANNER/mpc_planner
SRC_PURE_PURSUIT_PLANNER=$SRC_LOCAL_PLANNER/pure_pursuit_planner
# SRC_TEB_PLANNER=$SRC_LOCAL_PLANNER/teb_planner
SRC_WALL_FOLLOW_PLANNER=$SRC_LOCAL_PLANNER/wall_follow_planner
SRC_FDFS_PLANNER=$SRC_LOCAL_PLANNER/fdfs_planner

if [ "$BUILD_MODULE" = "task" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release task..."
    SRC_TASK_INCLUDE=$SRC_TASK/include
    SRC_TASK_LIB=$SRC_TASK/lib
    SRC_TASK_BIN=$SRC_TASK/test/bin

    cp -r $SRC_TASK_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_TASK_LIB/* $DEST_LIB
    cp $SRC_TASK_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "speed_controller" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release speed_controller..."
    SRC_SPEED_CONTROLLER_INCLUDE=$SRC_SPEED_CONTROLLER/include
    SRC_SPEED_CONTROLLER_LIB=$SRC_SPEED_CONTROLLER/lib
    SRC_SPEED_CONTROLLER_BIN=$SRC_SPEED_CONTROLLER/test/bin

    cp -r $SRC_SPEED_CONTROLLER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_SPEED_CONTROLLER_LIB/* $DEST_LIB
    cp $SRC_SPEED_CONTROLLER_BIN/* $DEST_BIN    
fi

if [ "$BUILD_MODULE" = "rotate_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release rotate_planner..."
    SRC_ROTATE_PLANNER_INCLUDE=$SRC_ROTATE_PLANNER/include
    SRC_ROTATE_PLANNER_LIB=$SRC_ROTATE_PLANNER/lib
    SRC_ROTATE_PLANNER_BIN=$SRC_ROTATE_PLANNER/test/bin

    cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp -r $SRC_ROTATE_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_ROTATE_PLANNER_LIB/* $DEST_LIB
    cp $SRC_ROTATE_PLANNER_BIN/* $DEST_BIN 
fi


if [ "$BUILD_MODULE" = "basic_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release basic_planner..."
    SRC_BASIC_PLANNER_INCLUDE=$SRC_BASIC_PLANNER/include
    SRC_BASIC_PLANNER_LIB=$SRC_BASIC_PLANNER/lib
    SRC_BASIC_PLANNER_BIN=$SRC_BASIC_PLANNER/test/bin

    cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp -r $SRC_BASIC_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_BASIC_PLANNER_LIB/* $DEST_LIB
    cp $SRC_BASIC_PLANNER_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "mpc_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release mpc_planner..."
    SRC_MPC_PLANNER_INCLUDE=$SRC_MPC_PLANNER/include
    SRC_MPC_PLANNER_LIB=$SRC_MPC_PLANNER/lib
    SRC_MPC_PLANNER_BIN=$SRC_MPC_PLANNER/test/bin

    cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp -r $SRC_MPC_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_MPC_PLANNER_LIB/* $DEST_LIB
    cp $SRC_MPC_PLANNER_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "pure_pursuit_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release pure_pursuit_planner..."
    SRC_PURE_PURSUIT_PLANNER_INCLUDE=$SRC_PURE_PURSUIT_PLANNER/include
    SRC_PURE_PURSUIT_PLANNER_LIB=$SRC_PURE_PURSUIT_PLANNER/lib
    SRC_PURE_PURSUIT_PLANNER_BIN=$SRC_PURE_PURSUIT_PLANNER/test/bin

    cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp -r $SRC_PURE_PURSUIT_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_PURE_PURSUIT_PLANNER_LIB/* $DEST_LIB
    cp $SRC_PURE_PURSUIT_PLANNER_BIN/* $DEST_BIN 
fi

# if [ "$BUILD_MODULE" = "teb_planner" ] || [ "$BUILD_MODULE" = "all" ]
# then
#     echo "Release teb_planner..."
#     SRC_TEB_PLANNER_INCLUDE=$SRC_TEB_PLANNER/include
#     SRC_TEB_PLANNER_LIB=$SRC_TEB_PLANNER/lib
#     SRC_TEB_PLANNER_BIN=$SRC_TEB_PLANNER/test/bin

#     cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
#     cp -r $SRC_TEB_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
#     cp $SRC_TEB_PLANNER_LIB/* $DEST_LIB
#     cp $SRC_TEB_PLANNER_BIN/* $DEST_BIN 
# fi

if [ "$BUILD_MODULE" = "wall_follow_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release wall_follow_planner..."
    SRC_WALL_FOLLOW_PLANNER_INCLUDE=$SRC_WALL_FOLLOW_PLANNER/include
    SRC_WALL_FOLLOW_PLANNER_LIB=$SRC_WALL_FOLLOW_PLANNER/lib
    SRC_WALL_FOLLOW_PLANNER_BIN=$SRC_WALL_FOLLOW_PLANNER/test/bin

    cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp -r $SRC_WALL_FOLLOW_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_WALL_FOLLOW_PLANNER_LIB/* $DEST_LIB
    cp $SRC_WALL_FOLLOW_PLANNER_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "fdfs_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release fdfs_planner..."
    SRC_FDFS_PLANNER_INCLUDE=$SRC_FDFS_PLANNER/include
    SRC_FDFS_PLANNER_LIB=$SRC_FDFS_PLANNER/lib
    SRC_FDFS_PLANNER_BIN=$SRC_FDFS_PLANNER/test/bin

    cp -r $SRC_LOCAL_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp -r $SRC_FDFS_PLANNER_INCLUDE/* $DEST_CONTROLLER_INCLUDE
    cp $SRC_FDFS_PLANNER_LIB/* $DEST_LIB
    cp $SRC_FDFS_PLANNER_BIN/* $DEST_BIN 
fi

###################### data #####################

SRC_DATA_INCLUDE=$SRC_DATA/include
SRC_DATA_CENTER=$SRC_DATA/data_center
SRC_EVENT_CENTER=$SRC_DATA/event_center

if [ "$BUILD_MODULE" = "data_center" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release data center..."
    SRC_DATA_CENTER_INCLUDE=$SRC_DATA_CENTER/include
    SRC_DATA_CENTER_LIB=$SRC_DATA_CENTER/lib
    SRC_DATA_CENTER_BIN=$SRC_DATA_CENTER/test/bin

    # cp $SRC_DATA_INCLUDE/* $DEST_DATA_INCLUDE
    cp -r $SRC_DATA_CENTER_INCLUDE/* $DEST_DATA_INCLUDE
    cp $SRC_DATA_CENTER_LIB/* $DEST_LIB
    cp $SRC_DATA_CENTER_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "event_center" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release event center..."
    SRC_EVENT_CENTER_INCLUDE=$SRC_EVENT_CENTER/include
    SRC_EVENT_CENTER_LIB=$SRC_EVENT_CENTER/lib
    SRC_EVENT_CENTER_BIN=$SRC_EVENT_CENTER/test/bin

    # cp $SRC_DATA_INCLUDE/* $DEST_DATA_INCLUDE
    cp -r $SRC_EVENT_CENTER_INCLUDE/* $DEST_DATA_INCLUDE
    cp $SRC_EVENT_CENTER_LIB/* $DEST_LIB
    cp $SRC_EVENT_CENTER_BIN/* $DEST_BIN
fi

#################### detector ###################

SRC_DETECTOR_INCLUDE=$SRC_DETECTOR/include
SRC_EMERGENCY_STOP_DETECTOR=$SRC_DETECTOR/emergency_stop_detector
SRC_OBSTACLE_DETECTOR=$SRC_DETECTOR/obstacle_detector
SRC_COLLISION_DETECTOR=$SRC_DETECTOR/collision_detector

if [ "$BUILD_MODULE" = "emergency_stop_detector" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release emergency_stop_detector..."
    SRC_EMERGENCY_STOP_DETECTOR_INCLUDE=$SRC_EMERGENCY_STOP_DETECTOR/include
    SRC_EMERGENCY_STOP_DETECTOR_LIB=$SRC_EMERGENCY_STOP_DETECTOR/lib
    SRC_EMERGENCY_STOP_DETECTOR_BIN=$SRC_EMERGENCY_STOP_DETECTOR/test/bin

    cp -r $SRC_DETECTOR_INCLUDE/* $DEST_DETECTOR_INCLUDE
    cp -r $SRC_EMERGENCY_STOP_DETECTOR_INCLUDE/* $DEST_DETECTOR_INCLUDE
    cp $SRC_EMERGENCY_STOP_DETECTOR_LIB/* $DEST_LIB
    cp $SRC_EMERGENCY_STOP_DETECTOR_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "obstacle_detector" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release obstacle_detector..."
    SRC_OBSTACLE_DETECTOR_INCLUDE=$SRC_OBSTACLE_DETECTOR/include
    SRC_OBSTACLE_DETECTOR_LIB=$SRC_OBSTACLE_DETECTOR/lib
    SRC_OBSTACLE_DETECTOR_BIN=$SRC_OBSTACLE_DETECTOR/test/bin

    cp -r $SRC_DETECTOR_INCLUDE/* $DEST_DETECTOR_INCLUDE
    cp -r $SRC_OBSTACLE_DETECTOR_INCLUDE/* $DEST_DETECTOR_INCLUDE
    cp $SRC_OBSTACLE_DETECTOR_LIB/* $DEST_LIB
    cp $SRC_OBSTACLE_DETECTOR_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "collision_detector" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release collision_detector..."
    SRC_COLLISION_DETECTOR_INCLUDE=$SRC_COLLISION_DETECTOR/include
    SRC_COLLISION_DETECTOR_LIB=$SRC_COLLISION_DETECTOR/lib
    SRC_COLLISION_DETECTOR_BIN=$SRC_COLLISION_DETECTOR/test/bin

    cp -r $SRC_DETECTOR_INCLUDE/* $DEST_DETECTOR_INCLUDE
    cp -r $SRC_COLLISION_DETECTOR_INCLUDE/* $DEST_DETECTOR_INCLUDE
    cp $SRC_COLLISION_DETECTOR_LIB/* $DEST_LIB
    cp $SRC_COLLISION_DETECTOR_BIN/* $DEST_BIN 
fi

###################### map ######################

SRC_MAP_INCLUDE=$SRC_MAP/include
SRC_CLEAN_MAP=$SRC_MAP/clean_map
SRC_LOCAL_MAP=$SRC_MAP/local_map

if [ "$BUILD_MODULE" = "clean_map" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release clean_map..."
    SRC_CLEAN_MAP_INCLUDE=$SRC_CLEAN_MAP/include
    SRC_CLEAN_MAP_LIB=$SRC_CLEAN_MAP/lib
    SRC_CLEAN_MAP_BIN=$SRC_CLEAN_MAP/test/bin

    cp -r $SRC_MAP_INCLUDE/* $DEST_MAP_INCLUDE
    cp -r $SRC_CLEAN_MAP_INCLUDE/* $DEST_MAP_INCLUDE
    cp $SRC_CLEAN_MAP_LIB/* $DEST_LIB
    cp $SRC_CLEAN_MAP_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "local_map" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release local_map..."
    SRC_LOCAL_MAP_INCLUDE=$SRC_LOCAL_MAP/include
    SRC_LOCAL_MAP_LIB=$SRC_LOCAL_MAP/lib
    SRC_LOCAL_MAP_BIN=$SRC_LOCAL_MAP/test/bin

    cp -r $SRC_MAP_INCLUDE/* $DEST_MAP_INCLUDE
    cp -r $SRC_LOCAL_MAP_INCLUDE/* $DEST_MAP_INCLUDE
    cp $SRC_LOCAL_MAP_LIB/* $DEST_LIB
    cp $SRC_LOCAL_MAP_BIN/* $DEST_BIN
fi

#################### planner ####################

SRC_PLANNER_INCLUDE=$SRC_PLANNER/include
SRC_NAVIGATION_PLANNER=$SRC_PLANNER/navigation_planner
SRC_PATH_FOLLOW_PLANNER=$SRC_PLANNER/path_follow_planner
SRC_CCPP_COVERAGE_PLANNER=$SRC_PLANNER/ccpp_coverage_planner
SRC_GLOBAL_TEB_PLANNER=$SRC_PLANNER/teb_planner

if [ "$BUILD_MODULE" = "navigation_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release navigation_planner..."
    SRC_NAVIGATION_PLANNER_INCLUDE=$SRC_NAVIGATION_PLANNER/include
    SRC_NAVIGATION_PLANNER_LIB=$SRC_NAVIGATION_PLANNER/lib
    SRC_NAVIGATION_PLANNER_BIN=$SRC_NAVIGATION_PLANNER/test/bin

    cp -r $SRC_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp -r $SRC_NAVIGATION_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp $SRC_NAVIGATION_PLANNER_LIB/* $DEST_LIB
    cp $SRC_NAVIGATION_PLANNER_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "path_follow_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release path_follow_planner..."
    SRC_PATH_FOLLOW_PLANNER_INCLUDE=$SRC_PATH_FOLLOW_PLANNER/include
    SRC_PATH_FOLLOW_PLANNER_LIB=$SRC_PATH_FOLLOW_PLANNER/lib
    SRC_PATH_FOLLOW_PLANNER_BIN=$SRC_PATH_FOLLOW_PLANNER/test/bin

    cp -r $SRC_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp -r $SRC_PATH_FOLLOW_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp $SRC_PATH_FOLLOW_PLANNER_LIB/* $DEST_LIB
    cp $SRC_PATH_FOLLOW_PLANNER_BIN/* $DEST_BIN 
fi   

if [ "$BUILD_MODULE" = "ccpp_coverage_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release ccpp_coverage_planner..."

    SRC_CCPP_COVERAGE_PLANNER_INCLUDE=$SRC_CCPP_COVERAGE_PLANNER/include
    SRC_CCPP_COVERAGE_PLANNER_LIB=$SRC_CCPP_COVERAGE_PLANNER/lib
    SRC_CCPP_COVERAGE_PLANNER_BIN=$SRC_CCPP_COVERAGE_PLANNER/test/bin

    cp -r $SRC_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp -r $SRC_CCPP_COVERAGE_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp $SRC_CCPP_COVERAGE_PLANNER_LIB/* $DEST_LIB
    cp $SRC_CCPP_COVERAGE_PLANNER_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "global_teb_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release global_teb_planner..."

    SRC_GLOBAL_TEB_PLANNER_INCLUDE=$SRC_GLOBAL_TEB_PLANNER/include
    SRC_GLOBAL_TEB_PLANNER_LIB=$SRC_GLOBAL_TEB_PLANNER/lib
    SRC_GLOBAL_TEB_PLANNER_BIN=$SRC_GLOBAL_TEB_PLANNER/test/bin

    cp -r $SRC_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp -r $SRC_GLOBAL_TEB_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp $SRC_GLOBAL_TEB_PLANNER_LIB/* $DEST_LIB
    cp $SRC_GLOBAL_TEB_PLANNER_BIN/* $DEST_BIN 
fi

if [ "$BUILD_MODULE" = "edge_follow_planner" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release edge_follow_planner..."
    SRC_EDGE_FOLLOW_PLANNER_INCLUDE=$SRC_EDGE_FOLLOW_PLANNER/include
    SRC_EDGE_FOLLOW_PLANNER_LIB=$SRC_EDGE_FOLLOW_PLANNER/lib
    SRC_EDGE_FOLLOW_PLANNER_BIN=$SRC_EDGE_FOLLOW_PLANNER/test/bin

    cp -r $SRC_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp -r $SRC_EDGE_FOLLOW_PLANNER_INCLUDE/* $DEST_PLANNER_INCLUDE
    cp $SRC_EDGE_FOLLOW_PLANNER_LIB/* $DEST_LIB
    cp $SRC_EDGE_FOLLOW_PLANNER_BIN/* $DEST_BIN 
fi   
##################### utils #####################

SRC_UTILS_INCLUDE=$SRC_UTILS/include
SRC_CONFIG=$SRC_UTILS/config
SRC_GEOMETRY=$SRC_UTILS/geometry
SRC_HSM=$SRC_UTILS/hsm
SRC_LOG=$SRC_UTILS/log
SRC_TIMER=$SRC_UTILS/timer

if [ "$BUILD_MODULE" = "config" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release config..."
    SRC_CONFIG_INCLUDE=$SRC_CONFIG/include
    SRC_CONFIG_LIB=$SRC_CONFIG/lib
    SRC_CONFIG_BIN=$SRC_CONFIG/test/bin

    # cp $SRC_UTILS_INCLUDE/* $DEST_UTILS_INCLUDE
    cp -r $SRC_CONFIG_INCLUDE/* $DEST_UTILS_INCLUDE
    cp $SRC_CONFIG_LIB/* $DEST_LIB
    cp $SRC_CONFIG_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "geometry" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release geometry..."
    SRC_GEOMETRY_INCLUDE=$SRC_GEOMETRY/include
    SRC_GEOMETRY_LIB=$SRC_GEOMETRY/lib
    SRC_GEOMETRY_BIN=$SRC_GEOMETRY/test/bin

    # cp $SRC_UTILS_INCLUDE/* $DEST_UTILS_INCLUDE
    cp -r $SRC_GEOMETRY_INCLUDE/* $DEST_UTILS_INCLUDE
    cp $SRC_GEOMETRY_LIB/* $DEST_LIB
    cp $SRC_GEOMETRY_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "hsm" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release hsm..."
    SRC_HSM_INCLUDE=$SRC_HSM/include
    SRC_HSM_LIB=$SRC_HSM/lib
    SRC_HSM_BIN=$SRC_HSM/test/bin

    # cp $SRC_UTILS_INCLUDE/* $DEST_UTILS_INCLUDE
    cp -r $SRC_HSM_INCLUDE/* $DEST_UTILS_INCLUDE
    cp $SRC_HSM_LIB/* $DEST_LIB
    cp $SRC_HSM_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "log" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release log..."
    SRC_LOG_INCLUDE=$SRC_LOG/include
    SRC_LOG_LIB=$SRC_LOG/lib
    SRC_LOG_BIN=$SRC_LOG/test/bin

    # cp $SRC_UTILS_INCLUDE/* $DEST_UTILS_INCLUDE
    cp -r $SRC_LOG_INCLUDE/* $DEST_UTILS_INCLUDE
    cp $SRC_LOG_LIB/* $DEST_LIB
    cp $SRC_LOG_BIN/* $DEST_BIN
fi

if [ "$BUILD_MODULE" = "timer" ] || [ "$BUILD_MODULE" = "all" ]
then
    echo "Release timer..."
    SRC_TIMER_INCLUDE=$SRC_TIMER/include
    SRC_TIMER_LIB=$SRC_TIMER/lib
    SRC_TIMER_BIN=$SRC_TIMER/test/bin

    # cp $SRC_UTILS_INCLUDE/* $DEST_UTILS_INCLUDE
    cp -r $SRC_TIMER_INCLUDE/* $DEST_UTILS_INCLUDE
    cp $SRC_TIMER_LIB/* $DEST_LIB
    cp $SRC_TIMER_BIN/* $DEST_BIN
fi
