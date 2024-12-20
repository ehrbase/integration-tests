# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Pablo Pazos (Hannover Medical School),
# Nataliya Flusman (Solit Clouds), Nikita Danilin (Solit Clouds)
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
Documentation   Sanity Integration Tests
...             https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/EHR_COMPOSITION.md#b6a-main-flow-create-new-event-composition

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/aql_query_keywords.robot
Resource        ../_resources/keywords/directory_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot

Suite Setup     Precondition
#Suite Teardown  restart SUT

*** Variables ***
${VALID EHR DATA SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/valid


*** Test Cases ***
Main flow Sanity Tests for FLAT Compositions
    create EHR
    Get Web Template By Template Id (ECIS)  ${template_id}
    commit composition   format=FLAT
    ...                  composition=family_history__.json
    check the successful result of commit composition
    (FLAT) get composition by composition_uid    ${composition_uid}
    Get Web Template By Template Id (ECIS)  ${template_id}
    (FLAT) get composition by composition_uid    ${composition_uid}
    Update Composition (FLAT)  family_history.v2__.json
    (FLAT) get composition by composition_uid    ${composition_uid}
    check composition exists

    ${composition_uid_short}=  Fetch From Left  ${composition_uid}  :
    Replace Uid With Actual  robot/_resources/test_data_sets/directory/empty_directory_items.json  ${composition_uid_short}  robot/_resources/test_data_sets/directory/empty_directory_items_uid_replaced.json
    create DIRECTORY (JSON)    empty_directory_items_uid_replaced.json
    Should Be Equal As Strings    ${response.status_code}    201
    Set Test Variable   ${preceding_version_uid}    ${preceding_version_uid}
    remove File  robot/_resources/test_data_sets/directory/empty_directory_items_uid_replaced.json

    #execute ad-hoc query    B/102_get_compositions_orderby_name.json
    #check response: is positive
    Set Variable With Short Compo Id And Delete Composition     ${composition_uid_short}
    delete DIRECTORY (JSON)
    Status Should Be    204

    (admin) delete ehr
    #[Teardown]    restart SUT


Main flow Sanity Tests for Canonical JSON Compositions
    #create EHR
    Create EHR For Sanity Flow
    Get Web Template By Template Id (ECIS)  ${template_id}
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    check the successful result of commit composition
    get composition by composition_uid    ${composition_uid}
    check composition exists
    ${version_uid_short}    Fetch From Left     ${composition_uid}      :
    Set Variable With Short Compo Id And Delete Composition     ${version_uid_short}
    prepare new request session    JSON    Prefer=return=representation
    commit composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    check content of composition (JSON)

    prepare new request session    JSON    Prefer=return=representation
    update composition (JSON)    minimal/minimal_observation.composition.participations.extdatetimes.v2.xml
    check content of updated composition (JSON)

    get composition by composition_uid    ${version_uid}
    check composition exists

    ${version_uid_short}=  Fetch From Left  ${version_uid}  :
    Replace Uid With Actual  robot/_resources/test_data_sets/directory/empty_directory_items.json  ${version_uid_short}  robot/_resources/test_data_sets/directory/empty_directory_items_uid_replaced.json
    create DIRECTORY (JSON)    empty_directory_items_uid_replaced.json
    Should Be Equal As Strings    ${response.status_code}    201
    Set Test Variable   ${preceding_version_uid}    ${preceding_version_uid}
    remove File  robot/_resources/test_data_sets/directory/empty_directory_items_uid_replaced.json

    #execute ad-hoc query    B/102_get_compositions_orderby_name.json
    #check response: is positive
    Set Variable With Short Compo Id And Delete Composition     ${version_uid_short}
    delete DIRECTORY (JSON)
    (admin) delete ehr
    #[Teardown]    restart SUT

Main flow Sanity Tests for Canonical XML Compositions
    #To remove not-ready tag when https://vitagroup-ag.atlassian.net/browse/CDR-1616 is merged
    #create EHR
    Create EHR For Sanity Flow
    Get Web Template By Template Id (ECIS)  ${template_id}
    commit composition   format=CANONICAL_XML
    ...                  composition=nested.en.v1__full_without_links.xml
    check the successful result of commit composition
    get composition by composition_uid    ${composition_uid}
    check composition exists

    ${version_uid_short}    Fetch From Left     ${composition_uid}      :
    Set Variable With Short Compo Id And Delete Composition     ${version_uid_short}
    prepare new request session    XML    Prefer=return=representation
    commit composition (XML)    minimal/minimal_observation.composition.participations.extdatetimes.xml
    check content of composition (XML)
    prepare new request session    XML    Prefer=return=representation
    update composition (XML)    minimal/minimal_observation.composition.participations.extdatetimes.v2.xml
    check content of updated composition (XML)

    get composition by composition_uid    ${version_uid}
    check composition exists
    ${version_uid_short}=  Fetch From Left  ${version_uid}  :
    Replace Uid With Actual  robot/_resources/test_data_sets/directory/empty_directory_items.json  ${version_uid_short}  robot/_resources/test_data_sets/directory/empty_directory_items_uid_replaced.json
    create DIRECTORY (JSON)    empty_directory_items_uid_replaced.json
    Should Be Equal As Strings    ${response.status_code}    201
    Set Test Variable   ${preceding_version_uid}    ${preceding_version_uid}
    remove File  robot/_resources/test_data_sets/directory/empty_directory_items_uid_replaced.json

    #execute ad-hoc query    B/102_get_compositions_orderby_name.json
    #check response: is positive
    Set Variable With Short Compo Id And Delete Composition     ${version_uid_short}
    delete DIRECTORY (JSON)
    ## Covers bug ticket https://vitagroup-ag.atlassian.net/browse/CDR-1616
    ## system.allow-template-overwrite: false
    Upload OPT      nested/nested.opt
    Should Be Equal As Strings      ${response_code}    409
    Should Contain  ${response.text}
    ...     Operational template with this template ID already exists: nested.en.v1
    [Teardown]      Run Keywords    (admin) delete ehr      AND     (admin) delete all OPTs


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT    all_types/family_history.opt
    Upload OPT    nested/nested.opt
    Upload OPT    minimal/minimal_observation.opt
    Extract Template Id From OPT File
    Create Session      ${SUT}    ${BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}

Set Variable With Short Compo Id And Delete Composition
    [Arguments]     ${short_compo_id}
    Set Test Variable       ${versioned_object_uid}
    ...     ${short_compo_id}
    Delete Composition Using API

Create EHR For Sanity Flow
    [Documentation]     Create EHR with EHR_Status and other details, so it can contain correct subject object.
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
