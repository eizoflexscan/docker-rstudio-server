# docker-rstudio-server

#### Table of Contents
1. [Overview](#overview)
1. [Files Description](#filesdescription)

## Overview

This repository contains the necessary files for setting up a  [Rstudio Server](https://www.rstudio.com/products/rstudio/#Server) containerized application up and running on a [Bigboard](www.bigboards.io).

Rstudio is an integrated development environment (IDE) targeted specifically at data scientists. The server version  allows one to work with R on a remote server as if it were a local R Console.

This has proven useful,
* if you need to run your analysis on a high-end server rather than your laptop
* if you want all your team members to work on the same R installation

This image was originally developed by Koen Rutten for workshops using [Rstudio Server](https://www.rstudio.com/products/rstudio/#Server) as X instances on [Bigboard](www.bigboards.io).
But it can also be combined with Hadoop, Spark and Shiny to get a full R Stack (see [R on Spark on Yarn](http://hive.bigboards.io/#/library/stack/google-oauth2-113490423275171641798/cm-r-stack) for details).  


## Files Description

### Dockerfile

#### Step 1 : Load pre-existing image
Tells Docker which image your image is based on with the "FROM" keyword. In our case, we'll use the Bigboards base image bigboards/base-__arch__ as the foundation to build our app. 

```sh
FROM bigboards/base-__arch__
```


### Step 2 : Set environment variables
The ENV command is used to set the environment variables. These variables consist of “key = value” pairs which can be accessed within the container by scripts and applications alike. If you want don't need to control the R version for your application or if you always want to work with the lastest version, you should remove these lines. 

```sh
## General ENV
ENV R_BASE_VERSION 3.3.1
ENV RSTUDIO_SERVER_VERSION 0.99.1251
```

### Step 3 : Install dependencies
Install dependencies external to R and Rstudio,
```sh
RUN set -e \
  && apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
  	gdebi-core \ 
    libapparmor1 \
    wget \
    libcurl4-openssl-dev 
```

### Step 4: Download and Install R Base
A full description of R installation processes can be found at the following [link](https://cran.rstudio.com/bin/linux/ubuntu/README.html). 

```sh   
RUN set -e \
&& codename=$(lsb_release -c -s) \	
&& echo "deb http://freestatistics.org/cran/bin/linux/ubuntu $codename/" | tee -a /etc/apt/sources.list > /dev/null \
&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
&& apt-get -y update \
&& apt-get install -y r-base r-base-dev \
&& apt-get clean
```
*  Obtain the latest R packages (line 1-2). Add an entry with URL of your favorite CRAN mirror (See https://cran.r-project.org/mirrors.html for the list of CRAN mirrors) 
*  Use crypto to validate downloaded packages (line 3). The Ubuntu archives on CRAN are signed with the key of “Michael Rutter marutter@gmail.com” with key ID E084DAB9. 
*  Install the complete R system (line 4-6), including r-base-dev package to allow users to instal additional packages with "install.packages()".


Note that if you do not want to install the lastest version of R, you should remove the first line and replace the second line with `&& echo 'deb https://cloud.r-project.org/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list`
and choose your Ubuntu operating system (Xenial 16.04, Trusty 14.04 or Precise 12.04). 



### Step 5: Download and install R Packages 

Install as many R packages as you want by completing the list. But if you want to install Shiny Server later on, you must add `shiny` to the list before installing Shiny Server.

```sh
RUN R -e 'install.packages(c('devtools','shiny',  'rmarkdown', 'SparkR'), repos="http://cran.freestatistics.org/")' \
	&& R -e 'library("devtools"); install_github("mbojan/alluvial")' \
    && R -e 'update.packages(ask=FALSE,repos="http://cran.freestatistics.org/")'
```

* Install R packages from a list available on CRAN (line 1),
* Install R packages from a list available on Github (line 2),
* Avoid to ask if packages required to be updated (line 3).


### Step 6: Download and install RStudio Server Open Source edition
A full description of Rstudio installation processes can be found at the following [link](https://cran.rstudio.com/bin/linux/ubuntu/README.html). Instead of using the default value for usernames and passwords, they will be defined later on in the configuration file `build_logins.sh`.

```
RUN wget -O /tmp/rstudio.deb http://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb && \
    gdebi -n /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb
```    


### Step 7: Configure default locale
It might be interesting to avoid confusion to configure default local, see [comments](https://github.com/rocker-org/rocker/issues/19).

```sh
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen en_US.utf8 && \
	/usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
```


### Add users for RStudio, the sleep is added because older versions of docker have an issue with chmod
ADD build_logins.sh /tmp/build_logins.sh
RUN chmod +x /tmp/build_logins.sh && \
	sleep 1 && \
 	./tmp/build_logins.sh 4 && \
 	rm /tmp/build_logins.sh

### Remove the package list to reduce image size. Note: do this as the last thing of the build process as installs can fail due to this!
# Additional cleanup
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### Add shell script with startup commands
ADD run.sh /init/run.sh

### Expose the RStudio Server port
EXPOSE 8787

###  Start RStudio Server 
CMD ["./init/run.sh"]







### build_logins.sh

### run.sh


**[Back to top](#table-of-contents)**

## Limitations

It currently uses the Rstudio Server open-source edition so there is no load-balancing. If you need load-balancing, you can either upgrade to the Commercial License edition or use [Architect Server](https://www.openanalytics.eu/products) from [OpenAnalytics](https://www.openanalytics.eu/). 


