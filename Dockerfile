FROM bigboards/base-__arch__

MAINTAINER Koen Rutten <koen.rutten@archimiddle.com>

# install dependencies
RUN apt-get update && apt-get install -y r-base r-base-dev gdebi-core libapparmor1 wget

# install rstudio
RUN wget -O /tmp/rstudio.deb http://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb && \
    gdebi -n /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

RUN adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd

RUN wget -O /tmp/caret.tar.gz https://cran.r-project.org/src/contrib/caret_6.0-70.tar.gz && \
    R CMD INSTALL /tmp/caret.tar.gz &&
    rm /tmp/caret.tar.gz

RUN mkdir -p /data/ml && chown guest /data/ml
VOLUME /data/ml

EXPOSE 8787

CMD ["/usr/lib/rstudio-server/bin/rserver"]
