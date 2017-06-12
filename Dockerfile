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


# ######################################
# 				Preference			   #
# ######################################
# 用户名
ENV NON_ROOT omi
# NVM 版本号
ENV NVM_VERSION 0.33.2
# 初始安装的 node.js 版本号
ENV NODE_VERSION 8.1.0



# 备份源列表
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
ADD sources-16.04_LTS.list /tmp/sources.list
RUN cat /tmp/sources.list > /etc/apt/sources.list
RUN rm /tmp/sources.list
# 使用新源刷新
RUN apt-get update 

# 更新系统
#RUN apt-get upgrade -y
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
RUN apt-get install -y \
	apt-utils \
	build-essential \
	ca-certificates \
	curl \
	git \
	python \
    sudo \
	tmux \
	wget \
	zsh

# 创建非root用户
RUN groupadd --gid 1000 $NON_ROOT \
	&& useradd --uid 1000 --gid $NON_ROOT --shell /bin/bash --create-home $NON_ROOT \
# 使用和用户名一样的密码
    && echo "$NON_ROOT:$NON_ROOT" | chpasswd \
# 加入 sudo 权限
# 设置root密码：$ sudo passwd root
	&& adduser $NON_ROOT sudo

# 安装gosu，方便后面以非root用户执行指令
#ENV GOSU_VERSION 1.10
##ENV DPKG_ARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
#RUN echo $DPKG_ARCH
#RUN DPKG_ARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }') \
#	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$DPKG_ARCH" \
#	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$DPKG_ARCH.asc" \
## verify the signature
#	&& export GNUPGHOME="$(mktemp -d)" \
#	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
#	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
#	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
#	&& chmod +x /usr/local/bin/gosu \
## verify that the binary works
#	&& gosu nobody true


# 这里开始使用非root用户安装zsh和node.js
USER $NON_ROOT

# 进入非root用户根目录
WORKDIR /home/$NON_ROOT/

# 安装oh-my-zsh
RUN wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | zsh || true

# 设置tmux
RUN git clone https://github.com/iPersona/tmux.git .tmux
WORKDIR .tmux
RUN chmod 755 init.sh
RUN ./init.sh

# 安装nvm（如果使用zsh的话，需要添加到zsh中）
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash

# 设置NVM环境变量
ENV NVM_DIR /home/$NON_ROOT/.nvm
# 设置国内源地址加速下载
# ENV NVM_NODEJS_ORG_MIRROR https://npm.taobao.org/mirrors/node

# 使用nvm安装node.js
RUN source $NVM_DIR/nvm.sh \
	&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
	&& [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
	&& nvm --version \
	&& nvm install $NODE_VERSION \
# 更新版本号
	#&& NODE_VERSION=$(node -v) \
	#&& echo node version: $NODE_VERSION \
	#&& NODE_VERSION=$(awk 'BEGIN {print substr("'$NODE_VERSION'", 2)}') \
	&& nvm alias default $NODE_VERSION \
	&& nvm use default

# 添加node.js环境变量
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# 获取 node.js 版本号
#RUN node -v
#RUN npm -v

# 安装以太坊环境
RUN npm install -g ethereumjs-testrpc truffle




	    

