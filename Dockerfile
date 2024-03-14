FROM ubuntu
MAINTAINER Sean Channel <pentabular@gmail.com>
 
ENV HOSTNAME rtfm
ENV DEBIAN_FRONTEND noninteractive
ENV NEEDRESTART_MODE a
RUN apt-get update

## install all your favorite things / with docs -- season to taste
RUN apt-get -y install gnu-standards miscfiles linux-doc doc-debian debian-kernel-handbook \
    build-essential gcc-doc git git-doc diffutils diffutils-doc binutils binutils-doc \
    gdb gdb-doc autoconf-doc automake bison bison-doc flex flex-doc gettext gettext-doc \
    make-doc libcunit1-doc cpp-doc libcppunit-doc gawk-doc glibc-doc libtool libtool-doc \
    junit4 junit4-doc libcunit1 libcunit1-doc

## install doc processing tools, search engine, TODO  lighttpd
RUN apt-get -y install info dwww dpkg-www man2html swish++ info2www antiword pstotext poppler-utils

## TODO: check apache mods enabled
RUN sed -i 's/^#FilterFile/FilterFile/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^#FollowLinks/FollowLinks/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^RecurseSubdirs/#RecurseSubdirs/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^WordThreshold.*$/WordThreshold   5000000/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^StoreWordPositions/#StoreWordPositions/g' /usr/share/dwww/swish++.conf \
    /usr/share/man2html/swish++.conf && \
    echo "DWWW_MERGE_MAN2HTML_INDEX='yes'" >> /etc/dwww/dwww.conf && \
    echo "DWWW_USE_CACHE='no'" >> /etc/dwww/dwww.conf && \
    sed -i 's/Require\ local/Require all granted/g' /etc/apache2/conf-enabled/dwww.conf \
    /etc/apache2/conf-enabled/man2html.conf dpkg-www.conf && \
    ln -s /var/lib/info2www /var/www

RUN echo "updating indexes.." && \
    /etc/cron.daily/man-db && \
    /etc/cron.weekly/man-db && \
    /etc/cron.weekly/man2html && \
    /etc/cron.daily/dwww && \
    /etc/cron.weekly/dwww

# get ready to launch!
EXPOSE 80
ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
