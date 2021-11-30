# zapci-dojo
ZAPCI DefectDojo

# Spiderscan
- Clone Repository
- cd spiderscan/
- Running test
```
TARGET_URL='<target_url>' DOJOKEY='<api_key>' DOJOIP='<ip:port>'  PRODNAME='<Product_Name>' docker-compose up --force-recreate --build --exit-code-from scan
```
- check HTML and XML under `output` folder
