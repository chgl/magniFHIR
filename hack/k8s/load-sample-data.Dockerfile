FROM curlimages/curl:8.23.0@sha256:a134550be58ab783810e613ae96fd253c38f7bdd16d9bf9be350700c7a29ac06

WORKDIR /data

COPY fhir/*.json .

COPY k8s/load-sample-data.sh .

USER 65532:65532
ENTRYPOINT [ "/data/load-sample-data.sh" ]
