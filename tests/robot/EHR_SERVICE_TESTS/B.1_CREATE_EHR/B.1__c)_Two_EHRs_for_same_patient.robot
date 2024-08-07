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
Metadata    Created    2020.01.30

Documentation   B.1.c) Alternative flow 2: Create two EHRs for the same patient
Metadata        TOP_TEST_SUITE    EHR_SERVICE

Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

# Suite Setup  startup SUT
# Suite Teardown  shutdown SUT

Force Tags    refactor



*** Test Cases ***
Create Same EHR Twice For The Same Patient (JSON)

    prepare new request session    JSON

    generate random subject_id
    create new EHR for subject_id (JSON)    ${subject_id}
    Status Should Be    201
    Get EHR ID From Location Headers
    create new EHR for subject_id (JSON)    ${subject_id}

    verify response
    [Teardown]      (admin) delete ehr


*** Keywords ***
verify response
    Status Should Be    409

    # TODO: response should indicate a conflict with an already existing EHR with the same subject id, namespace pair.

Get EHR ID From Location Headers
    [Documentation]     {response} is the variable set after POST or PUT EHR calls
    ...                 Set as test var ${ehr_id} from Location key located in response.headers
    @{location_split}     Split String      ${response.headers['Location']}     /
    Set Test Variable     ${ehr_id}         ${location_split}[-1]
