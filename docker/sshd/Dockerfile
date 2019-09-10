FROM ubuntu:18.04
# Install Some Stuff
RUN apt-get update && \
    apt-get install -y \
        openssh-server && \
    apt-get clean
RUN sed -i 's/.*UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    cat /etc/ssh/sshd_config
ADD entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 22