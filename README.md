# What is Fuse Fabric?

*Fuse Fabric* (Fabric) provides a centralised provisioning and configuration management for scalable deployment of JBoss Fuse containers in a hybrid cloud model.  It enables variety of advanced features such as:

+ Remote installation and provisioning of containers
+ Phased roll out of new versions of applications
+ Load balancing
+ Failover of deployed endpoints

## Key concepts

+ **Fabric server**: collection os *containers* that share a *fabric registry*.  It is responsible for maintaining a *replica* of a fabric registry.
    + **Fabric registry**: replicated database that stores information related to provisioning and managing containers.
        + **Runtime registry**: holds infrastructure information like details of how many machines are actually running, their physical location, and what services are they implementing.
        + **Configuration registry**: holds logical information for the fabric like applications to be deployed and their dependencies
+ **Ensemble**: is a collection of Fabric servers that collectively maintain the state of the fabric registry.  To guard against network splits in a [quorum-based](http://en.wikipedia.org/wiki/Quorum_(distributed_computing)) system, number of Fabrics servers in an Ensemble is always an odd number.
+ **Profile**: is an abstract unit of deployment, holding data required for deploying applications into a Fabric container. Profile is a collection of following:
    + OSGI bundles
    + Required KARAF features/services
    + Configuration data for the container runtime

Multiple features can be associated with a given container, allowing the container to serve multiple purposes.

## How to Fabric

### Pre-requisites

- [ ] Ensure that you have at-least three RHEL 7.2 instance *or an equivalent OS*
- [ ] Login to each OS instance and execute the [install-jboss-fuse.sh](https://github.com/finiteloopme/fabric8-demo/blob/master/install-jboss-fuse.sh) command as <kbd>sudo</kbd>

    ```bash
    # Create a file named install-jboss-fuse.sh using the contents from the above link to install-jboss-fuse.sh
    chmod 755 install-jboss-fuse.sh
    sudo ./install-jboss-fuse.sh
    ```
This will ensure that JBoss Fuse is installed on all the OS instances.

### Sample setup
Lets setup a three node Fabric.

Host name           | Description   | IP Address
--------------------|---------------|----------------
jboss-fuse-fabric-1 | Fabric node 1 | 209.132.179.21
jboss-fuse-fabric-2 | Fabric node 2 | 209.132.179.74
jboss-fuse-fabric-3 | Fabric node 3 | 209.132.179.173

The JBoss Fuse installation is at location <kbd>/opt/jboss/jboss-fuse-full</kbd>

### Demo script

#### Create and setup the Fabric
Create the first Fabric node on *jboss-fuse-fabric-1*.

1. Change the directory to <kbd>/opt/jboss/jboss-fuse-full</kbd>
2. Start the JBoss Fuse server <kbd>bin/start</kbd>
3. Create the Fabric

    ```bash
    # Use a client to connect to the JBoss Fuse container
    bin/client

    # Create the root fabric
    fabric:create --clean -m 209.132.179.21 -r manualip --wait-for-provisioning

    fabric:create --wait-for-provisioning --verbose --clean --new-user fAdmin --new-user-role admin --new-user-password fAdmin --zookeeper-password zpasswd --resolver manualip --manual-ip 209.132.179.21
    ```

Join the remaining two nodes to the *root* fabric created above.

```bash
# Use a client to connect to the JBoss Fuse container
bin/client

# Join the Fabric from jboss-fuse-fabric-2
fabric:join --zookeeper-password zpasswd --resolver manualip --manual-ip 209.132.179.74 209.132.179.21:2181 root2

# Join the Fabric from jboss-fuse-fabric-3
fabric:join --zookeeper-password zpasswd --resolver manualip --manual-ip 209.132.179.173 209.132.179.21:2181 root3
```

While trying to join both the containers you will get a prompt with a message like below. Enter *yes* to proceed.

```bash
You are about to change the container name. This action will restart the container.
The local shell will automatically restart, but ssh connections will be terminated.
The container will automatically join: 209.132.179.21:2181 the cluster after it restarts.
Do you wish to proceed (yes/no): yes
```

Once all the containers have re-started (it takes time), we will have a 1 node ensemble and 3 nodes in our fabric.

```bash
JBossFuse:admin@root> container-list
[id]   [version]  [type]  [connected]  [profiles]              [provision status]
root*  1.0        karaf   yes          fabric                  success           
                                       fabric-ensemble-0000-1                    
                                       jboss-fuse-full                           
root2  1.0        karaf   yes          fabric                  success           
root3  1.0        karaf   yes          fabric                  success           
```

To finish, we will add all our nodes to the ensemble.

```bash
JBossFuse:admin@root> fabric:ensemble-add root2 root3
This will change of the zookeeper connection string.
Are you sure want to proceed(yes/no):yes
```

Once completed, the nodes will be part of the ensemble.

```bash
JBossFuse:admin@root> container-list
[id]   [version]  [type]  [connected]  [profiles]              [provision status]
root*  1.0        karaf   yes          fabric                  success           
                                       fabric-ensemble-0000-1                    
                                       jboss-fuse-full                           
                                       fabric-ensemble-0001-1                    
root2  1.0        karaf   yes          fabric                  success           
                                       fabric-ensemble-0001-2                    
root3  1.0        karaf   yes          fabric                  success           
                                       fabric-ensemble-0001-3                    
```

### Tear down the demo setup

In the *root* container or jboss-fuse-fabric-1, issue the following command to *re-create* the Fabric.

```bash
JBossFuse:admin@root> fabric:create --wait-for-provisioning --force --zookeeper-password zpasswd --clean
Waiting for container: root
Waiting for container root to provision.

# On jboss-fuse-fabric-2
JBossFuse:admin@root2> fabric:container-delete --force root2
The list of container names: [root2]

# On jboss-fuse-fabric-3
JBossFuse:admin@root3> fabric:container-delete --force root3
The list of container names: [root3]
```
