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
Metadata    Created    2019.03.03

Documentation   B.1.b) Alternative flow 1: Create same EHR twice
...
...             Flow:
...
...                 1. Invoke the create EHR service (for each item in the Data set with given ehr_id, data sets 9 to 16)
...                 2. The server should answer with a positive response associated to "EHR created"
...                 3. Invoke the create EHR service (for the same item as in 1.)
...                 4. The server should answer with a negative response, and that should be related with the EHR existence,
...                    like "EHR with ehr_id already exists"
...
...             Postconditions:
...                 A new EHR will exists in the system, the first one created, and be consistent with the data sets used.
...
Metadata        TOP_TEST_SUITE    EHR_SERVICE

Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

# Suite Setup    startup SUT
# Suite Teardown    shutdown SUT

Force Tags    refactor



*** Test Cases ***
Create Same EHR Twice (JSON)

    [Documentation]     Uses PUT method on /ehr/{{ehr_id}} endpoint to create new EHR.

    prepare new request session    JSON
    generate random ehr_id
    create new EHR by ID        ${ehr_id}
    Status Should Be    201

    create new EHR by ID        ${ehr_id}
    server complains about already existing ehr_id
    [Teardown]      (admin) delete ehr


Create Same EHR Twice (XML)

    [Documentation]     Uses PUT method on /ehr/{{ehr_id}} endpoint to create new EHR.

    prepare new request session    XML
    generate random ehr_id
    create new EHR by ID        ${ehr_id}
    Status Should Be    201

    create new EHR by ID        ${ehr_id}
    server complains about already existing ehr_id
    [Teardown]      (admin) delete ehr



*** Keywords ***
server complains about already existing ehr_id
    # Log To Console      ${response}
    # Log To Console      ${response.status}
    Status Should Be    409
    
    # String    response body error    EHR with this ID already exists
    # TODO: create separate checks for JSON/XML responses
