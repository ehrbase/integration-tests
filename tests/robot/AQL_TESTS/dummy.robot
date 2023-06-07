#*** Settings ***
#Documentation   DUMMY TEST SUITE FOR AQL CHECKS
#Library     OperatingSystem
#Library     String
#Library     Collections
#Library     DataDriver      file=${CURDIR}\\dummy_test_data.csv   dialect=excel
#
#*** Test Cases ***
#Execute Query With Selected [${path}] And Expected [${expected}]
#    [Template]      Execute Query
#    ${path}     ${expected}
#
#
#*** Keywords ***
#Execute Query
#    [Arguments]     ${path}     ${expected}
#    ${actual}   Set Variable    expected_name
#    ${query_to_apply}   Set Variable    SELECT ${path} FROM EHR e CONTAINS COMPOSITION c [openEHR-EHR-COMPOSITION.conformance_composition_.v0]
#    log     ${query_to_apply}
#    IF      '${expected}' != '${actual}'
#        Fail
#    END

*** Settings ***
Documentation   DUMMY TEST SUITE FOR AQL CHECKS
Resource    ../_resources/keywords/aql_keywords.robot
Library     OperatingSystem
Library     String
Library     Collections
Library     DataDriver
...         file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/dummy_test_data_temp.csv
...         dialect=excel
#...         file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/dummy_test_data.csv
#...         dialect=excel


#robot -d .\results --noncritical not-ready robot\AQL_TESTS\dummy.robot
*** Test Cases ***
Execute Query With Selected [${path}] And Expected [${expected}]
    [Tags]      not-ready
    [Template]      Execute Query
    ${path}     ${expected}


*** Keywords ***
Execute Query
    [Arguments]     ${path}     ${expected}
    Execute Ad Hoc Query    ${path}     ${expected}