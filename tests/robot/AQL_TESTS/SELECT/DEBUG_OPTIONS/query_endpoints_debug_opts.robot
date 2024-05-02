*** Settings ***
Documentation   CHECK Query Request Debug Options
...             - Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1397
...             - PR: https://github.com/ehrbase/ehrbase/pull/1296
Resource        ../../../_resources/keywords/aql_keywords.robot
Resource        ../../../_resources/keywords/aql_query_keywords.robot
Suite Setup     Set Library Search Order For Tests


*** Test Cases ***
1. Query - Ad-Hoc Query POST - DryRun True - ExecSQL True - QueryPlan True
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL "SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p WHERE c/uid/value='{compo_id}::{system_id_with_tenant}::1'"
    ...         - Check debug options are present in response body Query call.
    [Setup]     Precondition
    Set Suite Variable    ${query}
    ...     SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p WHERE c/uid/value='${compo_id}::${system_id_with_tenant}::1'
    Set Suite Variable    ${test_data}      {"q":"${query}"}
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=true     query_plan=true
    Send Ad Hoc Request     aql_body=${test_data}   req_headers=${debug_headers}
    Check Reponse Body

2. Query - Ad-Hoc Query POST - DryRun False - ExecSQL False - QueryPlan True
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=false     exec_sql=false     query_plan=true
    Send Ad Hoc Request     aql_body=${test_data}   req_headers=${debug_headers}
    Check Reponse Body

3. Query - Ad-Hoc Query POST - DryRun False - ExecSQL False - QueryPlan False
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=false     exec_sql=false     query_plan=false
    Send Ad Hoc Request     aql_body=${test_data}   req_headers=${debug_headers}
    Check Reponse Body

4. Query - Ad-Hoc Query POST - DryRun True - ExecSQL False - QueryPlan False
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=false     query_plan=false
    Send Ad Hoc Request     aql_body=${test_data}   req_headers=${debug_headers}
    Check Reponse Body

5. Query - Ad-Hoc Query POST - DryRun False - ExecSQL True - QueryPlan False
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=false     exec_sql=true     query_plan=false
    Send Ad Hoc Request     aql_body=${test_data}   req_headers=${debug_headers}
    Check Reponse Body

6. Query - Ad-Hoc Query POST - DryRun True - ExecSQL False - QueryPlan True
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=false     query_plan=true
    Send Ad Hoc Request     aql_body=${test_data}   req_headers=${debug_headers}
    Check Reponse Body

7. Query - Ad-Hoc Query GET - DryRun True - ExecSQL True - QueryPlan True
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=true     query_plan=true
    Send Ad Hoc Request Through GET     q_param=${query}    req_headers=${debug_headers}
    Check Reponse Body

8. Query - Ad-Hoc Query GET - Check Debug Option - DryRun True - ExecSQL True - QueryPlan False
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=true     query_plan=false
    Send Ad Hoc Request Through GET     q_param=${query}    req_headers=${debug_headers}
    Check Reponse Body

9. Query - Stored Query GET By Qualified Query Name And Version - DryRun False - ExecSQL True - QueryPlan True
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=false     exec_sql=true     query_plan=true
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${query}     format=text
    GET /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name_version}    req_headers=${debug_headers}
    Set Test Variable   ${resp_body}    ${resp}
    Set Test Variable   ${resp_body_columns}    ${resp['columns']}
    Check Reponse Body

10. Query - Stored Query GET By Qualified Query Name And Version - DryRun True - ExecSQL False - QueryPlan True
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=false     query_plan=true
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${query}     format=text
    GET /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name_version}    req_headers=${debug_headers}
    Set Test Variable   ${resp_body}    ${resp}
    Set Test Variable   ${resp_body_columns}    ${resp['columns']}
    Check Reponse Body

11. Query - Stored Query POST By Qualified Query Name - DryRun False - ExecSQL False - QueryPlan True
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=false     exec_sql=false     query_plan=true
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query}     format=text
    ${resp_query}       POST /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name}    req_headers=${debug_headers}
    Set Test Variable   ${resp_body}    ${resp}
    Set Test Variable   ${resp_body_columns}    ${resp['columns']}
    Check Reponse Body

12. Query - Stored Query POST By Qualified Query Name - DryRun True - ExecSQL True - QueryPlan False
    [Documentation]     - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    ${debug_headers}    Set Debug Options In Dict
    ...     dry_run=true     exec_sql=true     query_plan=false
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query}     format=text
    ${resp_query}       POST /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name}    req_headers=${debug_headers}
    Set Test Variable   ${resp_body}    ${resp}
    Set Test Variable   ${resp_body_columns}    ${resp['columns']}
    Check Reponse Body
    [Teardown]      Admin Delete EHR For AQL


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Suite Variable       ${compo_id}     ${composition_short_uid}

Check Reponse Body
    Length Should Be    ${resp_body_columns}    4
    ${rows_count}   Get Length      ${resp_body['rows']}
    IF  '${dry_run}' == 'true'
        Length Should Be    ${resp_body['rows']}    0
        Response Body Meta Checks For Debug Opts    resultsize_count=${${rows_count}}
    ELSE
        Length Should Be    ${resp_body['rows']}    5
        Response Body Meta Checks For Debug Opts    resultsize_count=${${rows_count}}   dry_run=${FALSE}
    END
