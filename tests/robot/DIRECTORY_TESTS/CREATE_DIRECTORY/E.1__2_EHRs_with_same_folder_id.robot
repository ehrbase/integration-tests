*** Settings ***
Documentation    Alternative flow 3: create directory with the same existing uid in other EHR
...
...     Preconditions:
...         2 EHRs exists without folders
...
...     Flow:
...         1. Create Folder with defined uid (ex. e5ee0249-60c6-47b0-80cc-f5cef3172015::local.ehrbase.org::1) under EHR1
...         2. Create Folder with the same uid value (as in step1) under EHR2
...         3. The service should not allow to create folder from step2, as the folder with the same uid
...         exists under another EHR (this case under EHR1).
...
...     Postconditions:
...         EHR1 and EHR2 deleted
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests


Force Tags



*** Test Cases ***
Alternative flow: create directory with the same existing uid under another EHR
    [Tags]      not-ready
    [Documentation]     Previously failing due to https://vitagroup-ag.atlassian.net/browse/CDR-1615
    ## remove not-ready tag
    ## when branch https://github.com/ehrbase/ehrbase/tree/refs/heads/feature/CDR-1615-Fix-dublicate-folder-vo_id is merged
    create EHR
    Set Test Variable   ${ehr_id1}  ${ehr_id}
    create DIRECTORY (JSON)    empty_directory_with_defined_uid.json     isModifiable=${TRUE}
    Status Should Be    201
    create EHR
    Set Test Variable   ${ehr_id2}  ${ehr_id}
    Run Keyword And Return Status   create DIRECTORY (JSON)    empty_directory_with_defined_uid.json     isModifiable=${TRUE}
    Should Be Equal As Strings      ${response.status_code}      409
    Should Be Equal As Strings      ${response.json()['error']}     Conflict
    Should Be Equal As Strings      ${response.json()['message']}   FOLDER with uid e5ee0249-60c6-47b0-80cc-f5cef3172015 already exist.
    [Teardown]    Delete EHRs


*** Keywords ***
Delete EHRs
    Set Test Variable   ${ehr_id}   ${ehr_id1}
    (admin) delete ehr
    Set Test Variable   ${ehr_id}   ${ehr_id2}
    (admin) delete ehr