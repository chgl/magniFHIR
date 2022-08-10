#!/bin/sh

FHIR_SERVER_URL=${FHIR_SERVER_URL:-"http://localhost:8080/fhir"}

curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/hospitalInformation1658779445044.json' "${FHIR_SERVER_URL}"
curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/practitionerInformation1658779445044.json' "${FHIR_SERVER_URL}"
curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/Ashleigh_Olson_9d9b8bed-7b79-7fa9-cea1-f133a6b4d551.json' "${FHIR_SERVER_URL}"
curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/Eugene_Purdy_2500b9ad-56c8-447d-d0b4-589dea3008ba.json' "${FHIR_SERVER_URL}"
curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/Grace_Jenkins_0b72a5cf-ab16-61cb-4cdc-727a1078fdd6.json' "${FHIR_SERVER_URL}"
curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/Latina_Hana_Turcotte_c4b841d9-b890-48d1-cb0c-87450e1f2737.json' "${FHIR_SERVER_URL}"
curl -X POST -H 'Content-Type:application/fhir+json' --retry-connrefuse --connect-timeout 30 --max-time 60 --retry 5 --retry-delay 15 --data '@/data/Mattie_Zboncak_c423a667-3ea7-f553-a179-a4cf1948221f.json' "${FHIR_SERVER_URL}"

echo "Done loading sample resources"
