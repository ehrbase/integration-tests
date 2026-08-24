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

Metadata        TOP_TEST_SUITE    ADMIN_COMPOSITION

Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot
Resource        ../_resources/keywords/composition_keywords.robot

Suite Setup     Set Library Search Order For Tests

Force Tags     ADMIN_composition


*** Variables ***
${SUT}          ADMIN-TEST    # overriding defaults in suite_settings.robot


*** Test Cases ***
001 ADMIN - Delete Composition
    Upload OPT    minimal/minimal_observation.opt
    prepare new request session    JSON    Prefer=return=representation
    create supernew ehr
    Set Test Variable  ${ehr_id}  ${response.json()['ehr_id']['value']}
    ehr_keywords.validate POST response - 201 created ehr
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    (admin) delete composition
    Log To Console  ${response}
    [Teardown]      (admin) delete ehr

002 ADMIN - Delete An Already Deleted Composition
    [Documentation]     1. Delete a composition via 'normal' endpoint \n\n
    ...                    (DELETE /ehr/${ehr_id}/composition/${uid}) \n\n
    ...                 2. Delete the same composition again via admin endpoint \n\n
    ...                    (DELETE /admin/ehr/${ehr_id}/composition/${versioned_object_uid} \n\n
    Upload OPT    minimal/minimal_admin.opt
    create new EHR (XML)
    commit composition (XML)    minimal/minimal_admin.composition.extdatetimes.xml
    delete composition    ${version_uid}
    (admin) delete composition
    Log To Console  ${response}
    [Teardown]      (admin) delete ehr

