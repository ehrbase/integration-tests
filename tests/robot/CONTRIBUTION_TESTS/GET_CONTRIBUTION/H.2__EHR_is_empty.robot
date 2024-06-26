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
Documentation   Contribution Integration Tests
...
...     Alternative flow 1: get CONTRIBUTION on an empty EHR
...
...     Preconditions:
...         An EHR with known ehr_id exists and doesn't have any CONTRIBUTIONS.
...
...     Flow:
...         1. Invoke get CONTRIBUTION service by the existing ehr_id and a random CONTRIBUTION uid
...         2. The result should be negative, with a message similar to "the CONTRIBUTION uid doesn't exist for the EHR ehr_id"
...
...     Postconditions:
...         None
Metadata        TOP_TEST_SUITE    CONTRIBUTION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/contribution_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

#Suite Setup  startup SUT
# Test Setup  start openehr server
# Test Teardown  restore clean SUT state
#Suite Teardown  shutdown SUT

Force Tags



*** Test Cases ***
Alternative flow 1: get CONTRIBUTION on an empty EHR

    create EHR

    create fake CONTRIBUTION

    retrieve CONTRIBUTION by fake contri_uid (JSON)

    check response: is negative indicating non-existent contribution_uid on ehr_id
    [Teardown]    Run Keywords    (admin) delete ehr      AND     (admin) delete all OPTs
