*** Settings ***
Documentation	CHECK AGGREGATE FUNCTIONS MIN ON DV_ORDERED IN AQL
...		- Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/AGGREGATE_FUNCTIONS.md#min-on-dv_ordered
...     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition.
...     - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.

Resource	../../../_resources/keywords/aql_keywords.robot

Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/aggregate_functions/combinations/min_on_dv_ordered.csv
...     dialect=excel

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL


*** Test Cases ***
SELECT MIN(${path}) FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0]
    [Template]      Execute Query
    ${path}    ${expected_file}


*** Keywords ***
Precondition
    Upload OPT For AQL      	conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL  conformance_ehrbase.de.v0_max_v3.json

Execute Query
    [Arguments]     ${path}     ${expected_file}
   	${query}    Set Variable    SELECT MIN(${path}) FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0]
    Set AQL And Execute Ad Hoc Query    ${query}

    ${expected_result}	Set Variable	${EXPECTED_JSON_DATA_SETS}/aggregate_functions/${expected_file}
    ${exclude_paths}    Create List		root['meta']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}
    ...		ignore_string_case=${TRUE}

    Should Be Empty    ${diff}    msg=DIFF DETECTED!