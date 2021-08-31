FROM ubuntu:latest
RUN apt-get -y update

RUN apt-get -y install python3
RUN apt-get -y install python3-pip
RUN pip install httpserver
RUN mkdir -p /usr/src/app
COPY httpserver.py /usr/src/app/httpserver.py 
WORKDIR /usr/src/app
CMD [ "python3", "/usr/src/app/httpserver.py" ]
