FROM kdvolder/sshd
RUN apt-get update && \
    apt-get install -y \
        openjdk-8-jdk-headless \
        curl \
        git && \
    apt-get clean
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin