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
Metadata    Authors    *Wladislaw Wagner*, *Jake Smolka*
Metadata    Created    2020.09.01

Metadata        TOP_TEST_SUITE    ADMIN_DIRECTORY

Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot
Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/directory_keywords.robot

Suite Setup     Set Library Search Order For Tests

Force Tags     ADMIN_directory


*** Variables ***
${SUT}          ADMIN-TEST    # overriding defaults in suite_settings.robot


*** Test Cases ***
ADMIN - Delete Directory
    Upload OPT    minimal/minimal_evaluation.opt
    prepare new request session    JSON    Prefer=return=representation
    create supernew ehr
    Set Test Variable  ${ehr_id}  ${response.json()['ehr_id']['value']}
    ehr_keywords.validate POST response - 201 created ehr
    create DIRECTORY (JSON)    subfolders_in_directory.json
    ${versioned_uid}=   Fetch From Left  ${version_uid}  ::
    Set Test Variable  ${folder_versioned_uid}  ${versioned_uid}
    (admin) delete directory
    Log To Console  ${response}
    [Teardown]      (admin) delete ehr