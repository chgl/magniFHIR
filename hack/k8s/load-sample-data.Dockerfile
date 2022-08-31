FROM curlimages/curl:7.85.0@sha256:9fab1b73f45e06df9506d947616062d7e8319009257d3a05d970b0de80a41ec5

WORKDIR /data

COPY fhir/*.json .

COPY k8s/load-sample-data.sh .

USER 65532:65532
ENTRYPOINT [ "/data/load-sample-data.sh" ]
