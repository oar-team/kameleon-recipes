Kameleon recipes for Grid'5000
------------------------------

This repository contains the Grid'5000 kameleon recipes to generate Grid'5000 environments. This repository is a fork of the default repository of kameleon recipes, which adds the Grid'5000 recipes. 

Grid'5000 environment recipes are stored in the root of this repository, in files following the scheme:
  ./<distro>-<arch>-<variant>.yaml
(e.g. debian10-x64-std, centos8-x64-min).

The `kameleon info <recipe>` command can be used get more information about the recipe, such as the steps used or inherited recipes.

Recipes found in subdirectories not supported by the Grid'5000 team.
 
Users can use the Grid'5000 recipes as templates to create their own recipes. For more information, see the Grid'5000 documentation:
  https://www.grid5000.fr/mediawiki/index.php/Environments_creation_using_kameleon
