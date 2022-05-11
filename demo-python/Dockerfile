FROM gradle

COPY src/ /home/gradle/src
COPY build.gradle /home/gradle/

RUN apt update -yq && apt install -yq python3 python3-pip

RUN pip install pytest 

CMD gradle packageApp