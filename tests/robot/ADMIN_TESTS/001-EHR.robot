# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Jake Smolka (Hannover Medical School).
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
Metadata    Authors    *Jake Smolka*, *Wladislaw Wagner*  
Metadata    Created    2020.09.01

Metadata        TOP_TEST_SUITE    ADMIN_EHR

Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/db_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot
Resource        ../_resources/keywords/directory_keywords.robot
Resource        ../_resources/keywords/composition_keywords.robot

Suite Setup     Run Keywords
                ...     Set Library Search Order For Tests      AND
                ...     Log all env variables

Force Tags     ADMIN_ehr


*** Variables ***
${SUT}          ADMIN-TEST    # overriding defaults in suite_settings.robot


*** Test Cases ***
ADMIN - Delete EHR
    prepare new request session    JSON    Prefer=return=representation
    create supernew ehr
    Set Test Variable  ${ehr_id}  ${response.json()['ehr_id']['value']}
    ehr_keywords.validate POST response - 201 created ehr
    [Teardown]      (admin) delete ehr

ADMIN - Delete EHR with composition
    Upload OPT    minimal/minimal_observation.opt
    prepare new request session    JSON    Prefer=return=representation
    create supernew ehr
    Set Test Variable  ${ehr_id}  ${response.json()['ehr_id']['value']}
    ehr_keywords.validate POST response - 201 created ehr
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    [Teardown]      (admin) delete ehr

ADMIN - Delete EHR with two compositions
    Upload OPT    minimal/minimal_observation.opt
    prepare new request session    JSON    Prefer=return=representation
    create supernew ehr
    Set Test Variable  ${ehr_id}  ${response.json()['ehr_id']['value']}
    ehr_keywords.validate POST response - 201 created ehr
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    [Teardown]      (admin) delete ehr

ADMIN - Delete EHR with directory
    Upload OPT    minimal/minimal_observation.opt
    prepare new request session    JSON    Prefer=return=representation
    create supernew ehr
    Set Test Variable  ${ehr_id}  ${response.json()['ehr_id']['value']}
    ehr_keywords.validate POST response - 201 created ehr
    create DIRECTORY (JSON)    subfolders_in_directory.json
    [Teardown]      (admin) delete ehr


*** Keywords ***
Log all env variables
    ${allvars}=     Log Variables
