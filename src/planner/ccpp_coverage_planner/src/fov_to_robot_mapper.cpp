/*!
 *****************************************************************
 * \file
 *
 * \note
 * Copyright (c) 2016 \n
 * Fraunhofer Institute for Manufacturing Engineering
 * and Automation (IPA) \n\n
 *
 *****************************************************************
 *
 * \note
 * Project name: Care-O-bot
 * \note
 * ROS stack name: autopnp
 * \note
 * ROS package name: ipa_room_exploration
 *
 * \author
 * Author: Florian Jordan, Richard Bormann
 * \author
 * Supervised by: Richard Bormann
 *
 * \date Date of creation: 11.2016
 *
 * \brief
 *
 *
 *****************************************************************
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer. \n
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution. \n
 * - Neither the name of the Fraunhofer Institute for Manufacturing
 * Engineering and Automation (IPA) nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission. \n
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License LGPL as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License LGPL for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License LGPL along with this program.
 * If not, see <http://www.gnu.org/licenses/>.
 *
 ****************************************************************/

#include <fov_to_robot_mapper.h>
#include "map_accessibility_analysis.h"

// Function that provides the functionality that a given fov path gets mapped to a robot path by using the given parameters.
// To do so simply a vector operation is applied. If the computed robot pose is not in the free space, another accessible
// point is generated by finding it on the radius around the fov middlepoint s.t. the distance to the last robot position
// is minimized.
// Important: the room map needs to be an unsigned char single channel image, if inaccessible areas should be excluded, provide the inflated map
// robot_to_fov_vector in [m]
void mapPath(const cv::Mat& room_map, std::vector<ipa_building_msgs::Point_x_y_theta>& robot_path,
		const std::vector<ipa_building_msgs::Point_x_y_theta>& fov_path, const Eigen::Matrix<float, 2, 1>& robot_to_fov_vector,
		const double map_resolution, const cv::Point2d map_origin, const cv::Point& starting_point)
{
	// initialize helper classes
	MapAccessibilityAnalysis map_accessibility;
	AStarPlanner path_planner;
	const double map_resolution_inv = 1.0/map_resolution;

	// initialize the robot position in accessible space to enable the Astar planner to find a path from the beginning
	cv::Point robot_pos(starting_point.x, starting_point.y);
//	std::vector<MapAccessibilityAnalysis::Pose> accessible_start_poses_on_perimeter;
//	map_accessibility.checkPerimeter(accessible_start_poses_on_perimeter, fov_center, fov_radius_pixel, PI/64., room_map, false, robot_pos);

	// map the given robot to fov vector into pixel coordinates
	Eigen::Matrix<float, 2, 1> robot_to_fov_vector_pixel;
	robot_to_fov_vector_pixel << robot_to_fov_vector(0,0)*map_resolution_inv, robot_to_fov_vector(1,0)*map_resolution_inv;
	const double fov_radius_pixel = robot_to_fov_vector_pixel.norm();
	const double fov_to_front_offset_angle = atan2((double)robot_to_fov_vector(1,0), (double)robot_to_fov_vector(0,0));
	// std::cout << "mapPath: fov_to_front_offset_angle: " << fov_to_front_offset_angle << "rad (" << fov_to_front_offset_angle*180./PI << "deg)" << std::endl;
	// std::cout << "fov_radius_pixel: " << fov_radius_pixel << "      robot_to_fov_vector: " << robot_to_fov_vector(0,0) << ", " << robot_to_fov_vector(1,0) << std::endl;

	// go trough the given poses and calculate accessible robot poses
	// first try with A*, if this fails, call map_accessibility_analysis and finally try a directly computed pose shift
	int found_with_astar = 0, found_with_map_acc = 0, found_with_shift = 0, not_found = 0;
	for(std::vector<ipa_building_msgs::Point_x_y_theta>::const_iterator pose=fov_path.begin(); pose!=fov_path.end(); ++pose)
	{
		bool found_pose = false;

		// 1. try with map_accessibility_analysis
		// compute accessible locations on perimeter around target fov center
		MapAccessibilityAnalysis::Pose fov_center(pose->x, pose->y, pose->theta);
		std::vector<MapAccessibilityAnalysis::Pose> accessible_poses_on_perimeter;
		map_accessibility.checkPerimeter(accessible_poses_on_perimeter, fov_center, fov_radius_pixel, PI/64., room_map, false, robot_pos);

		//std::cout << "  fov_center: " << fov_center.x << ", " << fov_center.y << ", " << fov_center.orientation << "           accessible_poses_on_perimeter.size: " << accessible_poses_on_perimeter.size() << std::endl;

		if(accessible_poses_on_perimeter.size()!=0)
		{
			// todo: also consider complete visibility of the fov_center (or whole cell) as a selection criterion
			// todo: extend with a complete consideration of the exact robot footprint
			// go trough the found accessible positions and take the one that minimizes the angle between approach vector and robot heading direction at the target position
			// and which lies in the half circle around fov_center which is "behind" the fov_center pose's orientation
//			double max_cos_alpha = -10;
			std::map<double, MapAccessibilityAnalysis::Pose, std::greater<double> > cos_alpha_to_perimeter_pose_mapping;		// maps (positive) cos_alpha to their perimeter poses
			MapAccessibilityAnalysis::Pose best_pose;
			//std::cout << "Perimeter: \n robot_pos = " << robot_pos.x << ", " << robot_pos.y << "     fov_center = " << fov_center.x << ", " << fov_center.y << "\n";
			for(std::vector<MapAccessibilityAnalysis::Pose>::iterator perimeter_pose = accessible_poses_on_perimeter.begin(); perimeter_pose != accessible_poses_on_perimeter.end(); ++perimeter_pose)
			{
				// exclude positions that are ahead of the moving direction
				//cv::Point2d heading = cv::Point2d(fov_center.x, fov_center.y) - cv::Point2d(perimeter_pose->x, perimeter_pose->y);
				//const double heading_norm = sqrt((double)heading.x*heading.x+heading.y*heading.y);
				perimeter_pose->orientation -= fov_to_front_offset_angle; // robot heading correction of off-center fov
				const cv::Point2d perimeter_heading = cv::Point2d(cos(perimeter_pose->orientation), sin(perimeter_pose->orientation));
				const double perimeter_heading_norm = 1.;
				const cv::Point2d fov_center_heading = cv::Point2d(cos(fov_center.orientation), sin(fov_center.orientation));
				const double fov_center_heading_norm = 1.;
				const double cos_alpha = (fov_center_heading.x*perimeter_heading.x+fov_center_heading.y*perimeter_heading.y)/(fov_center_heading_norm*perimeter_heading_norm);
				//std::cout << "  cos_alpha: " << cos_alpha << std::endl;
//				if (cos_alpha < 0)
//					continue;
				if (cos_alpha >= 0.)
					cos_alpha_to_perimeter_pose_mapping[cos_alpha] = *perimeter_pose;		// rank by cos(angle) between approach direction and viewing direction

				// rank by cos(angle) between approach direction and viewing direction
				//cv::Point2d approach = cv::Point2d(perimeter_pose->x, perimeter_pose->y) - cv::Point2d(robot_pos.x, robot_pos.y);
				//const double approach_norm = sqrt(approach.x*approach.x+approach.y*approach.y);
//				double cos_alpha = 1.;		// only remains 1.0 if robot_pose and perimeter_pose are identical
//				if (fov_center_heading.x!=0 || fov_center_heading.y!=0)	// compute the cos(angle) between approach direction and viewing direction
//					cos_alpha = (fov_center_heading.x*perimeter_heading.x + fov_center_heading.y*perimeter_heading.y)/(fov_center_heading_norm*perimeter_heading_norm);
				//std::cout << " - perimeter_pose = " << perimeter_pose->x << ", " << perimeter_pose->y << "     cos_alpha = " << cos_alpha << "   max_cos_alpha = " << max_cos_alpha << std::endl;
//				if(cos_alpha>max_cos_alpha)
//				{
//					max_cos_alpha = cos_alpha;
//					best_pose = *perimeter_pose;
//					found_pose = true;
//				}
			}
//			std::cout << "  cos_alpha_to_perimeter_pose_mapping.size: " << cos_alpha_to_perimeter_pose_mapping.size() << std::endl;
			if (cos_alpha_to_perimeter_pose_mapping.size() > 0)
			{
				// rank by cos(angle) between approach direction and viewing direction
				double max_cos_alpha = cos_alpha_to_perimeter_pose_mapping.begin()->first;
				double closest_dist = std::numeric_limits<double>::max();
				for (std::map<double, MapAccessibilityAnalysis::Pose, std::greater<double> >::iterator it=cos_alpha_to_perimeter_pose_mapping.begin(); it!=cos_alpha_to_perimeter_pose_mapping.end(); ++it)
				{
//					std::cout << "    cos_alpha: " << it->first << std::endl;
					// only consider the best fitting angles
					if (it->first < 0.95*max_cos_alpha)
						break;
					// from those select the position with shortest approach path from current position
					const double dist = cv::norm(robot_pos-cv::Point(it->second.x, it->second.y));
					if (dist < closest_dist)
					{
						closest_dist = dist;
						best_pose = it->second;
						found_pose = true;
					}
				}
//				std::cout << "    closest_dist: " << closest_dist << "    best_pose: " << best_pose.x << ", " << best_pose.y << ", " << best_pose.orientation << std::endl;
			}

			// add pose to path and set robot position to it
			if (found_pose == true)
			{
				ipa_building_msgs::Point_x_y_theta best_pose_msg;
				best_pose_msg.x = best_pose.x*map_resolution + map_origin.x;
				best_pose_msg.y = best_pose.y*map_resolution + map_origin.y;
				best_pose_msg.theta = best_pose.orientation;
				robot_path.push_back(best_pose_msg);
				robot_pos = cv::Point(cvRound(best_pose.x), cvRound(best_pose.y));
				//std::cout << " best_pose = " << best_pose.x << ", " << best_pose.y << "      max_cos_alpha = " << max_cos_alpha << std::endl;
				++found_with_map_acc;
			}
		}

		// 2. if no accessible pose was found, try with a directly computed pose shift
		if (found_pose==false)
		{
			// get the rotation matrix
			const float sin_theta = std::sin(pose->theta);
			const float cos_theta = std::cos(pose->theta);
			Eigen::Matrix<float, 2, 2> R;
			R << cos_theta, -sin_theta, sin_theta, cos_theta;

			// calculate the resulting rotated relative vector and the corresponding robot position
			Eigen::Matrix<float, 2, 1> v_rel_rot = R * robot_to_fov_vector_pixel;
			Eigen::Matrix<float, 2, 1> robot_position;
			robot_position << pose->x-v_rel_rot(0,0), pose->y-v_rel_rot(1,0);

			// check the accessibility of the found point
			ipa_building_msgs::Point_x_y_theta current_pose;
			if(robot_position(0,0) >= 0 && robot_position(1,0) >= 0 && robot_position(0,0) < room_map.cols &&
					robot_position(1,0) < room_map.rows && room_map.at<uchar>((int)robot_position(1,0), (int)robot_position(0,0)) == 255) // position accessible
			{
				current_pose.x = (robot_position(0,0) * map_resolution) + map_origin.x;
				current_pose.y = (robot_position(1,0) * map_resolution) + map_origin.y;
				current_pose.theta = pose->theta;
				found_pose = true;
				robot_path.push_back(current_pose);

				// set robot position to computed pose s.t. further planning is possible
				robot_pos = cv::Point((int)robot_position(0,0), (int)robot_position(1,0));

				++found_with_shift;
			}
		}

		if (found_pose==false)
		{
			// 3. if still no accessible position was found, try with computing the A* path from robot position to fov_center and stop at the right distance
			// get vector from current position to desired fov position
			cv::Point fov_position(pose->x, pose->y);
			std::vector<cv::Point> astar_path;
			path_planner.planPath(room_map, robot_pos, fov_position, 1.0, 0.0, map_resolution, 0, &astar_path);

			// find the point on the astar path that is on the viewing circle around the fov middlepoint
			cv::Point accessible_position;
			for(std::vector<cv::Point>::iterator point=astar_path.begin(); point!=astar_path.end(); ++point)
			{
				if(cv::norm(*point-fov_position) <= fov_radius_pixel)
				{
					accessible_position = *point;
					found_pose = true;
					break;
				}
			}

			// add pose to path and set robot position to it
			if(found_pose == true)
			{
				// get the angle s.t. the pose points to the fov middlepoint and save it
				ipa_building_msgs::Point_x_y_theta current_pose;
				current_pose.x = (accessible_position.x * map_resolution) + map_origin.x;
				current_pose.y = (accessible_position.y * map_resolution) + map_origin.y;
				current_pose.theta = std::atan2(pose->y-accessible_position.y, pose->x-accessible_position.x) - fov_to_front_offset_angle; // todo: check -fov_to_front_offset_angle
				robot_path.push_back(current_pose);
				// set robot position to computed pose s.t. further planning is possible
				robot_pos = accessible_position;
				++found_with_astar;
			}
		}

		if (found_pose==false)
		{
			++not_found;
			// std::cout << "  not found." << std::endl;
		}

//		testing
//		std::cout << robot_pos << ", " << cv::Point(pose->x, pose->y) << std::endl;
//		cv::Mat room_copy = room_map.clone();
//		cv::line(room_copy, robot_pos, cv::Point(pose->x, pose->y), cv::Scalar(127), 1);
//		cv::circle(room_copy, robot_pos, 2, cv::Scalar(100), CV_FILLED);
//		cv::imshow("pose", room_copy);
//		cv::waitKey();

//		if (robot_path.size()>0)
//			std::cout << "  robot_pos: " << robot_path.back().x << ", " << robot_path.back().y << ", " << robot_path.back().theta << std::endl;
	}
	// std::cout << "Found with map_accessibility: " << found_with_map_acc << ",   with shift: " << found_with_shift
	// 		<< ",   with A*: " << found_with_astar << ",   not found: " << not_found << std::endl;
}


// computes the field of view center and the radius of the maximum incircle of a given field of view quadrilateral
// the metric coordinates are relative to the robot base coordinate system (i.e. the robot center)
// coordinate system definition: x points in forward direction of robot and camera, y points to the left side  of the robot and z points upwards. x and y span the ground plane.
// fitting_circle_center_point_in_meter this is also considered the center of the field of view, because around this point the maximum radius incircle can be found that is still inside the fov
// fov_resolution resolution of the fov center and incircle computations, in [pixels/m]
void computeFOVCenterAndRadius(const std::vector<Eigen::Matrix<float, 2, 1> >& fov_corners_meter,
		float& fitting_circle_radius_in_meter, Eigen::Matrix<float, 2, 1>& fitting_circle_center_point_in_meter, const double fov_resolution)
{
	// The general solution for the largest incircle is to find the critical points of a Voronoi graph and select the one
	// with largest distance to the sides as circle center and its closest distance to the quadrilateral sides as radius
	// see: http://math.stackexchange.com/questions/1948356/largest-incircle-inside-a-quadrilateral-radius-calculation
	// -------------> easy solution: distance transform on fov, take max. value that is closest to center

	// read out field of view and convert to pixel coordinates, determine min, max and center coordinates
	std::vector<cv::Point> fov_corners_pixel;
	cv::Point center_point_pixel(0,0);
	cv::Point min_point(100000, 100000);
	cv::Point max_point(-100000, -100000);
	for(int i = 0; i < 4; ++i)
	{
		fov_corners_pixel.push_back(cv::Point(fov_corners_meter[i](0,0)*fov_resolution, fov_corners_meter[i](1,0)*fov_resolution));
		center_point_pixel += fov_corners_pixel.back();
		min_point.x = std::min(min_point.x, fov_corners_pixel.back().x);
		min_point.y = std::min(min_point.y, fov_corners_pixel.back().y);
		max_point.x = std::max(max_point.x, fov_corners_pixel.back().x);
		max_point.y = std::max(max_point.y, fov_corners_pixel.back().y);
	}
	center_point_pixel.x = center_point_pixel.x/4 - min_point.x + 1;
	center_point_pixel.y = center_point_pixel.y/4 - min_point.y + 1;

	// draw an image of the field of view and compute a distance transform
	cv::Mat fov_image = cv::Mat::zeros(4+max_point.y-min_point.y, 4+max_point.x-min_point.x, CV_8UC1);
	std::vector<std::vector<cv::Point> > polygon_array(1,fov_corners_pixel);
	for (size_t i=0; i<polygon_array[0].size(); ++i)
	{
		polygon_array[0][i].x -= min_point.x-1;
		polygon_array[0][i].y -= min_point.y-1;
	}
	cv::fillPoly(fov_image, polygon_array, cv::Scalar(255));
	cv::Mat fov_distance_transform;
	cv::distanceTransform(fov_image, fov_distance_transform, CV_DIST_L2, CV_DIST_MASK_PRECISE);

	// determine the point(s) with maximum distance to the rim of the field of view, if multiple points apply, take the one closest to the center
	float max_dist_val = 0.;
	cv::Point max_dist_point(0,0);
	double center_dist = 1e10;
	for (int v=0; v<fov_distance_transform.rows; ++v)
	{
		for (int u=0; u<fov_distance_transform.cols; ++u)
		{
			if (fov_distance_transform.at<float>(v,u)>max_dist_val)
			{
				max_dist_val = fov_distance_transform.at<float>(v,u);
				max_dist_point = cv::Point(u,v);
				center_dist = (center_point_pixel.x-u)*(center_point_pixel.x-u) + (center_point_pixel.y-v)*(center_point_pixel.y-v);
			}
			else if (fov_distance_transform.at<float>(v,u) == max_dist_val)
			{
				double cdist = (center_point_pixel.x-u)*(center_point_pixel.x-u) + (center_point_pixel.y-v)*(center_point_pixel.y-v);
				if (cdist < center_dist)
				{
					max_dist_val = fov_distance_transform.at<float>(v,u);
					max_dist_point = cv::Point(u,v);
					center_dist = cdist;
				}
			}
		}
	}

	// compute fitting_circle_radius and center point (round last digit)
	fitting_circle_radius_in_meter = 10*(int)(((max_dist_val-1.f)+5)*0.1) / fov_resolution;
	// std::cout << "fitting_circle_radius: " << fitting_circle_radius_in_meter << " m" << std::endl;
	cv::Point2d center_point = cv::Point2d(10*(int)(((max_dist_point.x+min_point.x-1)+5.)*0.1), 10*(int)(((max_dist_point.y+min_point.y-1)+5.)*0.1))*(1./fov_resolution);
	// std::cout << "center point: " << center_point << " m" << std::endl;
	fitting_circle_center_point_in_meter << center_point.x, center_point.y;

//	// display
//	cv::normalize(fov_distance_transform, fov_distance_transform, 0, 1, cv::NORM_MINMAX);
//	cv::circle(fov_distance_transform, max_dist_point, 2, cv::Scalar(0.2), -1);
//	cv::imshow("fov_image", fov_image);
//	cv::imshow("fov_distance_transform", fov_distance_transform);
//	cv::waitKey();
}
