FROM ros:melodic-ros-core

MAINTAINER Yosuke Matsusaka <yosuke.matsusaka@gmail.com>

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y curl supervisor && \
    apt-get clean

# OSRF distribution is better for gazebo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN source /opt/ros/melodic/setup.bash && \
    mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/src && \
    catkin_init_workspace && \
    git clone --depth 1 https://github.com/uuvsimulator/uuv_simulator.git && \
    git clone --depth 1 https://github.com/uuvsimulator/uuv_simulation_evaluation.git && \
    git clone --depth 1 https://github.com/uuvsimulator/rexrov2.git && \
    cd .. && \
    rosdep update && apt-get update && \
    apt-get install -y python3-pip python-pip swig ros-melodic-rviz && \
    pip3 install --no-cache-dir --ignore-installed -U cython catkin_tools && pip3 install --no-cache-dir smac pymap3d && \
    pip install --no-cache-dir pymap3d && \
    rosdep install --from-paths src --ignore-src -r -y && \
    catkin config --install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/melodic && \
    catkin build && \
    apt-get clean && rm -r ~/catkin_ws

RUN git clone --depth 1 https://github.com/osrf/uctf.git /tmp/uctf && \
    cp -r /tmp/uctf/models/iris_with_standoffs_demo /usr/share/gazebo-9/models/ && \
    rm -r /tmp/uctf

ADD supervisord.conf /etc/supervisor/supervisord.conf

VOLUME /opt/ros/melodic/share/rexrov2_description

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
