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
Documentation       Composition Integration Tests
Metadata            TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Suite Setup     Set Library Search Order For Tests

Force Tags



*** Test Cases ***
Main flow has existing COMPOSITION (JSON)

    Upload OPT    minimal/minimal_observation.opt
    create EHR
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    get composition by composition_uid    ${version_uid}
    check composition exists

    #[Teardown]    restart SUT


Main flow has existing COMPOSITION and works without accept header

    Upload OPT    minimal/minimal_observation.opt
    create EHR
    commit composition without accept header    minimal/minimal_observation.composition.participations.extdatetimes.xml
    get composition by composition_uid    ${version_uid}
    check composition exists

    #[Teardown]    restart SUT


Get Composition After Update And Check Number Of Participations
    [Documentation]     Covers bug https://jira.vitagroup.ag/browse/CDR-647
    ...         - Upload OPT
    ...         - Create EHR
    ...         - Commit composition with 1 participation
    ...         - Update composition with the same content as in previous step
    ...         - Get composition by latest version id (::2 is this case)
    ...         - Check that returned composition contains only 1 participation
    Upload OPT    minimal/minimal_observation.opt
    create EHR
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    get composition by composition_uid    ${version_uid}
    update composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    Should Be Equal As Strings    ${response.status_code}    ${200}
    Set Test Variable  ${version_uid}  ${version_uid[0:-1]}2
    get version of versioned composition of EHR by UID    ${versioned_object_uid}    ${version_uid}
    Length Should Be    ${response.json()['data']['context']['participations']}    1
