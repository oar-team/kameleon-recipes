Kadeploy3 deploy kernels
===

This directory contains the recipes used to build Kadeploy3's Deployment MiniOS.

They can be built from the root of the repository with kameleon via the following command:

```shell
$ kameleon build kadeploy-deploy-kernel/<recipe>
```

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

