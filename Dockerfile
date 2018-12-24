FROM httpd:2.4
# Данный образ базируется на стандартном образе Debian+Apache 2.4: https://store.docker.com/images/httpd

MAINTAINER Petr Myazin <petr.myazin@gmail.com>
MAINTAINER Oleg Doroshenko <oleg@doroshenko.su>

# Копируем дистрибутив в директорию dist
COPY deb64.tar.gz /dist/deb64.tar.gz
COPY deb.tar.gz /dist/deb.tar.gz

# Разархивируем дистрибутив
RUN tar -xzf /dist/deb64.tar.gz -C /dist \
  # и устанавливаем пакеты 1С в систему внутри контейнера
  && dpkg -i /dist/*.deb \
  # и тут же удаляем исходные deb файлы дистрибутива, которые нам уже не нужны
  && rm /dist/*.deb

RUN cp -r /opt/1C/v8.3/x86_64 /opt/1C/v8.3/x86_copy
RUN apt-get --yes remove 1c-enterprise83-ws && apt-get --yes remove 1c-enterprise83-server && apt-get --yes remove 1c-enterprise83-common 
RUN apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales \
  && apt-get -qq install --yes --no-install-recommends fontconfig imagemagick \
  && apt-get -qq install --yes --no-install-recommends xfonts-utils cabextract mc screen lrzsz wget
RUN dpkg --add-architecture i386 && apt-get update --yes && apt-get upgrade --yes
RUN apt-get autoremove --yes
RUN apt-get --yes install imagemagick-6.q16:i386 
RUN apt-get --yes install imagemagick:i386 
RUN apt-get --yes install unixodbc:i386

RUN sh -c 'echo "deb http://ftp.ru.debian.org/debian/ stretch contrib" > /etc/apt/sources.list.d/debian-stretch-contrib.list' && apt-get update --yes 

RUN apt-get --yes install libgsf-1-114:i386 

RUN mkdir --parent /var/log/1C /home/usr1cv8/.1cv8/1C/1cv8/conf
    
RUN apt-get -qq install --yes --no-install-recommends libwebkitgtk-1.0-0:i386
RUN apt-get -qq install --yes --no-install-recommends libwebkitgtk-3.0-0:i386
RUN apt-get -f install

RUN apt-get --yes install libgd3:i386 \
&& apt-get --yes install libzip4:i386 \
&& apt-get --yes install libfreetype6:i386 \
&& apt-get --yes install libglib2.0-0:i386 \
&& apt-get --yes install libkrb5-3:i386 \
&& apt-get --yes install libgssapi-krb5-2:i386

RUN wget --quiet --output-document /tmp/libpng12-0_1.2.50-2+deb8u3_i386.deb http://ftp.ru.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_i386.deb
RUN dpkg --install /tmp/libpng12-0_1.2.50-2+deb8u3_i386.deb && rm /tmp/libpng12-0_1.2.50-2+deb8u3_i386.deb 
  

# Разархивируем дистрибутив
RUN tar -xzf /dist/deb.tar.gz -C /dist \
  # и устанавливаем пакеты 1С в систему внутри контейнера
  && dpkg -i /dist/*.deb \
  # и тут же удаляем исходные deb файлы дистрибутива, которые нам уже не нужны
  && rm /dist/*.deb \
  && chown --recursive usr1cv8:grp1cv8 /var/log/1C /home/usr1cv8

# Копируем внутрь контейнера заранее подготовленный конфиг от Apache
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Копируем внутрь контейнера заранее подготовленный конфиг с настройками подключения к серверу 1С
COPY default.vrd /usr/local/apache2/htdocs/BuhBase/default.vrd
