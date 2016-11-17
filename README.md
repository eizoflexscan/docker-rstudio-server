# docker-rstudio-server

#### Table of Contents
1. [Overview](#overview)
1. [Files Description](#filesdescription)

## Overview

This repository contains the necessary files for setting up a  [Rstudio Server](https://www.rstudio.com/products/rstudio/#Server) containerized application up and running on a [Bigboard](www.bigboards.io).

Rstudio is an integrated development environment (IDE) targeted specifically at data scientists. The server version  allows one to work with R on a remote server as if it were a local R Console.

This has proven useful
* if you need to run your analysis on a high-end server rather than your laptop
* if you want all your team members to work on the same R installation
* when connecting to R on a cloud instance


This image is based on [bigboards/docker-rstudio-server](https://github.com/bigboards/docker-rstudio-server "bigboards/docker-rstudio-server") originally developed by Koen Rutten for workshops using [Rstudio Server](https://www.rstudio.com/products/rstudio/#Server) as X instances on [Bigboard](www.bigboards.io). It currently uses the Rstudio Server open-source edition so there is no load-balancing. If you need load-balancing, you can either upgreate to the Commercial License edition or use [Architect Server](https://www.openanalytics.eu/products) from [OpenAnalytics](https://www.openanalytics.eu/). 

## Files Description

### Dockerfile

#### Step 1 : Load Pre-Existing Image
Tells Docker which image your image is based on with the "FROM" keyword. In our case, we'll use the bigboards base image java-8-x86_64 as the foundation to build our app. 

```sh
FROM bigboards/java-8-x86_64
```



### build_logins.sh

### run.sh


**[Back to top](#table-of-contents)**

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there are Known Issues, you might want to include them under their own heading here.

## License

The MIT License
