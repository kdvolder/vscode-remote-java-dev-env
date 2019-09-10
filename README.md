VSCode Remote Java Dev Env
==========================

Explore the use of vscode remote development support.

Goal: setup a k8s pod / container to which we can connect using vscode remote development and in that container do some java development.

Challenges:

At this time vscode-remote does not support using k8s containers/pods as development
targets directly. 

Strategy:

Here we will just use the generic 'ssh' based support for connecting to
remote targets. This is done as follows:

- create a docker image containing the desired development tools such as:
   - JDK installation
   - git

- include sshd in the image

- start a k8s container using the sshd + java runtime image.
- start sshd in the image
- create a service with loadbalancer to expose container port 22 for external
  connections. 
- define a secret that holds the local user's ssh public key. 
- configure sshd in the pod/container using this secret so that it is recongized
  as a 'authorized key'. This allows us to connect to the pod/container via ssh 
  from the local machine using a command like `ssh root@${public-ip-address}`.

Using This
==========

Setting up a gke cluster
------------------------

First... you will need a k8s cluster with enough 'resources' available to
comfortably run a vscode development environment. See folder `cluster-setup` 
for some bash scripts to create a cluster (and destroy it after you no longer need it).

Steps:

- make sure you have gcloud cli installed and logged.
- edit `vars.sh` to define the name of your cluster.
- run `./create-gke-cluster.sh` to create a cluster.
- run `./setup-kube-config.sh` to setup kubeconfig to fetch credentials and point to your cluster.

Docker image
------------

We need a docker image that will provide all the software we want in our 'development environment'.
The docker image is already built and published on docker-hub as `kdvolder/remote-java-dev-env`.
You can use this image as is, then there is nothing else you have to do here.

If you wish to make changes to the image. See the files under
`docker/java-dev-env`.

## Building

To build the image and publish it to docker-hub run the script `build-docker-image.sh`.

You will need to make some changes and rename `kdvolder/remote-java-dev-env` to something
else (replace kdvolder with your own dockerhub username). You will also need to find 
references to the changed name across this repo and change them as well.

## Testing the image

*Warning:* These steps work on Linux but I suspect they may not work on Mac where
extra complications exist because docker runs in a separate VM. If you can't figure
this out, you could just skip this step and move directly to deploying the image to 
k8s.

Run `./run-with-docker.sh` a in terminal. This will start an ssh daemon in a docker container.
Leave the terminal that you started this with open (if you close it the ssh daemon will be shutdown).

In a new terminal determine the ip address of the container. You can use `docker ps` to find the 
container. Then use `docker inspect` to see its details and find the ip address.

For example:

```
$ docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS              PORTS               NAMES
f54c6d27227e        kdvolder/remote-java-dev-env   "/entrypoint.sh"    5 minutes ago       Up 5 minutes        22/tcp              dazzling_germain
$ docker inspect dazzling_germain | grep IPAd
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.2",
                    "IPAddress": "172.17.0.2",
```

Connect to the ip address using local ssh client from the cli.

```
$ ssh root@172.17.0.2
The authenticity of host '172.17.0.2 (172.17.0.2)' can't be established.
ECDSA key fingerprint is SHA256:Ox6/VQFPAOvlft1++27v412MF11HZqxWFay+Eltz7QQ.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.17.0.2' (ECDSA) to the list of known hosts.
root@f54c6d27227e:~# 
```

If you see the `root@...` prompt you have successfully connected to
the container.

Note: if you are going through these steps a second time you
will likely see an error like this:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

This is expected because every time the sshd is run in a new
container, it generates new host keys. To get past this error, 
just follow  the instructions printed alongside the error 
message to remove  the host from list of known hosts. E.g:

```
$ ssh-keygen -f "/home/kdvolder/.ssh/known_hosts" -R "172.17.0.2"
```

Deploying on k8s
----------------

See the folder `k8s`. To deploy everything run the script `./deploy-all.sh`.
This will:

- create a secret containing the contents of your `~/.ssh/id_rsa.pub` public
  key file (so make sure you have one :-).
- create a pod running the java-dev-env docker image in a container
- expose the ssh daemon running in that container as a service of type `LoadBalancer`.
  This makes it accessible on a public ip address.

To connect to your remote 'development' environment with ssh you will need to
determine its public ip address. To this end run the command:

```
$ kubectl get service jde
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
jde    LoadBalancer   10.75.14.143   34.82.134.71   22:30532/TCP   81s
```

Note down the 'EXTERNAL-IP' address. It may not appear at first as it can take
some time for the gke cluster to set this up.

Now you can ssh into your remote dev machine from the cli:

```
$ ssh root@34.82.134.71
The authenticity of host '34.82.134.71 (34.82.134.71)' can't be established.
ECDSA key fingerprint is SHA256:GASNePJE4LlEWZFxIFTWcTkWB8073FWg95FsMdK46iE.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '34.82.134.71' (ECDSA) to the list of known hosts.
root@jde-6c6dbd5cc4-xgv6l:~# 
```

If you see the `root@...` prompt you have succesfully connected to the
remote development host.

Note: If you see an error like `@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @`. This is somewhat expected because everytime the container is started
it will generate new host keys. Simply follow the instructions from the
error message to remove the old host key, then try again.

Using Vscode Remote to Connect
------------------------------

If you can successfully use the ssh from cli to connect, then you should also
be able to use vscode-remote extension to connect as well.

Steps:

- install [vscode remote extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
- From vscode use CTRL-SHIFT-P to find and execute command `Remote SSH: connect to host`.
- when prompted for the host to connect to type `root@34.82.134.71` (use the public 
ip address of exposed service noted down earlier).

If successful a new vscode window will open which is connected to the remote host.
You can now start developing on that machine. E.g. use `git clone` to checkout some code. Then open it in vscode and start working. You can also install vscode-extensions
of your choosing on the remote machine in the same way as you would locally. Initially, no extensions will be installed remotely. 

What's next?
============

We should discuss that :-). Some ideas:

- Automatically install and configure kubectl on the remote host
- Automatically install a set of vscode extension on the remote host (e.g. k8s support, vscode-spring-boot pack, java extension pack etc.)
- Automatically copy local user's git configuration so that cloning (and pushing
  code) works without needing to setup authentication manually on the remote
  machine.
- exposing boot apps run in the remote development environment so they can be
  access from a browser on the user's machine.
- Other ways to take advantage of the fact that the remote host is 'inside the cluster' to achieve tighter integration of
  tooling with the cluster environment?
- ?