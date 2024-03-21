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

Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

# Suite Setup  startup SUT
# Suite Teardown  shutdown SUT

Test Setup
Test Teardown  

Force Tags      COMPOSITION_get_versioned



*** Test Cases ***
1. Get Versioned Composition Of Existing EHR (JSON)

    # prepare new request session    JSON    Prefer=return=representation

    create EHR and commit a composition for versioned composition tests

    get versioned composition of EHR by UID    ${versioned_object_uid}
    Status Should Be    200
    Should Be Equal As Strings    ${versioned_object_uid}    ${response.json()['uid']['value']}
    Should Be Equal As Strings    ${ehr_id}    ${response.json()['owner_id']['id']['value']}
    [Teardown]    Run Keywords      (admin) delete ehr      AND     (admin) delete all OPTs


2. Get Versioned Composition Of Existing EHR With Two Status Versions (JSON)

    # prepare new request session    JSON    Prefer=return=representation

    create EHR and commit a composition for versioned composition tests

    update a composition for versioned composition tests

    get versioned composition of EHR by UID    ${versioned_object_uid}
    Status Should Be    200
    Should Be Equal As Strings    ${versioned_object_uid}    ${response.json()['uid']['value']}
    Should Be Equal As Strings    ${ehr_id}    ${response.json()['owner_id']['id']['value']}
    [Teardown]    Run Keywords      (admin) delete ehr      AND     (admin) delete all OPTs


3. Get Versioned Composition Of Non-Existing EHR (JSON)

    create EHR and commit a composition for versioned composition tests

    (admin) delete ehr
    create fake EHR

    get versioned composition of EHR by UID    ${versioned_object_uid}
    Status Should Be    404
    [Teardown]    (admin) delete all OPTs


4. Get Versioned Composition Of Invalid EHR_ID (JSON)

    create EHR and commit a composition for versioned composition tests
    (admin) delete ehr
    Set Test Variable    ${ehr_id}    foobar

    get versioned composition of EHR by UID    ${versioned_object_uid}
    Status Should Be    404
    [Teardown]    (admin) delete all OPTs



5. Get Versioned Composition Of Non-Existing Composition (JSON)

    create EHR and commit a composition for versioned composition tests
    (admin) delete ehr
    create fake composition

    get versioned composition of EHR by UID    ${versioned_object_uid}
    Status Should Be    404
    [Teardown]    (admin) delete all OPTs


6. Get Versioned Composition Of Invalid Composition ID (JSON)

    create EHR and commit a composition for versioned composition tests

    Set Test Variable    ${versioned_object_uid}    foobar

    get versioned composition of EHR by UID    ${versioned_object_uid}
    Status Should Be    404
    [Teardown]    Run Keywords      (admin) delete ehr      AND     (admin) delete all OPTs

