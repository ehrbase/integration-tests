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
Documentation   Alternative flow 2: update directory on non-existing EHR
...             Preconditions:
...                 An EHR with ehr_id does not exist.
...             
...             Flow:
...                 1. Invoke the update directory service for random ehr_id
...                 2. The service should return an error
...                    related to the non-existent ehr_id
...             
...             Postconditions:
...                 None.
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/ehr_keywords.robot
Suite Setup     Set Library Search Order For Tests

#Suite Setup  startup SUT
# Test Setup  start openehr server
# Test Teardown  restore clean SUT state
#Suite Teardown  shutdown SUT

Force Tags    refactor



*** Test Cases ***
Alternative flow 2: update directory on non-existing EHR
    [Tags]              

    create fake EHR
    update DIRECTORY - fake ehr_id (JSON)    update/2_add_subfolders.json
    validate PUT response - 404 unknown ehr_id
