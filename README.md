# zapci-dojo
ZAPCI DefectDojo

# Usage Spiderscan
- Clone Repository
- cd spiderscan/
- Running test
```
TARGET_URL='<target_url>' DOJOKEY='<api_key>' DOJOIP='<ip:port>'  EGID='<Engagement_ID>' docker-compose up --build --exit-code-from scan
```
- check HTML and XML under `output` folder