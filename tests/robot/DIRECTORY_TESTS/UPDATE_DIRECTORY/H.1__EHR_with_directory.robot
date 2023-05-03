# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Pablo Pazos (Hannover Medical School).
#
# This file is part of Project EHRbase
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



*** Settings ***
Documentation   Main flow: update directory from EHR with directory
...             
...             Preconditions:
...                 An EHR with ehr_id exists and has a directory.
...             
...             Flow:
...                 1. Invoke the update directory service for the ehr_id
...                 2. The service should return a positive result related w/
...                    the updated directory
...                 3. The directory version ID should reflect it is
...                    a new version from the previous directory version
...             
...             Postconditions:
...                 The EHR ehr_id has the updated directory structure.
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot

Test Setup              Preconditions
Test Teardown           Postconditions


*** Test Cases ***
Main flow: update directory from EHR with directory
    [Documentation]     Steps of this test:
    ...                     1. Create empty folder
    ...                     2. Add subfolders
    ...                     3. Add items to folder/subfolder
    ...                     4. validate result
    ...                     \nCovers as well: https://vitagroup-ag.atlassian.net/browse/CDR-828
    [Tags]              

    update DIRECTORY (JSON)    update/2_add_subfolders.json
    validate PUT response - 200 updated
    Should Contain      ${response.json()['uid']['value']}      ${CREATING_SYSTEM_ID}::2
    ${rootFolderCount}      Get Length      ${response.json()['folders']}
    ${subRootFolderCount}      Get Length      ${response.json()['folders'][0]['folders']}
    Should Be Equal As Strings    ${rootFolderCount}    ${1}
    Should Be Equal As Strings    ${subRootFolderCount}    ${1}
    Should Be Equal As Strings     ${response.json()['folders'][0]['name']['value']}      history
    Should Be Equal As Strings     ${response.json()['folders'][0]['folders'][0]['name']['value']}      family

    update DIRECTORY (JSON)    update/3_add_items.json
    validate PUT response - 200 updated
    Should Contain      ${response.json()['uid']['value']}      ${CREATING_SYSTEM_ID}::3



*** Keywords ***
Preconditions
    create EHR
    create DIRECTORY (JSON)    update/1_create_empty_directory.json


Postconditions
    get DIRECTORY (JSON)
    validate GET response - 200 retrieved
