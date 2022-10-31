FROM curlimages/curl:7.86.0@sha256:cfdeba7f88bb85f6c87f2ec9135115b523a1c24943976a61fbf59c4f2eafd78e

WORKDIR /data

COPY fhir/*.json .

COPY k8s/load-sample-data.sh .

USER 65532:65532
ENTRYPOINT [ "/data/load-sample-data.sh" ]
