# Copyright (c) 2021 Jake Smolka (Hannover Medical School),
#                    Wladislaw Wagner (Vitasystems GmbH),
#                    Pablo Pazos (Hannover Medical School).
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
Metadata    Authors    *Jake Smolka*, *Wladislaw Wagner*
Metadata    Created    2021.01.26

Metadata        TOP_TEST_SUITE    EHR_STATUS

Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/aql_query_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

# Suite Setup  startup SUT
# Suite Teardown  shutdown SUT

Force Tags



*** Test Cases ***
1. Get Versioned Status Of Existing EHR by Version UID (JSON)
    [Documentation]    Simple, valid request

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    Set Test Variable  ${version_uid}  ${ehrstatus_uid}

    get versioned ehr_status of EHR by version uid
    Status Should Be    200
    Should Be Equal As Strings    ${ehrstatus_uid}    ${response.json()['uid']['value']}
    [Teardown]      (admin) delete ehr


1b. Get Versioned Status Of Existing EHR With 2 Versions by Version UID (JSON)
    [Documentation]    Simple, valid request

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)

    Set Test Variable  ${version_uid}  ${ehrstatus_uid[0:-1]}2

    get versioned ehr_status of EHR by version uid
    Status Should Be    200
    Should Be Equal As Strings    ${version_uid}    ${response.json()['uid']['value']}
    [Teardown]      (admin) delete ehr


1c. Get Versioned Status Of Existing EHR With 2 Versions by Invalid Version UID (JSON)
    [Documentation]    Simple, valid EHR_ID but invalid (non-existent) version

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)

    Set Test Variable  ${version_uid}  ${ehrstatus_uid[0:-1]}3

    get versioned ehr_status of EHR by version uid
    Status Should Be    404
    [Teardown]      (admin) delete ehr


1d. Get Versioned Status Of Existing EHR by Invalid Version UID (JSON)
    [Documentation]    Simple, invalid (negative) version number

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)

    Set Test Variable  ${version_uid}  ${ehrstatus_uid[0:-1]}-2

    get versioned ehr_status of EHR by version uid
    Status Should Be    400
    [Teardown]      (admin) delete ehr


1e. Get Versioned Status Of Existing EHR by Invalid Version UID (JSON)
    [Documentation]    Simple, invalid (floating point) version number

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)

    Set Test Variable  ${version_uid}  ${ehrstatus_uid[0:-1]}2.0

    get versioned ehr_status of EHR by version uid
    Status Should Be    400
    [Teardown]      (admin) delete ehr


1f. Get Versioned Status Of Existing EHR by Invalid Version UID (JSON)
    [Documentation]    Simple, invalid (random) version UID


    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201
    
    generate random version_uid
    get versioned ehr_status of EHR by version uid
    Status Should Be    404
    [Teardown]      (admin) delete ehr


2. Get Versioned Status Of EHR by Version UID Invalid EHR (JSON)
    [Documentation]    Simple, invalid EHR_ID (non-existent)

    prepare new request session    JSON    Prefer=return=representation

    generate random ehr_id
    generate random version_uid

    get versioned ehr_status of EHR by version uid
    Status Should Be    404


3. Get Versioned Status Of Existing EHR by Version UID Invalid Version UID (JSON)
    [Documentation]    Simple, valid EHR_ID but invalid version_uid

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    # comment: alter version uid to invalid one
    Set Test Variable  ${version_uid}  ${ehrstatus_uid[0:-1]}2

    get versioned ehr_status of EHR by version uid
    Status Should Be    404
    [Teardown]      (admin) delete ehr


4. Get Versioned Status Of Existing EHR With 2 Versions by Version UID Invalid Version UID (JSON)
    [Documentation]    Simple, valid EHR_ID but invalid version_uid

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Status Should Be    201

    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)

    generate random version_uid

    # comment: alter version uid to invalid one
    Set Test Variable  ${version_uid}  ${version_uid[0:-1]}2

    get versioned ehr_status of EHR by version uid
    Status Should Be    404
    [Teardown]      (admin) delete ehr
