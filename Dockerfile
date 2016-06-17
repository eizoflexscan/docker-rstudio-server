FROM bigboards/base-__arch__

MAINTAINER Koen Rutten <koen.rutten@archimiddle.com>

# install dependencies
RUN apt-get update && apt-get install -y r-base r-base-dev gdebi-core libapparmor1 supervisor wget

# install rstudio
RUN wget http://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb && \
    gdebi -n rstudio-server-0.99.902-amd64.deb && \
    rm /rstudio-server-0.98.978-amd64.deb

RUN adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd

EXPOSE 8787

CMD ["/usr/lib/rstudio-server/bin/rserver"]
