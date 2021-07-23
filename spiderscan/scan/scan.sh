#!/bin/bash

echo "URL zap: $PROXY_URL"
echo "DOJOIP: $DOJOIP"
echo "Target: $TARGET_URL"

echo "ZAP is ready"

SESS=`curl -s --fail "$PROXY_URL/JSON/core/action/newSession"`
SESS=`curl -s --fail "$PROXY_URL/JSON/pscan/action/enableAllScanners"`
SESS=`curl -s --fail "$PROXY_URL/JSON/core/action/clearExcludedFromProxy"`

echo "Ready for testing"

#set maximum spider to 100s
MAX=`curl "$PROXY_URL/JSON/spider/action/setOptionMaxDuration/?Integer=100"`

echo "scanning..."
SCANID=`curl "$PROXY_URL/JSON/spider/action/scan/?url=https://www.example.com&contextName=&recurse="`

#check status

STATUS='"0"'
while [ "$STATUS" != '"100"' ]
do
STATUS=`curl --fail "$PROXY_URL/JSON/spider/view/status/?scanId=$SCANID" 2> /dev/null | jq '.status'`
sleep 1
echo "current status: $STATUS"
done

echo "generating report..."
sleep 5

#report
#curl --fail http://localhost:8090/OTHER/core/other/jsonreport/?formMethod=GET > report.json
result=`curl --fail "$PROXY_URL/OTHER/core/other/xmlreport/?formMethod=GET" > output/report.xml`
html=`curl --fail "$PROXY_URL/OTHER/core/other/htmlreport/?formMethod=GET" > output/report.html`

curl -X POST --header "Content-Type:multipart/form-data" --header "Authorization:Token $DOJOKEY" -F "engagement=${EGID}" -F "scan_type=ZAP Scan" -F 'file=@./output/report.xml' --url "http://${DOJOIP}/api/v2/import-scan/"