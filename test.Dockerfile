# Start from ROS Humble base image
FROM ros:humble-ros-base

# Set environment variables
ENV ROS_DISTRO=humble
ENV GZ_VERSION=fortress

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
RUN mkdir -p ~/workspace/src

# Import the collection of repositories including Gazebo
RUN cd ~/workspace/src && wget https://raw.githubusercontent.com/ignition-tooling/gazebodistro/master/collection-fortress.yaml
RUN cd ~/workspace/src && vcs import < collection-fortress.yaml

# Add OSRF packages keyring and repository
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt-get update

# Install Gazebo dependencies
RUN cd ~/workspace/src && apt -y install \
  $(sort -u $(find . -iname 'packages-'`lsb_release -cs`'.apt' -o -iname 'packages.apt' | grep -v '/\.git/') | sed '/ignition\|sdf/d' | tr '\n' ' ')

# Install Dart 6.13 (remove default version and install new one)
RUN apt remove libdart* -y
RUN add-apt-repository ppa:dartsim/ppa -y
RUN apt-get update -y
RUN apt-get install libdart6-all-dev -y


# Get ros_gz
RUN cd ~/workspace/src/ && git clone https://github.com/gazebosim/ros_gz.git
RUN cd ~/workspace/src/ros_gz/ && git checkout $ROS_DISTRO

# Build the ROS gz packages
RUN /bin/bash -c '. /opt/ros/${ROS_DISTRO}/setup.bash; cd ~/workspace; colcon build --cmake-args -DBUILD_TESTING=OFF --symlink-install --merge-install'


# Create entrypoint
RUN echo '#!/bin/bash \n\
    source /opt/ros/${ROS_DISTRO}/setup.bash \n\
    source /root/workspace/install/setup.bash \n\
    exec "$@"' > /ros_entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["ign", "gazebo", "--headless-rendering"]