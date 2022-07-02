FROM golang:1.14

WORKDIR /go/src/app

COPY . .

RUN go get -d -v github.com/minio/minio-go/v6
RUN go get -d -v github.com/go-pg/pg/v10
RUN go get -d -v github.com/streadway/amqp

RUN go install -v main.go

CMD ["main"]