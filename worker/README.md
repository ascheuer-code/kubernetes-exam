# Facerecognition YOLO

Simple object recognition worker configured to perform face blur on jpg images fed via a RabbitMQ message queue.

The code is part of the final exam of the free [anynines Kubernetes Tutorial](https://learn.kubernetes.anynines.com/).
Therefore, the code is not meant to be production grade and contains refactoring TODOs that learners may engage with.

## The Worker

The worker performs the following steps

* Connect to RabbitMQ
* Retrieve a job (message)
* Retrieve the image
* Start image processing
* Upload the image
* Acknowledge the message (and thus remove it from the queue)

Read the source code for further information.

## Building the Image

Example:

    docker build -t facerecognition-yolo:dev .

## Publishing the Image

Example:

    docker tag facerecognition-yolo:dev fischerjulian/facerecognition-yolo:dev
    docker push fischerjulian/facerecognition-yolo:dev

As a oneliner:

    docker build -t facerecognition-yolo:dev . && docker tag facerecognition-yolo:dev fischerjulian/facerecognition-yolo:dev && docker push fischerjulian/facerecognition-yolo:dev

## Running the Image

Example:

    docker run --rm -it --name facerecognition-yolo facerecognition-yolo bash

### Running the Face Recognition

Inside the container run:

    cd python3 yolo_opencv.py --image /tmp/object_recognition/original-image.jpg --config yolov3.cfg --weights yolov3.weights --classes yolov3.txt 

This will produce output file: `/tmp/object_recognition/filtered-image.jpg`

## Downloading the YOLO Weights Definition

    wget https://pjreddie.com/media/files/yolov3.weights

## Links and Further Reading

1. https://pjreddie.com/darknet/yolo/
2. https://github.com/loretoparisi/docker/tree/master/darknet
3. https://www.arunponnusamy.com/yolo-object-detection-opencv-python.html
