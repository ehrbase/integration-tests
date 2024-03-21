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
Documentation   Composition Integration Tests
...             https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/EHR_COMPOSITION.md#b6a-main-flow-create-new-event-composition
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot

Suite Setup       Precondition
#Suite Teardown  restart SUT


*** Test Cases ***
Main flow create new event COMPOSITION CANONICAL_JSON
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    check the successful result of commit composition

Main flow create new event COMPOSITION CANONICAL_XML
    commit composition   format=CANONICAL_XML
    ...                  composition=nested.en.v1__full_without_links.xml
    check the successful result of commit composition

Main flow create new event COMPOSITION FLAT
    commit composition   format=FLAT
    ...                  composition=nested.en.v1__full.xml.flat.json
    check the successful result of commit composition   nesting
    [Teardown]      Run Keywords    (admin) delete ehr      AND     (admin) delete all OPTs

Alternative flow create COMPOSITION After Delete And Upload Template
    [Documentation]     Bug CDR-1174 fixed and closed.
    ...     \n*Flow:*
    ...     - Upload OPT: nested/nested.en.tmp.v1.opt
    ...     - Create EHR
    ...     - Delete uploaded OPT using ADMIN endpoint and expect 200
    ...     - Upload the same OPT
    ...     - Commit Composition and expect 201
    ${template_file}    Set Variable        nested/nested.en.tmp.v1.opt
    Set Test Variable   ${template_id}      nested.en.tmp.v1
    Upload OPT      ${template_file}
    create EHR
    (admin) delete OPT
    Status Should Be    200
    Upload OPT      ${template_file}
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.tmp.v1__full_without_links.json
    Status Should Be    201
    [Teardown]      Run Keywords    (admin) delete OPT      AND
                    ...     (admin) delete ehr      AND     (admin) delete all OPTs

# Main flow create new event COMPOSITION TDD
#     [Tags]    future
#     commit composition   format=TDD
#     ...                  composition=nested.en.v1__full.xml
#     check the successful result of commit composition

# Main flow create new event COMPOSITION STRUCTURED
#     [Tags]    future
#     commit composition   format=STRUCTURED
#     ...                  composition=nested.en.v1__full.json
#     check the successful result of commit composition   nesting


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT    nested/nested.opt
    create EHR