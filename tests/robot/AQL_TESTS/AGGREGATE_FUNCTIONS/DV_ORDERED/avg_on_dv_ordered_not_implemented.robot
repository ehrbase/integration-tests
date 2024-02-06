*** Settings ***
Documentation	CHECK AGGREGATE FUNCTIONS AVG NOT IMPLEMENTED ON DV_ORDERED IN AQL
...		- Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/AGGREGATE_FUNCTIONS.md#avg-on-dv-ordered

Resource	../../../_resources/keywords/aql_keywords.robot

Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/aggregate_functions/combinations/all_dv_ordered_types.csv
...     dialect=excel


*** Test Cases ***
Not Implemented ${type} AVG(${path})
    [Template]      Execute Query
    ${type}		${path}

*** Keywords ***
Execute Query
    [Arguments]		${type}		${path}
   	${query}    Set Variable    SELECT AVG(${path}) FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0]
    Set AQL And Execute Ad Hoc Query    ${query}
    Fail 	Implement proper test after AVG(${type}) is supported
