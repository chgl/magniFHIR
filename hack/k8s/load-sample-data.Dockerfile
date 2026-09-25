FROM curlimages/curl:8.22.0@sha256:58adaa4e8dca9c988bae2aba4ab3434a0bb2da16bbe3f92dec39ec7785166777

WORKDIR /data

COPY fhir/*.json .

COPY k8s/load-sample-data.sh .

USER 65532:65532
ENTRYPOINT [ "/data/load-sample-data.sh" ]
