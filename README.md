# Docker Gazebo

This package contains a working dockerfile/instruction on how to install gazebo using dart 6.13 require for the tracks plugin.

# Problem

Due to the fact that Ubuntu 22.04 ships with DART 6.12, but Gazebo requires DART 6.13 for the tracks simulation, it is necessary to install DART from source to meet the version requirement. Compiling DART, Gazebo, and gz-ros from source can be time-consuming, so a Dockerfile has been created to streamline the process. This Dockerfile enables anyone to run the simulator without going through the lengthy compilation steps themselves. For those who need a user interface, there are two options: either follow the steps outlined in the Dockerfile to perform a local installation or utilize an X server to forward the simulator's display from the Docker container to the host machine.

More details on the issue can be found here: https://github.com/gazebosim/gz-sim/issues/1662


# Installation

## Docker

A cloud image will be available in the next version of the software, but currently, you need to build it. This process can take from 30 min to 1h. To save time, you can use the online image available on github.

### Run the image

*You migth need to change the ROS_DOMAIN_ID to make it work with your system.

```bash
docker compose up
```

### Build the image

If you want to modify the image and build it locally, you can use the following command :

```bash
docker compose build
```


