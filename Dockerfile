FROM centos:centos7

RUN yum install -y --enablerepo=centosplus epel-release gettext tar automake \
      make git docker

# TODO: STI should be installed from official release page, instead of bundling
#       it in the GIT repository.
ADD bin/sti.gz /usr/bin/sti.gz
RUN gunzip /usr/bin/sti.gz

ADD bin/build.sh /buildroot/build.sh

WORKDIR /buildroot
CMD ["/buildroot/build.sh"]
