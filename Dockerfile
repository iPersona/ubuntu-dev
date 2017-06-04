# Ubuntu Dev
# Version 1.0

# 使用ubuntu基础镜像
FROM ubuntu

# 使用bash替换shell来使用source
# 参考：
# https://gist.github.com/remarkablemark/aacf14c29b3f01d6900d13137b21db3a
# https://stackoverflow.com/questions/25899912/install-nvm-in-docker
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER Omi <freedom2028@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

# 备份源列表
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
ADD sources-16.04_LTS.list /tmp/sources.list
RUN cat /tmp/sources.list /etc/apt/sources.list
RUN rm /tmp/sources.list
# 使用新源刷新
RUN apt-get update 

# 更新系统
#RUN apt-get upgrade -y
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q \

RUN apt-get install -y \
	apt-utils \
	curl \
	git \
	tmux \
	wget \
	zsh

# 安装oh-my-zsh
RUN wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | zsh || true

# 安装nvm（如果使用zsh的话，需要添加到zsh中）
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

# 设置NVM环境变量
USER root
ENV HOME /root
ENV NVM_DIR $HOME/.nvm
ENV NODE_VERSION 8.0.0

# 使用nvm安装node.js
RUN source $NVM_DIR/nvm.sh \
	&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
	&& [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
	&& nvm --version \
	&& nvm install $NODE_VERSION \
	&& nvm alias default $NODE_VERSION \
	&& nvm use default

# 添加node.js环境变量
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# 安装node.js
RUN node -v
RUN npm -v

# 设置tmux
WORKDIR ~/
RUN git clone https://github.com/iPersona/tmux.git .tmux
WORKDIR .tmux
RUN chmod 755 init.sh
RUN ./init.sh





	    

