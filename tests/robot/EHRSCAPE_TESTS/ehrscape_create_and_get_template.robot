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
# Author: Vladislav Ploaia


*** Settings ***
Documentation       EHRScape Tests
...                 Documentation URL to be defined

Resource            ../_resources/keywords/composition_keywords.robot

Suite Setup    SuitePrecondition
#Suite Teardown      restart SUT


*** Test Cases ***
Main flow create Template and GET by Template ID
    [Documentation]     Upload 1 template and get it using template_id (ECIS endpoints).
    Upload OPT      all_types/ehrn_family_history.opt
    Extract Template Id From OPT File
    Get Web Template By Template Id (ECIS)    ${template_id}

Main flow create and GET all Templates
    [Documentation]     Upload 2 templates and get all web templates, using ECIS endpoints.
    Upload OPT      all_types/family_history.opt
    Run Keyword And Return Status   Status Should Be    200
    Extract Template Id From OPT File
    ${template1}        Set Variable    ${template_id}
    Upload OPT      minimal/minimal_observation.opt
    Run Keyword And Return Status   Status Should Be    200
    Extract Template Id From OPT File
    ${template2}        Set Variable    ${template_id}
    #Get All Web Templates #TODO: enable this keyword
    #Check If Get Templates Response Has #TODO: enable this keyword
    #...         ${template1}        ${template2}

Get Template (ECIS) - Get Annotations
    [Documentation]     Create template, get it and check if additional annotations are present.
    [Tags]      not-ready
    Upload OPT    all_types/tobacco_smoking_summary.v0.opt
    Extract Template Id From OPT File
    Get Web Template By Template Id (ECIS)    ${template_id}    JSON
    Validate Response Body Has Format    JSON
    #PerformChecksOnAnnotation  #TODO: enable this keyword
    #webTemplate.tree.children[?(@.id='tobacco_smoking_summary')].children[?(@.id='start_date')].annotations.helpText
    #webTemplate.tree.children[?(@.id='tobacco_smoking_summary')].children[?(@.id='start_date')].annotations.validation
    #Example: $.['blocks'][?(@.block_id == 'image')]['image_url']
    #Save Response (JSON) To File And Compare Template Ids    ${template_id}

Get Template (ECIS) - Check Default Value Item
    [Documentation]     Create template, get it and check defaultValue key presence in JSON.
    [Tags]      not-ready   bug
    Upload OPT    all_types/dv_coded_text_default_error.opt
    Extract Template Id From OPT File
    Get Web Template By Template Id (ECIS)    ${template_id}    JSON
    Validate Response Body Has Format    JSON
    #below validation is failing because of CDR-417, missing defaultValue key in Get Template result.
    Log     ${response}
    Log     ${response['webTemplate']['tree']['children'][2]['children'][0]['inputs'][0]}
    Should Be Equal As Strings
    ...     ${response['webTemplate']['tree']['children'][2]['children'][0]['inputs'][0]['defaultValue']}
    ...     at0006
    [Teardown]    TRACE JIRA ISSUE    CDR-417

*** Keywords ***
ApplyJSONLocatorAndReturnResult
    [Documentation]     Apply JSON path on result and return JSON Path evaluation
    [Arguments]     ${children_id_with_annotation}      ${annotation_key}=comment
    ${returnValue}  Get Value From Json     ${response}
    ...     $.webTemplate.tree.children[?(@.id='tobacco_smoking_summary')].children[?(@.id='${children_id_with_annotation}')].annotations.${annotation_key}
    ${lenReturnValue}   Get Length  ${returnValue}
    Should Be True      ${lenReturnValue} > 0
    [Return]    ${returnValue}

PerformChecksOnAnnotation
    [Documentation]     Store JSON Path evaluation to variables.
    ...     Dependency: keyword -> Get Web Template By Template Id (ECIS)
    ${startDateAnnotationComment}       ApplyJSONLocatorAndReturnResult         start_date
    ${quitDateAnnotationComment}        ApplyJSONLocatorAndReturnResult         quit_date
    ${overallUseAnnotationComment}      ApplyJSONLocatorAndReturnResult         overall_use
    ${packDefinitionAnnotationComment}      ApplyJSONLocatorAndReturnResult     pack_definition
    ${startDateAnnotationHelpText}          ApplyJSONLocatorAndReturnResult     start_date          helpText
    ${quitDateAnnotationHelpText}           ApplyJSONLocatorAndReturnResult     quit_date           helpText
    ${overallUseAnnotationHelpText}         ApplyJSONLocatorAndReturnResult     overall_use         helpText
    ${packDefinitionAnnotationHelpText}     ApplyJSONLocatorAndReturnResult     pack_definition     helpText
    ${startDateAnnotationValidation}        ApplyJSONLocatorAndReturnResult     start_date          validation
    ${quitDateAnnotationValidation}         ApplyJSONLocatorAndReturnResult     quit_date           validation
    ${overallUseAnnotationValidation}       ApplyJSONLocatorAndReturnResult     overall_use         validation
    ${packDefinitionAnnotationValidation}   ApplyJSONLocatorAndReturnResult     pack_definition     validation
    Log     ${startDateAnnotationComment}           console=yes
    Log     ${quitDateAnnotationComment}            console=yes
    Log     ${overallUseAnnotationComment}          console=yes
    Log     ${packDefinitionAnnotationComment}      console=yes
    Log     ${startDateAnnotationHelpText}          console=yes
    Log     ${quitDateAnnotationHelpText}           console=yes
    Log     ${overallUseAnnotationHelpText}         console=yes
    Log     ${packDefinitionAnnotationHelpText}     console=yes
    Log     ${startDateAnnotationValidation}        console=yes
    Log     ${quitDateAnnotationValidation}         console=yes
    Log     ${overallUseAnnotationValidation}       console=yes
    Log     ${packDefinitionAnnotationValidation}   console=yes
	
SuitePrecondition
    ${variable_exists}      Run Keyword And Return Status
    ...     Variable Should Exist    ${MULTITENANCY_ENV_ENABLED}
    IF     '${variable_exists}' == '${FALSE}'
        Set Library Search Order    R	RCustom
    ELSE IF    '${MULTITENANCY_ENV_ENABLED}' == 'true' and '${variable_exists}' == 'True'
        Set Library Search Order    RCustom  R
    ELSE
        Set Library Search Order    R   RCustom
	END