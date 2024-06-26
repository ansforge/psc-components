# sec-psc component version history

## Principle

Each time one or more sec-psc components are released and delivered, add an entry in this file to record
the new component version combination (sec-psc distribution description).
Give this new distribution a semantic version number based on what changed (new features vs simple maintenance or bugfix). Push a mtching version tag.

## History

### 1.2.0

**NB** : these version number and entry content are provisional,  as 1.2.0 has not been released yet, as of 2024/05/22

This version adds the necessary change for the administration portal :
- Using fixed prometheus & alertmanager version to be able to rely on alertmanager's v2 API.

|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|

### 1.1.0

Adding a sha256 digest to all archives produced by psc-extract to allow the downloader
to check extract interity after downloading and unzipping it. Released on 2024/04/25.


|Component|Version|
|---------|-------|
|psc-ps-api|`2.0.1`|
|psc-amar-connector|`1.0.0`|
|psc-toggle-manager|`0.0.2`|
|psc-rass-loader|`1.0.1`|
|psc-extract|`0.1.0`|

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
