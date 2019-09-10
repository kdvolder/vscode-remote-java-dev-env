FROM kdvolder/sshd
RUN ls -la /
RUN apt-get update && \
    apt-get install -y \
        openjdk-8-jdk-headless \
        git && \
    apt-get clean
RUN ls -la /

