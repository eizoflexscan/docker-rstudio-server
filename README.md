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
Tells Docker which image your image is based on with the "FROM" keyword. In our case, we'll use the bigboards base image bigboards/base-__arch__ as the foundation to build our app. 

```sh
FROM bigboards/base-__arch__
```


### Step 2 : Set environment variables
The ENV command is used to set the environment variables. These variables consist of “key = value” pairs which can be accessed within the container by scripts and applications alike. If you want don't need to control the R version for your application or if you always want to work with the lastest version, you should remove these lines. 

```sh
## General ENV
ENV R_BASE_VERSION 3.3.1
ENV RSTUDIO_SERVER_VERSION 0.99.1251

## Password rstudio
ENV PASSWORD rstudio
```

### Step 3 : Install dependencies
Don't know what I'm doing. Many R packages have dependencies external to R that need to be installed.
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

###Step 4: Install R version

#### Step 4.1: Install R 
This is unrequired. It's simple to fix a bug

	```sh
	## From  rocker/r-base
	## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
	RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	  && locale-gen en_US.utf8 \
	  && /usr/sbin/update-locale LANG=en_US.UTF-8

	ENV LC_ALL en_US.UTF-8
	ENV LANG en_US.UTF-8
	```

	
#### Step 4.2: Install R 
To install the latest version of R you should first add the CRAN repository to your system as described here:
	```sh
	## From https://cran.rstudio.com/bin/linux/ubuntu/README.html
	RUN set -e \
		  && echo 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial/' >> /etc/apt/sources.list \
		  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
		  && apt-get -y update \
		  && apt-get -y install r-base r-cran-* \
		  && apt-get install r-base-dev \
		  && apt-get clean
	```
	

	*  Obtain the latest R packages (line 1). Add an entry with URL of your favorite CRAN mirror (See https://cran.r-project.org/mirrors.html for the list of CRAN mirrors) and choose your Ubuntu operating
	system (Xenial 16.04, Trusty 14.04 or Precise 12.04) 
	*  Use strong crypto to validate downloaded packages (line 2). The Ubuntu archives on CRAN are signed with the key of “Michael Rutter marutter@gmail.com” with key ID E084DAB9. To add the key to your system with one command use
	<sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9> 
	*  Install the complete R system (line 3-4), use <sudo apt-get install r-base>
	*  Install the r-base-dev package (line 5). Users who need to instal packages with "install.packages()" should also install the r-base-dev package 



####Step 4.3: Install R Package 
You’ll also need to install the Shiny R package before installing Shiny Server:
	```sh
	RUN R -e "install.packages(c('shiny','ggplot2','tidyr','knitr', 'rmarkdown', 'SparkR'), repos='https://cran.rstudio.com/')"
	```




###Step 5: Download and  Install Rstudio Server 
See the link https://cran.rstudio.com/bin/linux/ubuntu/README.html on the Rstudio webpage for details.  

Default value:

username: rstudio
password: rstudio

	```sh
	# Download and Install R studio Server 
	RUN set -e \
		  && curl https://s3.amazonaws.com/rstudio-server/current.ver \
			| xargs -I {} curl http://download2.rstudio.org/rstudio-server-{}-amd64.deb -o rstudio.deb \
		  && gdebi -n rstudio.deb \
		  && rm rstudio.deb

	# Set the username and password default value to "rstudio"	  
	RUN set -e \
		  && useradd -m -d /home/rstudio rstudio \
		  && echo rstudio:rstudio \
			| chpasswd
			
	EXPOSE 8787

	CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0", "--server-app-armor-enabled=0"]	
	```



### build_logins.sh

### run.sh


**[Back to top](#table-of-contents)**

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there are Known Issues, you might want to include them under their own heading here.

## License

The MIT License
