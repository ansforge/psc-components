# sec-psc component version history

## Principle

Each time one or more sec-psc components are released and delivered, add an entry in this file to record
the new component version combination (sec-psc distribution description).
Give this new distribution a semantic version number based on what changed (new features vs simple maintenance or bugfix). Push a mtching version tag.

## History


### 1.2.0

This version adds the necessary change for the administration portal :
- Using fixed prometheus & alertmanager version to be able to rely on alertmanager's v2 API.
- Adjusting kibana, prometheus and rabbitMQ(management UI) configuration to make them avaiable through the administration portal
- Switching to new versions of psc-ps-api & psc-toggle-manager to support the new toggle remove feature.
- Switching to psc-amar-connector 1.1.2 to add the endpoint used to get feedback about ongoing message processing.
- Switching to psc-extract 0.2.0 to add the status reporting and test file upload endpoints
- Switching to psc-rass-loader 1.1.1 to add the endpoint used to clear the files directory and an additional process execution scheduled at 11PM
- Locking major & minor versions of mongodb & mongo-express at respectively 7.0 and 1.0 to ensure reliability.

|Component| Version |
|---------|---------|
|psc-ps-api| `2.1.0` |
|psc-amar-connector| `1.1.2` |
|psc-toggle-manager| `0.1.0` |
|psc-rass-loader| `1.1.1` |
|psc-extract| `0.2.0` |
|psc-admin-portal| `1.0.0` |


### 1.1.6

This version backports version control over mongodb (7.0.x) and mongoexpress (1.0.x).

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.3`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|


### 1.1.5

This version fixes a broken prometheus docker image tag format.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.3`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|


### 1.1.4

This version deploys a fixed version of psc-amar-connector to properly replicate main identity data into otehrId identities in AMAR. Released on 2024/07/25.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.3`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|


### 1.1.3

This version deploys a fixed version of psc-amar-connector to avoid rejection PS with no first name create/update operations by AMAR. Released on 2024/07/12.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.2`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|


### 1.1.2

This version deploys a fixed version of psc-amar-connector to avoid rejection of some PS create/update operations by AMAR. Released on 2024/07/11.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.1`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|


### 1.1.1

This version adds fixed prometheus & alertmanager version to be able to rely on alertmanager's v2 API.
This doesn't change used versions, we record and stabilize current versions.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|

### 1.1.0

Adding a sha256 digest to all archives produced by psc-extract to allow the downloader
to check extract integrity after downloading and unzipping it. Released on 2024/04/25.


|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|

### 1.0.4

This version adds fixed prometheus & alertmanager version to be able to rely on alertmanager's v2 API.
(no effective version change, we're just recording and stabilizing current versions)

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.0.1`|


### 1.0.3

Fix for psc-rass-loader on 2024/04/12

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.0.1`|


### 1.0.2

Hot fix on psc-mongodb on 2024/04/10

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.0`|
|psc-extract|`0.0.1`|

### 1.0.1

Hot fix on pscc-toggle-ids on 2024/04/04

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.0`|
|psc-extract|`0.0.1`|

### 1.0.0

First recorded distribution. This is the state of production as of March 01, 2024.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.1`|
|psc-rass-loader|`1.0.0`|
|psc-extract|`0.0.1`|
