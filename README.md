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
    chmod 755 install.sh
    sudo ./install.sh
    ```
This will ensure that JBoss Fuse is installed on all the OS instances.

### Sample setup
Lets setup a three node Fabric.

Host name | Description  |  IP Address
--|--|--
jboss-fuse-fabric-1  |  Fabric node 1  |  209.132.179.21
jboss-fuse-fabric-2  |  Fabric node 2  |  209.132.179.74
jboss-fuse-fabric-3  |  Fabric node 3  |  209.132.179.173

### Demo script

#### Create and setup the
