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
Documentation   ATNA Logs Tests

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot
Resource        ../_resources/keywords/atna_logs_keywords.robot


*** Variables ***
${VALID EHR DATA SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/valid


*** Test Cases ***
Create EHR And Check ATNA Logs
    [Tags]      not-ready
    create EHR
    Sleep   7s
    ###
    Create Session Elastic Search
    Get Logstash Content And Store In Json
    Set Suite Variable     ${total_hits_after_create_ehr}    ${total_hits}
    Get Logstash Last Result And Check Operation    operation_type=C

Get EHR And Check ATNA Logs
    [Tags]      not-ready
    retrieve EHR by ehr_id
    Sleep   7s
    Get Logstash Content And Store In Json
    Set Test Variable     ${total_hits_after_get_ehr}    ${total_hits}
    Should Be True        ${total_hits_after_get_ehr} > ${total_hits_after_create_ehr}
    Get Logstash Last Result And Check Operation    operation_type=R
    #######
    retrieve EHR by ehr_id
    Sleep   7s
    Get Logstash Content And Store In Json
    Set Test Variable     ${second_total_hits_after_get_ehr}    ${total_hits}
    Should Be True        ${second_total_hits_after_get_ehr} > ${total_hits_after_get_ehr}
    Get Logstash Last Result And Check Operation    operation_type=R