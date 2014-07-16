[![Build Status](https://travis-ci.org/telamonian/puppet-eclipse.svg?branch=master)](https://travis-ci.org/telamonian/puppet-eclipse)

#Usage
#Add to your Puppetfile
```
github "java",	"1.5.0"
```

#Add to your manifests
```
include java
include eclipse
include eclipse::plugins
```

#Hiera config
The directory that your eclipse installation ends up in and the eclipse plugins that you install are controlled by a hiera file. There is a basic example .yaml file included in this module at /data/Darwin.yaml. The trickiest part of the .yaml file is that you have to use the fully qualified names of the plugins that you want to install.

#Fetching the fully qualified names of eclipse plugins
For a given eclipse p2 repository url, the fully qualified names of all available plugins can be fetched via the command line and a pre-existing eclipse executable using the following command:
```
./eclipse -application org.eclipse.equinox.p2.director -noSplash -repository <your-eclipse-p2-repository-url> -list
```