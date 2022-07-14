FROM ubuntu:18.04

LABEL maintainer="julian.fischer@anynines.com"
LABEL description="Facerecognition using (Darnket) Yolo Weights."

RUN mkdir /workdir

WORKDIR /workdir

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Installation
RUN apt-get update && apt-get -y install --no-install-recommends \
  pkg-config \
  apt-utils \
  autoconf \
  automake \
  libtool \
  build-essential \
  git \
  python3 python3-numpy python3-setuptools python3-pip\
  libopencv-dev opencv-data \
  ruby-dev \
  ruby \
  libxml2-dev \
  libcurl4-openssl-dev \
  vim

RUN gem install bundler

COPY yolo_opencv.py /workdir/yolo_opencv.py
COPY yolov3.cfg /workdir/yolov3.cfg
COPY yolov3.txt  /workdir/yolov3.txt 
COPY yolov3.weights /workdir/yolov3.weights

RUN pip3 install opencv-python

# Provide an exemplary origina-file for, mainly for manual testing.
# RUN cp /workdir/object-detection-opencv/dog.jpg /tmp/original-image.jpg

COPY Gemfile /workdir/Gemfile
COPY worker.rb /workdir/worker.rb

RUN bundle

# Recommended CMD
# cd object-detection-opencv && python3 yolo_opencv.py --image /tmp/original-image.jpg --config yolov3.cfg --weights ../yolov3.weights --classes yolov3.txt 

CMD ["ruby", "worker.rb"]