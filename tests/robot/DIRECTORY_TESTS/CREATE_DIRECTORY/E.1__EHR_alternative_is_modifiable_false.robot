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
Documentation    Main flow: create directory on empty EHR
...
...     Preconditions:
...         An EHR with ehr_id exists and doesn't have directory
...
...     Flow:
...         1. Invoke the create directory service for a random ehr_id
...         2. The service should return a a positive result related with the
...            directory just created for the EHR
...
...     Postconditions:
...         The EHR ehr_id has directory
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

#Suite Setup  startup SUT
# Test Setup  start openehr server
# Test Teardown  restore clean SUT state
#Suite Teardown  shutdown SUT

Force Tags



*** Test Cases ***
Alternative flow: create directory on empty EHR, with is_modifiable set to False
    create EHR
    update EHR: set ehr-status modifiable    ${FALSE}
    create DIRECTORY (JSON)    empty_directory.json     isModifiable=${FALSE}
    Status Should Be        409
    Should Contain    ${response.text}    does not allow modification
    [Teardown]    (admin) delete ehr

