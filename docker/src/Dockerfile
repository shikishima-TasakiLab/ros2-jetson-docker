ARG L4T_VERSION="r32.3.1"
FROM nvcr.io/nvidia/l4t-base:${L4T_VERSION}

LABEL maintainer="Shikishima-TasakiLab"

ARG ROS_DISTRO="dashing"
ARG HOST_USER="1000"
ARG USER_NAME="ros2"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        build-essential \
        git \
        less \
        emacs \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        cmake-curses-gui \
        cmake-qt-gui \
        dbus-x11 \
        dmz-cursor-theme \
        fonts-dejavu \
        gconf2 \
        gnome-terminal \
        gosu \
        language-pack-en \
        xdg-user-dirs \
        xsel \
        dirmngr \
        gpg-agent \
        mesa-utils \
        libarmadillo-dev \
        libcanberra-gtk-module \
        libcanberra-gtk3-0 \
        libcanberra-gtk3-module \
        libglu1-mesa-dev \
        libgles2-mesa-dev \
        freeglut3-dev \
        libdbus-glib-1-2 \
        libgflags-dev \
        libglew-dev \
        libgoogle-glog-dev \
        libgoogle-perftools-dev \
        libgsl0-dev \
        libmosquitto-dev \
        libopencv-dev \
        libopenni2-dev \
        libpcap-dev \
        libssh2-1-dev \
        locales \
        pulseaudio \
        python-flask \
        python-requests \
        python3-pip \
        python3-setuptools \
        python3-opencv \
        tmux \
        v4l-utils \
        nano \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m $USER_NAME && \
    echo "$USER_NAME:$USER_NAME" | chpasswd && \
    usermod --shell /bin/bash $USER_NAME && \
    usermod -aG sudo $USER_NAME && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USER_NAME && \
    chmod 0440 /etc/sudoers.d/$USER_NAME && \
    usermod  --uid $HOST_USER $USER_NAME && \
    groupmod --gid $HOST_USER $USER_NAME && \
    gpasswd -a $USER_NAME video

ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y \
        curl \
        gnupg2 \
        lsb-release
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

RUN apt-get update && \
    apt-get install -y \
        ros-melodic-actionlib-msgs \
        ros-melodic-catkin \
        ros-melodic-common-msgs \
        ros-melodic-gazebo-msgs \
        ros-melodic-geometry-msgs \
        ros-melodic-nav-msgs \
        ros-melodic-rosbash \
        ros-melodic-roscpp \
        ros-melodic-roscpp-tutorials \
        ros-melodic-roslaunch \
        ros-melodic-rosmsg \
        ros-melodic-rospy-tutorials \
        ros-melodic-sensor-msgs \
        ros-melodic-std-msgs \
        ros-melodic-std-srvs \
        ros-melodic-stereo-msgs \
        ros-melodic-tf2-msgs \
        ros-melodic-trajectory-msgs \
        ros-melodic-visualization-msgs \
        ros-dashing-desktop \
        python3-argcomplete \
        ros-dashing-rmw-opensplice-cpp \
        ros-dashing-rmw-connext-cpp \
        ros-dashing-ros1-bridge \
        python3-colcon-common-extensions

USER ${USER_NAME}

RUN echo 'source /opt/ros/dashing/setup.bash' >> /home/${USER_NAME}/.bashrc && \
    echo "if [[ -f \"/home/${USER_NAME}/colcon_ws/install/setup.bash\" ]]; then" >> /home/${USER_NAME}/.bashrc && \
    echo "    source /home/${USER_NAME}/colcon_ws/install/setup.bash" >> /home/${USER_NAME}/.bashrc && \
    echo 'fi' >> /home/${USER_NAME}/.bashrc && \
    mkdir /home/${USER_NAME}/colcon_ws

USER root
WORKDIR /root
ENV LANG=C.UTF-8
COPY ./entrypoint.sh /tmp/entrypoint.sh
ENTRYPOINT [ "/tmp/entrypoint.sh" ]
