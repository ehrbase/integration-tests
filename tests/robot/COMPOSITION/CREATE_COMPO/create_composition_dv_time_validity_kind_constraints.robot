*** Settings ***
Documentation   Composition Integration Tests
...             ${\n}*Test suite covering DV_TIME validity kind constraint*
...             ${\n}Restriction imposed by C_TIME pattern defined in Template (.opt file)
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/suite_settings.robot
Suite Setup     Set Library Search Order For Tests


*** Variables ***
${composition_file}     test_dv_time_contraint_v1__.json
${opt_reference_file}   all_types/test_dv_time_contraint_v1.opt
${opt_temp_file}        all_types/test_dv_time_contraint_v1__temp.opt
${positiveCode}         201
${negativeCode_422}     422
${negativeCode_400}     400


*** Test Cases ***
Test DV Time Validity Kind Constraints - C_TIME With Configured Pattern
    [Template]      Commit DV Time Validity Kind Constraints - C_TIME With Configured Pattern
    #C_TIME pattern value, DV_TIME value in COMPOSITION, expected code
    ## Positive cases
    HH:mm:ss        143015          ${positiveCode}
    HH:mm:ss        12:30:15.500    ${positiveCode}
    HH:mm:ss        12:30:25        ${positiveCode}
    HH:mm:ss        000000          ${positiveCode}
    ## Hours/Minutes/Seconds Boundary Violations
    HH:mm:ss        24:00:00   ${negativeCode_400}
    HH:mm:ss        25:30:15   ${negativeCode_400}
    HH:mm:ss        99:12:30   ${negativeCode_400}
    HH:mm:ss        12:60:00   ${negativeCode_400}
    HH:mm:ss        12:75:30   ${negativeCode_400}
    HH:mm:ss        12:30:60   ${negativeCode_400}
    HH:mm:ss        12:30:88   ${negativeCode_400}
    ## Separator and Format Violations
    HH:mm:ss        14-30-15    ${negativeCode_400}
    HH:mm:ss        14.30.15    ${negativeCode_400}
    HH:mm:ss        14/30/15    ${negativeCode_400}
    HH:mm:ss        06:01       ${negativeCode_422}
    HH:mm:ss        14:         ${negativeCode_400}
    HH:mm:ss        06          ${negativeCode_422}
    HH:mm:ss        0           ${negativeCode_400}
    ## Character & Padding Violations
    HH:mm:ss        14:30:AB    ${negativeCode_400}
    HH:mm:ss        dummystr    ${negativeCode_400}
    HH:mm:ss        9:30:15     ${negativeCode_400}
    HH:mm:ss        14:3:15     ${negativeCode_400}
    HH:mm:ss        14:30:5     ${negativeCode_400}

    ## Other C_TIME patterns
    HH:mm:??        12:30           ${positiveCode}
    HH:mm:??        12:30:45        ${positiveCode}
    HH:mm:XX        12:30           ${positiveCode}
    HH:mm:XX        12:30:45        ${negativeCode_422}
    HH:??:??        12              ${positiveCode}
    HH:??:??        12:18           ${positiveCode}
    HH:??:??        12:18:01        ${positiveCode}
    HH:??:??        12:18:01.356    ${positiveCode}
    HH:??:??        121801          ${positiveCode}
    HH:??:XX        12              ${positiveCode}
    HH:??:XX        12:23           ${positiveCode}
    HH:??:XX        1223            ${positiveCode}
    HH:??:XX        12:23:45        ${negativeCode_422}
    HH:??:XX        122345          ${negativeCode_422}
    HH:XX:XX        15              ${positiveCode}
    HH:XX:XX        1512            ${negativeCode_422}
    HH:XX:XX        15:24           ${negativeCode_422}
    HH:XX:XX        15:24:07        ${negativeCode_422}
    HH:XX:XX        152407          ${negativeCode_422}
    hh:MM:ss        03:13:18        ${positiveCode}
    HH:MM:ss        17:00:18        ${positiveCode}
    HH:MM:SS        21:59:59        ${positiveCode}


*** Keywords ***
Commit DV Time Validity Kind Constraints - C_TIME With Configured Pattern
    [Arguments]     ${c_time_pattern_opt_value}     ${dv_time_composition_value}
    ...             ${expectedCode}
    [Documentation]     C_TIME_PATTERN=${c_time_pattern_opt_value},
    ...     DV_TIME_VALUE=${dv_time_composition_value},
    ...     expectedCode=${expectedCode}
    Load XML File With OPT      ${opt_reference_file}
    ${returnedOptFile}   Change XML Value And Save Back To New OPT
    ...     ${xmlFileContent}
    ...     ${c_time_pattern_opt_value}
    Upload OPT      ${returnedOptFile}
    create EHR
    ${statusCodeBoolean}    CommitCompositionTemplate     ${dv_time_composition_value}    ${expectedCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedCode} is different.
    END
    [Teardown]      Run Keywords
    ...     Delete Composition Using API    AND
    ...     Delete Template Using API   AND
    ...     Remove File     ${newOPTFile}   AND
    ...     (admin) delete ehr      AND     (admin) delete all OPTs

Load XML File With OPT
    [Documentation]     Loads XML content from OPT file.
    ...     Stores file content in test variable, as well as full file path.
    [Arguments]     ${filePath}
    ${xmlFileContent}     Parse Xml   ${VALID DATA SETS}/${filePath}
    Set Test Variable   ${xmlFileContent}

CommitCompositionTemplate
    [Arguments]     ${dvDateTimeValue}      ${expectedCode}
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${dvDateTimeValue}
    Commit Composition Using Robot Templates
    ...                     format=CANONICAL_JSON
    ...                     composition=${composition_file}
    ${isStatusCodeEqual}    Run Keyword And Return Status
    ...     Should Be Equal As Strings      ${response.status_code}     ${expectedCode}
    ${isUidPresent}     Run Keyword And Return Status   Set Test Variable   ${version_uid}    ${response.json()['uid']['value']}
    IF      ${isUidPresent} == ${TRUE}
        @{split_compo_uid}      Split String        ${version_uid}      ::
        Set Suite Variable      ${system_id_with_tenant}    ${split_compo_uid}[1]
        ${short_uid}        Remove String       ${version_uid}    ::${system_id_with_tenant}::1
                            Set Suite Variable   ${versioned_object_uid}    ${short_uid}
    ELSE
        Set Suite Variable   ${versioned_object_uid}    ${None}
    END
    RETURN    ${isStatusCodeEqual}

Change Json KeyValue And Save Back To File
    [Documentation]     Updates DV_TIME values to
    ...     value provided as argument.
    ...     Takes 2 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be changed JsonPath key
    [Arguments]     ${jsonContent}      ${valueToUpdate}
    ${objPath}      Set Variable        $.content[0].data.events[0].data.items[0].value.value
    ${json_object}  Update Value To Json	${jsonContent}
    ...             ${objPath}        ${valueToUpdate}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${compositionFilePath}    ${json_str}

Change XML Value And Save Back To New OPT
    [Documentation]     Updates XML text and saves it as a file.
    ...     ${\n}Takes 2 arguments:
    ...     - XML file element or content
    ...     - c_time value
    [Arguments]     ${xmlContent}   ${c_time_pattern_value}
    # Convert the XML element object to a string (if it isn't one already)
    ${xml_string}=    Element To String    ${xmlContent}
    Set Test Variable   ${C_TIME_PATTERN}   ${c_time_pattern_value}
    ${replaced_xml}=    Replace Variables    ${xml_string}
    Log     Modified C_TIME pattern value is = ${C_TIME_PATTERN}
    Set Test Variable   ${newOPTFile}   ${VALID DATA SETS}/${opt_temp_file}
    Create File    ${newOPTFile}    ${replaced_xml}
    RETURN    ${opt_temp_file}

Load Json File With Composition
    [Documentation]     Loads Json content from composition file.
    ...     Stores file content in test variable, as well as full file path.
    ${COMPO DATA SETS}     Set Variable
    ...     ${PROJECT_ROOT}${/}tests${/}robot${/}_resources${/}test_data_sets${/}compositions
    ${file}                 Get File        ${COMPO DATA SETS}/CANONICAL_JSON/${composition_file}
    ${compositionFilePath}  Set Variable    ${COMPO DATA SETS}/CANONICAL_JSON/${composition_file}
    Set Suite Variable       ${file}
    Set Suite Variable       ${compositionFilePath}

Commit Composition Using Robot Templates
    [Arguments]         ${format}   ${composition}
    ...         ${need_template_id}=true   ${prefer}=representation
    ...         ${lifecycle}=complete    ${extTemplateId}=false
    [Documentation]     Creates the first version of a new COMPOSITION
    ...                 DEPENDENCY: `upload OPT`, `create EHR`
    ...
    ...                 ENDPOINT: POST /ehr/${ehr_id}/composition
    ...
    ...                 FORMAT VARIABLES: FLAT, TDD, STRUCTURED, CANONICAL_JSON, CANONICAL_XML

    @{template}=        Split String    ${composition}   __
    ${template}=        Get From List   ${template}      0

    Set Suite Variable    ${template_id}    ${template}

    ${file}=           Get File   ${COMPO DATA SETS}/${format}/${composition}

    &{headers}=        Create Dictionary   Prefer=return=${prefer}
    ...                openEHR-VERSION.lifecycle_state=${lifecycle}

    IF    '${need_template_id}' == 'true'
        Set To Dictionary   ${headers}   openEHR-TEMPLATE_ID=${template}
    END

    IF   '${format}'=='CANONICAL_JSON'
        Create Session      ${SUT}    ${BASEURL}    debug=2
        ...                 verify=True     #auth=${CREDENTIALS}
        Set To Dictionary   ${headers}   Content-Type=application/json
        Set To Dictionary   ${headers}   Accept=application/json
    ELSE IF   '${format}'=='CANONICAL_XML'
        Create Session      ${SUT}    ${BASEURL}    debug=2
        ...                 verify=True     #auth=${CREDENTIALS}
        Set To Dictionary   ${headers}   Content-Type=application/xml
        Set To Dictionary   ${headers}   Accept=application/xml
    ELSE IF   '${format}'=='FLAT'
        Set To Dictionary   ${headers}   Content-Type=application/json
        Set To Dictionary   ${headers}   Accept=application/json
        Set To Dictionary   ${headers}   X-Forwarded-Host=example.com
        Set To Dictionary   ${headers}   X-Forwarded-Port=333
        Set To Dictionary   ${headers}   X-Forwarded-Proto=https
        IF  '${extTemplateId}' == 'true'
            ${template_id}      Set Variable   ${externalTemplate}
            ${template}      Set Variable   ${externalTemplate}
            Set Suite Variable    ${template_id}    ${template}
        END
        &{params}       Create Dictionary     format=FLAT   ehrId=${ehr_id}     templateId=${template_id}
        Create Session      ${SUT}    ${ECISURL}    debug=2
        ...                 verify=True     #auth=${CREDENTIALS}
    ELSE IF   '${format}'=='TDD'
        Create Session      ${SUT}    ${BASEURL}    debug=2
        ...                 verify=True     #auth=${CREDENTIALS}
        Set To Dictionary   ${headers}   Content-Type=application/openehr.tds2+xml
        Set To Dictionary   ${headers}   Accept=application/openehr.tds2+xml
    ELSE IF   '${format}'=='STRUCTURED'
        Create Session      ${SUT}    ${BASEURL}    debug=2
        ...                 verify=True     #auth=${CREDENTIALS}
        Set To Dictionary   ${headers}   Content-Type=application/openehr.wt.structured+json
        Set To Dictionary   ${headers}   Accept=application/openehr.wt.structured+json
    END

    IF          '${format}'=='FLAT'
        ${resp}     POST On Session     ${SUT}   composition   params=${params}
        ...     expected_status=anything   data=${file}   headers=${headers}
    ELSE
        ${resp}     POST On Session     ${SUT}   /ehr/${ehr_id}/composition
        ...     expected_status=anything   data=${file}   headers=${headers}
    END

    Set Suite Variable   ${response}     ${resp}
    Set Suite Variable   ${format}       ${format}
    Set Suite Variable   ${template}     ${template}

    capture point in time    1
