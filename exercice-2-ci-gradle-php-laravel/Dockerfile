FROM gradle
RUN mkdir /home/gradle/project
WORKDIR /home/gradle/project
VOLUME project
COPY ./ /home/gradle/project

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt install php gzip -yq --no-install-recommends

RUN gradle tarball --no-daemon --info
