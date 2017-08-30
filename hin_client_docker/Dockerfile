# Debian wheezy für redmine von niklaus Giger
# Thanks to http://www.debian-administration.org/article/698/Automating_the_creation_of_docker_images

FROM debian:stretch
MAINTAINER Niklaus Giger "niklaus.giger@member.fsf.org"

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ADD oracle-java8-jdk_8u121_amd64.deb /root/
RUN apt-get update && apt-get install -y --no-install-recommends java-common
RUN dpkg -i  /root/oracle-java8-jdk_8u121_amd64.deb; pwd
RUN apt --fix-broken install -y --no-install-recommends
RUN useradd --uid 2000 --create-home --shell /bin/bash user_hin
RUN chown -R user_hin /home/user_hin && ls -lR /home/user_hin
WORKDIR /home/user_hin
USER user_hin
ADD HINClient_unix_1_5_3-50.tar.gz /home/user_hin
# RUN chown -R user_hin:user_hin .
RUN ls -lrtq  /home/user_hin/
CMD /home/user_hin/start_hin.sh
ADD start_hin.sh /home/user_hin/
