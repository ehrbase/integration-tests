*** Settings ***
Documentation   Test suite to check Swagger EHRBase API availability.
...             \nCovers https://vitagroup-ag.atlassian.net/browse/CDR-1429
Resource    ${EXECDIR}/robot/_resources/suite_settings.robot
Suite Setup 		Set Library Search Order For Tests


*** Variables ***
${api_docs_version_part}     /v3/api-docs


*** Test Cases ***
1. Check Swagger Main Page Availability
    ${temp_str}     Remove String       ${BASEURL}      /rest/openehr/v1
    Set Suite Variable      ${BASEURL}      ${temp_str}
    Create Session      ${SUT}      ${BASEURL}    verify=True
    ${resp}     GET On Session      ${SUT}      /swagger-ui/index.html    expected_status=anything
                Status Should Be    200     ${resp}

2. Check Swagger openEHR API Availability
    ${resp}     GET On Session      ${SUT}      ${api_docs_version_part}/1. openEHR API     expected_status=anything
                Status Should Be    200     ${resp}
                Dictionary Should Contain Key     ${resp.json()}    paths
                Set Test Variable       ${resp_json_paths}      ${resp.json()['paths']}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/ehr/{ehr_id}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/query/aql
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/definition/query/{qualified_query_name}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/definition/template/adl1.4
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/ehr/{ehr_id}/versioned_composition/{versioned_object_uid}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/ehr/{ehr_id}/ehr_status/{version_uid}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/ehr/{ehr_id}/directory/{version_uid}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/ehr/{ehr_id}/contribution/{contribution_uid}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/definition/template/adl1.4/{template_id}/example
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/openehr/v1/definition/query

3. Check Swagger EHRbase Status Endpoint
    ${resp}     GET On Session      ${SUT}      ${api_docs_version_part}/2. EHRbase Status Endpoint    expected_status=anything
                Status Should Be    200     ${resp}
                Dictionary Should Contain Key     ${resp.json()}    paths
                Dictionary Should Contain Key     ${resp.json()['paths']}    /rest/status

4. Check Swagger EHRbase Admin API
    ${resp}     GET On Session      ${SUT}      ${api_docs_version_part}/3. EHRbase Admin API    expected_status=anything
                Status Should Be    200     ${resp}
                Dictionary Should Contain Key     ${resp.json()}    paths
                Set Test Variable       ${resp_json_paths}      ${resp.json()['paths']}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/template/{template_id}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/ehr/{ehr_id}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/ehr/{ehr_id}/contribution/{contribution_id}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/status
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/template/all
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/query/{qualified_query_name}/{version}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/ehr/{ehr_id}/directory/{directory_id}
                Dictionary Should Contain Key     ${resp_json_paths}    /rest/admin/ehr/{ehr_id}/composition/{composition_id}

5. Check Swagger Management API
    ${resp}     GET On Session      ${SUT}      ${api_docs_version_part}/4. Management API    expected_status=anything
                Status Should Be    200     ${resp}
