FROM ubuntu:latest
RUN apt-get update && apt-get install -y supervisor openssh-server nginx
RUN mkdir /run/sshd/
RUN mkdir /root/.ssh/
COPY id_rsa.pub /root/.ssh/authorized_keys
COPY supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
