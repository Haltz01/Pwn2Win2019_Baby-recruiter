FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive 

# install web server
RUN apt-get update

RUN apt install -y apache2 curl php libapache2-mod-php php-mysql php-xml gdebi wget iptables net-tools

# we really don't like hackers
RUN find / -name "*.dtd" -type f -delete

RUN find / -name "*.xml" -type f -delete

# install prince
WORKDIR /tmp

RUN wget https://www.princexml.com/download/prince_12.5-1_ubuntu18.04_amd64.deb

RUN gdebi --option=APT::Get::force-yes="true" --option=APT::Get::Assume-Yes="true" -n prince_12.5-1_ubuntu18.04_amd64.deb

# setup webserver
WORKDIR /var/www/html

COPY . . 

RUN rm -rf index.html Dockerfile && mkdir resumes

RUN chmod 777 resumes

RUN echo '' > resumes/index.html 

# create a flag
RUN echo -n 'this_is_not_the_flag' > /etc/flag

RUN chmod +x iptables.sh && ./iptables.sh

RUN rm iptables.sh

# start web service
RUN service apache2 start

EXPOSE 1337
CMD apachectl -D FOREGROUND
