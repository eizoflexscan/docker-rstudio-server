FROM bigboards/base-x86_64
#FROM bigboards/base-__arch__

MAINTAINER Koen Rutten <koen.rutten@archimiddle.com>

# install dependencies
RUN apt-get update && apt-get install -y r-base r-base-dev gdebi-core libapparmor1 wget libcurl4-openssl-dev

# install rstudio
RUN wget -O /tmp/rstudio.deb http://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb && \
    gdebi -n /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

RUN adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd

# install R libraries
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN echo 'install.packages(c("caret","tidyr","stringr","caretEnsemble","party","devtools"), repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R
    && rm /tmp/packages.R
#RUN Rscript -e "install.packages('yhatr')"
#RUN Rscript -e "install.packages('ggplot2')"
#RUN Rscript -e "install.packages('plyr')"
#RUN Rscript -e "install.packages('reshape2')"
#RUN Rscript -e "install.packages('forecast')"
#RUN Rscript -e "install.packages('stringr')"
#RUN Rscript -e "install.packages('lubridate')"
#RUN Rscript -e "install.packages('randomForest')"
#RUN Rscript -e "install.packages('rpart')"
#RUN Rscript -e "install.packages('e1071')"
#RUN Rscript -e "install.packages('kknn')"
#RUN Rscript -e "install.packages('caret')"

RUN mkdir -p /data/ml && chown guest /data/ml
VOLUME /data/ml

EXPOSE 8787

CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize 0"]
