FROM bigboards/base-x86_64
#FROM bigboards/base-__arch__

MAINTAINER Koen Rutten <koen.rutten@archimiddle.com>

# install dependencies
RUN apt-get update && apt-get install -y gdebi-core libapparmor1 wget libcurl4-openssl-dev

# install latest R Base 
RUN codename=$(lsb_release -c -s) && \
	echo "deb http://freestatistics.org/cran/bin/linux/ubuntu $codename/" | tee -a /etc/apt/sources.list > /dev/null && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
	apt-get update && apt-get install -y r-base r-base-dev
	
# install RStudio
RUN wget -O /tmp/rstudio.deb http://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb && \
    gdebi -n /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

RUN adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd

# install R libraries
RUN echo 'install.packages(c("ggplot2","caret","tidyr","stringr","caretEnsemble","party","devtools"), repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R &&  \
	Rscript /tmp/packages.R && \
	rm /tmp/packages.R && \
	echo 'library("devtools"); install_github("mbojan/alluvial")' > /tmp/packages.R && \
	Rscript /tmp/packages.R && \
	rm tmp/packages.R

RUN mkdir -p /data/ml && chown guest /data/ml
VOLUME /data/ml

EXPOSE 8787

CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize 0"]
