# Copyright (c) 2023 Vladislav Ploaia (Vitagroup - CDR CORE Team)
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
Library    Collections
Library    String

Resource    ../suite_settings.robot


*** Variables ***
${ELASTICSEARCHURL}          http://localhost:9200


*** Keywords ***
Create Session Elastic Search
    Create Session      elasticsearch_session    ${ELASTICSEARCHURL}
    ...     debug=2     verify=True

Get Logstash Content And Store In Json
    Generate Logstash ID
    &{params}       Create Dictionary       pretty=${EMPTY}
    ${resp}         Get On Session     elasticsearch_session
                    ...     ${logstash_id}/_search
                    ...     params=${params}
                    ...     expected_status=anything
                    Set Test Variable       ${response}         ${resp}
                    Should Be Equal As Strings      ${resp.status_code}     ${200}
                    Set Test Variable       ${json_resp}        ${resp.json()}
                    Set Test Variable       ${total_hits}       ${json_resp['hits']['total']['value']}
                    Log     ${json_resp}
                    Should Be True     ${json_resp['hits']['total']['value']} > 0   There are no records.
                    #Log     ${json_resp['hits']['hits'][0]}

Generate Logstash ID
    ${now}      Evaluate    datetime.datetime.now().strftime('%Y.%m.%d')
    Set Suite Variable      ${logstash_id}    logstash-${now}-000001
