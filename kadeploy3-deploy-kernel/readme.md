Kadeploy3 deploy kernels
===

This directory contains the recipes used to build Kadeploy3's deployment miniOS.

They can be built from the root of the environments recipes repository with kameleon, using the following command:

```shell
$ kameleon build kadeploy-deploy-kernel/<recipe>
```

Some recipes allow building the kadeploy miniOS for other architecture (e.g. aarch64, ppc64el), using a cross build mechanism involving qemu-user. All build should however run on a X86 server.

# Stable recipes

The following recipes are production ready, and can be built:
* buster miniOS:
  * kadeploy3-deploy-kernel-buster.yaml
  * kadeploy3-deploy-kernel-buster-arm64.yaml
  * kadeploy3-deploy-kernel-buster-ppc64.yaml
* bullseye miniOS:
  * kadeploy3-deploy-kernel-bullseye.yaml
  * kadeploy3-deploy-kernel-bullseye-arm64.yaml
  * kadeploy3-deploy-kernel-bullseyel4t-arm64.yaml
  * kadeploy3-deploy-kernel-bullseye-ppc64.yaml
* bookworm miniOS:
  * kadeploy3-deploy-kernel-bookworm.yaml
  * kadeploy3-deploy-kernel-bookworm-arm64.yaml
  * kadeploy3-deploy-kernel-bookworm-gh.yaml

# Experimental recipes

The following recipes are related to work in progress.
Theses recipes may not build, or may not be stable once deployed on Grid'5000.

* kadeploy3-deploy-kernel-bookworm+ubuntukernel-arm64.yaml
* kadeploy3-deploy-kernel-sid.yaml
* kadeploy3-deploy-kernel-sid-arm64.yaml
* kadeploy3-deploy-kernel-trixie.yaml

# Base recipe using qemu or docker

The recipes of this directory can build using qemu-system (build using a qemu VM as the out context) or docker (build using a docker container as the out context) as a backend. Builds currently in production were done using qemu. 

Docker may not be quicker (further test needed), but more agile. 

Switching between qemu or docker relies on changing the kadeploy3-deploy-kernel-base.yaml symlink. As of writing this note, it currenlty points to the qemu variant.

NB: With both backends, qemu-user is used when it comes to cross build from one arch (X86) for another (e.g. aarch64, ppc64el).