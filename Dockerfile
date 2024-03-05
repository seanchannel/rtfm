FROM ubuntu
MAINTAINER Sean Channel <pentabular@gmail.com>
 
ENV HOSTNAME rtfm
ENV DEBIAN_FRONTEND noninteractive
ENV NEEDRESTART_MODE a
RUN apt-get update

# make rtfm.local discoverable 
# RUN apt install -y libnss-mdns avahi-autoipd avahi-daemon avahi-discover avahi-dnsconfd

# install lighttp & doc processing tools, search engine
RUN apt-get -y install lighttpd info dwww dpkg-www man2html swish++ info2www antiword pstotext poppler-utils

# enable lighttp cgi & dwww hooks
RUN lighty-enable-mod cgi && lighty-enable-mod debian-doc && \
    sed -i 's/^\$HTTP.*$/\$HTTP["remoteip"] =~ ".*" {/g' /etc/lighttpd/conf-enabled/90-debian-doc.conf && \
    sed -i 's/^#FilterFile/FilterFile/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^#FollowLinks/FollowLinks/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^RecurseSubdirs/#RecurseSubdirs/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^WordThreshold.*$/WordThreshold   5000000/g' /usr/share/dwww/swish++.conf && \
    sed -i 's/^StoreWordPositions/#StoreWordPositions/g' /usr/share/dwww/swish++.conf /usr/share/man2html/swish++.conf && \
    echo "DWWW_MERGE_MAN2HTML_INDEX='yes'" >> /etc/dwww/dwww.conf && \
    echo "DWWW_USE_CACHE='no'" >> /etc/dwww/dwww.conf && \
    ln -s /var/lib/info2www /var/www

# install some core docs / things with docs -- season to taste
RUN apt-get -y install miscfiles lighttpd-doc linux-doc build-essential binutils-doc \
    autoconf-doc automake bison-doc cpp-doc diffutils-doc flex gcc-doc gdb gdb-doc \
    bison glibc-doc gnu-standards git git-doc libtool libtool-doc make-doc libboost-doc \
    stl-manual gettext gettext-doc libcppunit-doc libcunit1-doc gawk-doc krb5-doc \
    doc-debian debian-kernel-handbook

# run the indexing scripts
RUN echo "updating indexes.." && \
    /etc/cron.daily/man-db && \
    /etc/cron.weekly/man-db && \
    /etc/cron.weekly/man2html && \
    /etc/cron.daily/dwww && \
    /etc/cron.weekly/dwww
 
# get ready to launch!
EXPOSE 80
ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
