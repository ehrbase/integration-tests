*** Settings ***
Documentation   ORDER BY - SINGLE ORDER BY - ORDER by unknown type
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/ORDER_BY_SUIT.md#order-by-unknown-type

Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/order_by/combinations/order_by_unknown_type.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL    ${ehr_id}


*** Test Cases ***
SELECT o/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/value, o/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude FROM OBSERVATION o [openEHR-EHR-OBSERVATION.choice.v0] ORDER BY ${path} ASC
    #[Tags]      not-ready
    [Template]      Execute Query
    ${query_nr}     ${path}     ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Upload OPT For AQL      choice_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      choice_ehrbase.de.v0.json
    Set Suite Variable      ${c_uid1}      ${composition_short_uid}

Execute Query
    [Arguments]     ${query_nr}     ${path}     ${expected_file}    ${nr_of_results}
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT o/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/value, o/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude FROM OBSERVATION o [openEHR-EHR-OBSERVATION.choice.v0] ORDER BY ${path} ASC
    Log     ${query_dict["tmp_query"]}
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    IF      ${query_nr} == ${2}
        Checks For Second Third Query
        ...     original_file=expected_order_by_unknown_type_at4_1.json
        ...     json_path=$..rows[?(@[0] != null)]
        ...     expected_file=expected_order_by_unknown_type_at4_1_part_expected.json
    END

    IF      ${query_nr} == ${3}
        Checks For Second Third Query
        ...     original_file=expected_order_by_unknown_type_at4_2.json
        ...     json_path=$..rows[?(@[1] != null)]
        ...     expected_file=expected_order_by_unknown_type_at4_2_part_expected.json
    END

Checks For Second Third Query
    [Arguments]     ${original_file}    ${json_path}    ${expected_file}
    ${expected_res_tmp}     Set Variable
    ...     ${EXPECTED_JSON_DATA_SETS}/order_by/${original_file}
    ${json_obj}         Load Json From File        ${expected_res_tmp}
    ${json_obj_tmp}     Get Value From Json	    ${json_obj}	    ${json_path}
    #Log     Without null at first column: ${json_obj_tmp}
    ${json_obj_tmp2}      Update Value To Json      ${json_obj}	    $.rows	    ${json_obj_tmp}
    #Log     Final JSON ${json_obj_tmp2}
    ${json_str}     Convert Json To String      ${json_obj_tmp2}
    ${diff}     compare json-string with json-file
    ...     ${json_str}     ${EXPECTED_JSON_DATA_SETS}/order_by/${expected_file}
    ...     ignore_order=${FALSE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!

#Execute Query
#    [Arguments]     ${query_nr}     ${path}     ${expected_file}    ${nr_of_results}
#    ${query_dict}   Create Dictionary
#    ...     tmp_query=SELECT o/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/value, o/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude FROM OBSERVATION o [openEHR-EHR-OBSERVATION.choice.v0] ORDER BY ${path} ASC
#    Log     ${query_dict["tmp_query"]}
#    ${query}    Set Variable    ${query_dict["tmp_query"]}
#    Log     ${query}
#    Set AQL And Execute Ad Hoc Query    ${query}
#    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/order_by/${expected_file}
#    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
#    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
#    Log     Expected data: ${data_replaced_vars}
#    Create File     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_unknown_type_tmp.json
#    ...     ${data_replaced_vars}
#    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
#    ${diff}     compare json-string with json-file
#    ...     ${resp_body_actual}     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_unknown_type_tmp.json
#    ...     ignore_order=${FALSE}    ignore_string_case=${TRUE}
#    Should Be Empty    ${diff}    msg=DIFF DETECTED!
#    [Teardown]      Remove File     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_unknown_type_tmp.json