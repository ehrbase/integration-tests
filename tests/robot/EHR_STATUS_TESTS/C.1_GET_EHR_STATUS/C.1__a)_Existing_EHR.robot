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
Metadata    Version    0.1.0
Metadata    Authors    *Wladislaw Wagner*, *Pablo Pazos*
Metadata    Created    2019.07.02

Documentation   C.1.a) Main flow: Get status of an existing EHR
...             Preconditions:
...                 An EHR with known ehr_id should exist.
...
...             Postconditions:
...                 None
...
...             Flow:
...                 1. Invoke the get EHR_STATUS service by the existing ehr_id
...                 2. The result should be positive and retrieve a correspondent EHR_STATUS.
...                    The EHR_STATUS internal information should match the rules in which
...                    the EHR was created (see test flow Create EHR) and those should be verified:
...
...                    a) has or not a subject_id
...                    b) has correct value for is_modifiable
...                    c) has correct value for is_queryable
Metadata        TOP_TEST_SUITE    EHR_STATUS

Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

# Suite Setup  startup SUT
# Suite Teardown  shutdown SUT

Force Tags



*** Test Cases ***
Get Status Of Existing EHR (JSON)

    prepare new request session    JSON    Prefer=return=representation

    create new EHR

    get ehr_status of EHR

    Verify Response (JSON)
    [Teardown]      (admin) delete ehr


Get Status Of Existing EHR (XML)

    prepare new request session    XML    Prefer=return=representation

    create new EHR (XML)

    get ehr_status of EHR

    verify response (XML)
    [Teardown]      (admin) delete ehr





*** Keywords ***
verify response (JSON)
        Status Should Be    200
        Should Be Equal As Strings      ${response.json()['uid']['value']}      ${ehrstatus_uid}

verify response (XML)
        Should Be Equal As Strings      ${response.status_code}    200
        # has or not a subject_id
        # has correct value for is_modifiable
        # has correct value for is_queryable
