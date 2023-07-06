FROM ubuntu:lunar

RUN mkdir -p /sdwa

ADD . /sdwa/

RUN apt-get update && apt-get upgrade && apt-get install -y python3-pip git

WORKDIR /sdwa

RUN pip3 install -r requirements.txt

RUN cd /sdwa && rm -f db/vuln_db.sqlite && ls -la /sdwa/db/ && python3 /sdwa/db/setup_db.py

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

CMD ["flask", "run", "-h", "0.0.0.0"]
