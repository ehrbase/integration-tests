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
Documentation   Composition Integration Tests
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

Force Tags



*** Test Cases ***
1. Main flow delete event COMPOSITION

    Upload OPT    minimal/minimal_observation.opt

    create EHR

    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    check content of composition (JSON)

    delete composition    ${preceding_version_uid}

    @{split_compo_uid}      Split String        ${del_version_uid}      ::
    Set Suite Variable      ${system_id_with_tenant}    ${split_compo_uid}[1]
    ${short_compo_id}       Remove String       ${del_version_uid}      ::${system_id_with_tenant}::1
    Set Test Variable       ${del_version_uid}      ${short_compo_id}
    get deleted composition

    [Teardown]    Run Keywords      (admin) delete ehr      AND     (admin) delete all OPTs

2. Create Update Delete Composition And Check Time Committed
    [Documentation]     Covers bug https://vitagroup-ag.atlassian.net/browse/CDR-2181
    Upload OPT    minimal/minimal_observation.opt

    create EHR

    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    check content of composition (JSON)
    get composition - latest version    JSON
    Set Test Variable   ${create_compo_commit_audit_datetime}     ${response.json()['commit_audit']['time_committed']['value']}
    Should Be Equal     ${response.json()['commit_audit']['change_type']['value']}   creation
    Sleep   0.5s
    update composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.v2.xml
    check content of updated composition (JSON)
    get composition - latest version    JSON
    Set Test Variable   ${update_compo_commit_audit_datetime}     ${response.json()['commit_audit']['time_committed']['value']}
    Should Be Equal     ${response.json()['commit_audit']['change_type']['value']}   modification
    Sleep   0.5s
    delete composition    ${composition_uid_v2}
    get composition - latest version    JSON
    Set Test Variable   ${delete_compo_commit_audit_datetime}     ${response.json()['commit_audit']['time_committed']['value']}
    Should Be Equal     ${response.json()['commit_audit']['change_type']['value']}   deleted
    Should Be True      '${create_compo_commit_audit_datetime}' != '${update_compo_commit_audit_datetime}'
    Should Be True      '${update_compo_commit_audit_datetime}' != '${delete_compo_commit_audit_datetime}'
    Should Be True      '${create_compo_commit_audit_datetime}' != '${delete_compo_commit_audit_datetime}'
    [Teardown]    Run Keywords      (admin) delete ehr      AND     (admin) delete all OPTs
