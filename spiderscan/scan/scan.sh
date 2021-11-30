#!/bin/bash

echo "URL zap: $PROXY_URL"
echo "DOJOIP: $DOJOIP"
echo "Target: $TARGET_URL"

echo "ZAP is ready"

SESS=`curl -s --fail "$PROXY_URL/JSON/core/action/newSession"`
SESS=`curl -s --fail "$PROXY_URL/JSON/pscan/action/enableAllScanners"`
SESS=`curl -s --fail "$PROXY_URL/JSON/core/action/clearExcludedFromProxy"`

echo "Ready for testing"

#set maximum spider parameters
MAX=`curl "$PROXY_URL/JSON/spider/action/setOptionMaxDuration/?Integer=10"`
MAX_DEPTH=`curl -X GET "$PROXY_URL/JSON/spider/action/setOptionMaxDepth/?Integer=5"`
MAX_CHILD=`curl -X GET "$PROXY_URL/JSON/spider/action/setOptionMaxChildren/?Integer=10"`

echo "scanning..."
SCANID=`curl "$PROXY_URL/JSON/spider/action/scan/?url=$TARGET_URL&contextName=&recurse="`

#check status

STATUS='"0"'
while [ "$STATUS" != '"100"' ]
do
STATUS=`curl --fail "$PROXY_URL/JSON/spider/view/status/?scanId=$SCANID" 2> /dev/null | jq '.status'`
sleep 2
echo "current status: $STATUS"

if [ -z "$STATUS" ]
then
 exit 1
fi

done

echo "generating report..."
sleep 5

#report
#curl --fail http://localhost:8090/OTHER/core/other/jsonreport/?formMethod=GET > report.json
result=`curl --fail "$PROXY_URL/OTHER/core/other/xmlreport/?formMethod=GET" > output/report.xml`
#html=`curl --fail "$PROXY_URL/OTHER/core/other/htmlreport/?formMethod=GET" > output/report.html`

PRODID=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Token ${DOJOKEY}" --url "http://{$DOJOIP}/api/v2/products/?limit=1000" | jq -c '[.results[] | select(.name | contains('\"${PRODNAME}\"'))][0] | .id')
EGID=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Token $DOJOKEY" --url "http://${DOJOIP}/api/v2/engagements/?limit=1000" | jq -c "[.results[] | select(.product == ${PRODID})][0] | .id")
curl -X POST --header "Content-Type:multipart/form-data" --header "Authorization:Token $DOJOKEY" -F "engagement=${EGID}" -F "scan_type=ZAP Scan" -F 'file=@./output/report.xml' --url "http://${DOJOIP}/api/v2/import-scan/"
