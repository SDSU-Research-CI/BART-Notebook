ARG BASE_IMAGE=quay.io/jupyter/scipy-notebook:2024-07-29

FROM ${BASE_IMAGE}

# Switch to root for linux updates and installs
USER root
WORKDIR /root

# Install rclone and code-server
RUN curl -O https://rclone.org/install.sh \
 && bash /root/install.sh \
 && rm -f /root/install.sh \
 && curl -fsSL https://code-server.dev/install.sh | sh

# Install Jupyter Desktop dependencies, zip and vim, Globus dependencies
RUN apt-get -y update \
 && apt-get -y install \
    dbus-x11 \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    zip \
    vim \
    tk \
    tcllib \
    bart-cuda \
    bart-view \
    gcc \
    libfftw3-dev \
    liblapacke-dev \
    libopenblas-dev \
    libpng-dev \
    make \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

WORKDIR /opt

# Install GlobusConnectPersonal
RUN wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz \
 && tar xzf globusconnectpersonal-latest.tgz \
 && rm globusconnectpersonal-latest.tgz

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

# Install Jupyter Desktop
RUN mamba install -y -q -c manics websockify
RUN mamba install -y -q -c conda-forge nb_conda_kernels
RUN pip install jupyter-remote-desktop-proxy jupyter-codeserver-proxy

COPY env.yaml env.yaml

RUN mamba env create -f env.yaml \
 && rm -rf env.yaml

ENV PATH=/opt/globusconnectpersonal-3.2.6:$PATH
