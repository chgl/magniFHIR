FROM curlimages/curl:7.88.1@sha256:48318407b8d98e8c7d5bd4741c88e8e1a5442de660b47f63ba656e5c910bc3da

WORKDIR /data

COPY fhir/*.json .

COPY k8s/load-sample-data.sh .

USER 65532:65532
ENTRYPOINT [ "/data/load-sample-data.sh" ]
