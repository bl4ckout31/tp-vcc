FROM python

RUN apt-get update && \ 
    apt-get -qqy install --no-install-recommends \ 
        autoconf \ 
        automake \ 
        build-essential \ 
        ca-certificates \ 
        git \ 
        mercurial \ 
        cmake \ 
        libass-dev \ 
        libgpac-dev \ 
        libtheora-dev \ 
        libtool \ 
        libvdpau-dev \ 
        libvorbis-dev \ 
        libopus-dev \ 
        pkg-config \ 
        texi2html \ 
        zlib1g-dev \ 
        libmp3lame-dev \ 
        wget \ 
        yasm && \ 
    apt-get -qqy clean && \ 
    rm -rf /var/lib/apt/lists/*
    
ADD build.sh /build.sh
RUN /bin/bash /build.sh

WORKDIR /app
ADD requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
ADD . /app/

CMD [ "python", "manage.py", "runserver" , "0.0.0.0:8000"]
