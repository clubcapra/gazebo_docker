# Start from ROS Humble base image
FROM ros:humble-ros-base

# Set environment variables
ENV ROS_DISTRO=humble
ENV GZ_VERSION=harmonic

# Install necessary packages for Gazebo Garden and its dependencies
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-vision-msgs \
    ros-${ROS_DISTRO}-actuator-msgs \
    software-properties-common \
    wget \
    lsb-release \
    gnupg \
    curl

# Add ROS2 apt repository
RUN sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN apt update -y

# Create workspace and source directories
RUN mkdir -p /gazebo/gazebo_ws/src

# Add OSRF packages keyring and repository
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt-get update

# Install Gazebo
RUN apt-get install -y gz-harmonic

# Get ros_gz
RUN cd /gazebo/gazebo_ws/src/ && git clone https://github.com/gazebosim/ros_gz.git -b $ROS_DISTRO

# Install dependencies
RUN cd /gazebo/gazebo_ws && rosdep install -r --from-paths src -i -y --rosdistro humble

# Build the ROS gz packages
RUN /bin/bash -c '. /opt/ros/${ROS_DISTRO}/setup.bash; cd /gazebo/gazebo_ws; colcon build --cmake-args -DBUILD_TESTING=OFF --symlink-install --merge-install'

# Create entrypoint
RUN echo '#!/bin/bash \n\
    source /opt/ros/${ROS_DISTRO}/setup.bash \n\
    source /gazebo/gazebo_ws/install/setup.bash \n\
    exec "$@"' > /ros_entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["ign", "gazebo", "--headless-rendering"]