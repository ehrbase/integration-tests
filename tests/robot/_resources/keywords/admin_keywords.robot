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
Documentation   ADMIN Keywords
Resource        ../suite_settings.robot
Resource        template_opt1.4_keywords.robot



*** Keywords ***
(admin) delete ehr
    [Documentation]     Admin delete of EHR record with a given ehr_id.
    ...                 DEPENDENCY: `prepare new request session`
    [Arguments]         ${multitenancy_token}=${None}
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary     ${headers}    Authorization=Bearer ${multitenancy_token}
    ELSE IF     ('${AUTH_TYPE}' == 'BASIC' or '${AUTH_TYPE}' == 'OAUTH') and '${multitenancy_token}' == '${None}'
        Set To Dictionary       ${headers}      &{authorization}
    END
    Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
                        ...     verify=False    #auth=${CREDENTIALS}
    ${resp}     DELETE On session     ${SUT}    /ehr/${ehr_id}
    ...         expected_status=anything    headers=${headers}
                Set Test Variable   ${response}     ${resp}
                Should Be Equal     ${resp.status_code}      ${204}


(admin) update OPT
    [Arguments]         ${opt_file}    ${prefer_return}=representation
    [Documentation]     Updates OPT via admin endpoint admin_baseurl/template/${template_id} \n\n

                        get valid OPT file    ${opt_file}
    
    &{headers}=         Create Dictionary    &{EMPTY}
                        Set To Dictionary    ${headers}
                        ...                  Content-Type=application/xml
                        ...                  Accept=application/xml
                        ...                  Prefer=return=${prefer_return}

                        Create Session       ${SUT}    ${ADMIN_BASEURL}    debug=2
                        ...                  verify=True    #auth=${CREDENTIALS}

    ${resp}=            PUT On Session    ${SUT}    /template/${template_id}   expected_status=anything
                        ...    data=${file}    headers=${headers}
                        Set Test Variable    ${response}    ${resp}
                        Set Test Variable    ${prefer_return}    ${prefer_return}


(admin) delete OPT
    [Arguments]         ${prefer_return}=representation
    [Documentation]     Admin delete OPT on server.
    ...                 Depends on any KW that exposes an variable named 'template_id'
    ...                 to test or suite level scope. \n\n
    ...                 valid values for 'prefer_return': \n\n\
    ...                 - representation (default) \n\n
    ...                 - minimal
                        prepare new request session
                        ...    Prefer=return=${prefer_return}
                        Set Test Variable    ${prefer_return}    ${prefer_return}
						Create Session       ${SUT}    ${ADMIN_BASEURL}    debug=2
                        ...                  verify=True	#auth=${CREDENTIALS}
    ${resp}             DELETE On Session   ${SUT}  /template/${template_id}
                        ...     expected_status=anything    headers=${headers}
                        Set Test Variable    ${response}    ${resp}

(admin) delete all OPTs
    [Documentation]     Admin delete OPT on server.
    ...                 Depends on any KW that exposes an variable named 'template_id'
    ...                 to test or suite level scope.
                        prepare new request session
   Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
    ...     verify=False    #auth=${CREDENTIALS}
   ${resp}              DELETE On Session   ${SUT}  /template/all
                        ...     expected_status=anything    headers=${headers}
                        Set Test Variable    ${response}    ${resp}


(admin) delete composition
    [Documentation]     Admin delete of Composition.
    ...                 Needs `${versioned_object_uid}` var from e.g. `commit composition (JSON)` KW.
    [Arguments]         ${multitenancy_token}=${None}

    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary     ${headers}    Authorization=Bearer ${multitenancy_token}
    ELSE IF     ('${AUTH_TYPE}' == 'BASIC' or '${AUTH_TYPE}' == 'OAUTH') and '${multitenancy_token}' == '${None}'
        Set To Dictionary       ${headers}      &{authorization}
    END
    Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
                            ...     verify=False
    ${resp}         DELETE On Session   ${SUT}  /ehr/${ehr_id}/composition/${versioned_object_uid}
                    ...     expected_status=anything    headers=${headers}
                    Status Should Be    204
                    Set Test Variable    ${response}    ${resp}

(admin) delete stored query
    [Documentation]     Admin delete of Stored Query (by qualified_verion or qualified_verion/id).
    [Arguments]     ${qualif_name}
    IF      '${AUTH_TYPE}' == 'BASIC' or '${AUTH_TYPE}' == 'OAUTH'
            Set To Dictionary       ${headers}      &{authorization}
    END
    Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
                            ...     verify=False
    ${resp}         DELETE On Session   ${SUT}  /query/${qualif_name}
                    ...     expected_status=anything    headers=${headers}
                    Status Should Be    200
                    Set Test Variable   ${response}     ${resp}

Delete Composition Using API
    IF      '${versioned_object_uid}' != '${None}'
        Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
                            ...     verify=False
        ${resp}         DELETE On Session   ${SUT}  /ehr/${ehr_id}/composition/${versioned_object_uid}
                        ...     expected_status=anything    headers=${headers}
                        ${isDeleteCompositionFailed}     Run Keyword And Return Status
                        ...     Status Should Be    204
                        Set Suite Variable    ${deleteCompositionResponse}    ${resp}
                        IF      ${isDeleteCompositionFailed} == ${FALSE} and '${resp.status_code}' == '404'
                            Log     Delete Composition returned ${deleteCompositionResponse.status_code} code.   console=yes
                        END
    END


Delete Template Using API
    Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
                        ...     verify=False
    ${resp}=            DELETE On Session   ${SUT}  /template/${template_id}
                        ...     expected_status=anything    headers=${headers}
                        Set Suite Variable    ${deleteTemplateResponse}    ${resp}
                        ${isDeleteTemplateFailed}     Run Keyword And Return Status
                        ...     Status Should Be    200
                        IF      ${isDeleteTemplateFailed} == ${FALSE} and '${resp.status_code}' == '404'
                            Log     Delete Template returned ${resp.status_code} code.   console=yes
                        END
                        #Delete All Sessions


check composition admin delete table counts
    Connect With DB

    ${contr_records}=   Count Rows In DB Table    ehr.contribution
                        # Should Be Equal As Integers    ${contr_records}     ${1}    # from creation of the EHR, which will not be deleted
    ${audit_records}=   Count Rows In DB Table    ehr.audit_details
                        # Should Be Equal As Integers    ${audit_records}     ${2}    # from creation of the EHR (1 for status, 1 for the wrapping contribution)
    ${compo_records}=   Count Rows In DB Table    ehr.composition
                        Should Be Equal As Integers    ${compo_records}     ${0}
    ${compo_h_records}=  Count Rows In DB Table    ehr.composition_history
                        Should Be Equal As Integers    ${compo_h_records}     ${0}
    ${entry_records}=   Count Rows In DB Table    ehr.entry
                        Should Be Equal As Integers    ${entry_records}     ${0}
    ${entry_h_records}=  Count Rows In DB Table    ehr.entry_history
                        Should Be Equal As Integers    ${entry_h_records}     ${0}
    ${event_context_records}=   Count Rows In DB Table    ehr.event_context
                        Should Be Equal As Integers    ${event_context_records}     ${0}
    ${entry_participation_records}=   Count Rows In DB Table    ehr.participation
                        Should Be Equal As Integers    ${entry_participation_records}     ${0}


(admin) delete contribution
    [Documentation]     Admin delete of Contribution.
    ...                 Needs `${contribution_uid}` var from e.g. `commit CONTRIBUTION (JSON)` KW.
    Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2
                        ...     verify=False
    ${resp}=            DELETE On Session   ${SUT}  /ehr/${ehr_id}/contribution/${contribution_uid}
                        ...     expected_status=anything    headers=${headers}
                        Set Test Variable   ${response}     ${resp}
                        Should Be Equal     ${response.status_code}     ${204}


(admin) delete directory
    [Documentation]     Admin delete of Directory.
    ...                 Needs manually created `${folder_versioned_uid}`.
    Create Session       ${SUT}    ${ADMIN_BASEURL}    debug=2
                        ...                  verify=True	#auth=${CREDENTIALS}
    ${resp}=            DELETE On Session   ${SUT}  /ehr/${ehr_id}/directory/${folder_versioned_uid}
                        ...     expected_status=anything    headers=${headers}
                        Status Should Be    204
                        Set Test Variable    ${response}    ${resp}
