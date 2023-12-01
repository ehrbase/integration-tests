*** Settings ***
Documentation   Queries provided by Medblocks Team
...         - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Compositions
...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
Resource        ../../_resources/keywords/aql_keywords.robot

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL    #enable this keyword if AQL checks are passing !!!


*** Variables ***
${EXPECTED_JSON_RESULTS}    ${EXPECTED_JSON_DATA_SETS}/external/test_set_3


*** Test Cases ***
SELECT c/items[at0001]/value/value, o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude, o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude FROM EHR e CONTAINS COMPOSITION C[openEHR-EHR-COMPOSITION.encounter.v1] CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.blood_pressure.v2] CONTAINS CLUSTER c[openEHR-EHR-CLUSTER.device.v1]
    ${query}    Set Variable    SELECT c/items[at0001]/value/value, o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude, o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude FROM EHR e CONTAINS COMPOSITION C[openEHR-EHR-COMPOSITION.encounter.v1] CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.blood_pressure.v2] CONTAINS CLUSTER c[openEHR-EHR-CLUSTER.device.v1]
    ${expected_result}      Set Variable    ${EXPECTED_JSON_RESULTS}/expected_composition_x_observation_x_cluster_x.json
    Execute Query   query=${query}    expected_rows_nr=10
    ...     expected_file=${expected_result}

SELECT C/items[at0001]/value/value, o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude, o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.blood_pressure.v2] CONTAINS CLUSTER C[openEHR-EHR-CLUSTER.device.v1]
    ${query}    Set Variable    SELECT C/items[at0001]/value/value, o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude, o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.blood_pressure.v2] CONTAINS CLUSTER C[openEHR-EHR-CLUSTER.device.v1]
    ${expected_result}      Set Variable    ${EXPECTED_JSON_RESULTS}/expected_observation_x_cluster_x_bp_device.json
    Execute Query   query=${query}    expected_rows_nr=10
    ...     expected_file=${expected_result}



*** Keywords ***
Precondition
    Upload OPT For AQL      external/ehrbase.testcase06.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo1_test_set_3_flat.json
    Set Suite Variable       ${c_uid1}      ${composition_short_uid}
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo2_test_set_3_flat.json
    Set Suite Variable       ${c_uid2}      ${composition_short_uid}
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo3_test_set_3_flat.json
    Set Suite Variable       ${c_uid3}      ${composition_short_uid}
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo4_no_obs_cluster_test_set_3_flat.json
    Set Suite Variable       ${c_uid4}      ${composition_short_uid}
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo5_no_action_cluster_test_set_3_flat.json
    Set Suite Variable       ${c_uid5}      ${composition_short_uid}
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo6_no_evaluation_cluster_test_set_3_flat.json
    Set Suite Variable       ${c_uid6}      ${composition_short_uid}
    Commit Composition For AQL      external/ehrbase.testcase06.v0__compo7_no_instruction_cluster_test_set_3_flat.json
    Set Suite Variable       ${c_uid7}      ${composition_short_uid}

Execute Query
    [Arguments]     ${query}    ${expected_rows_nr}    ${expected_file}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Set AQL And Execute Ad Hoc Query    ${query}
    Log     ${resp_body['rows']}
    #Length Should Be    ${resp_body['rows']}     ${expected_rows_nr}
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_file}
    ...     ignore_order=${ignore_order}    ignore_string_case=${ignore_string_case}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
