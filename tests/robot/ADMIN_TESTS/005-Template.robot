# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH).
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



*** Settings ***
Metadata    Version    0.1.0
Metadata    Authors    *Wladislaw Wagner*, *Axel Siebert"
Metadata    Created    2020.12.28

Metadata        TOP_TEST_SUITE    ADMIN_TEMPLATE

Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/template_opt1.4_keywords.robot

Suite Setup     Set Library Search Order For Tests

Force Tags     ADMIN_template


*** Variables ***
# comment: overriding defaults in suite_settings.robot
${SUT}                  ADMIN-TEST
${CACHE-ENABLED}        ${FALSE}


#////////////////////////////////////////////////////////////
#//                                                        //
#//   NOTE: Tests can't be executed in random order!       //
#//         Some have impact on each other                 //
#//         cause clean up steps don't work properly!      //
#//         Until this is fixed preserve given order!!!    //
#//                                                        //
#///////////////////////////////////////////////////////////

*** Test Cases ***
002 ADMIN - Delete All Templates (when only one was uploaded before)
    upload valid OPT    minimal/minimal_admin.opt
    (admin) delete all OPTs
    # 422 for case when "Cannot delete template x since the following compositions are still using it"
    Status Should Be    200
    Should Be True      ${response.json()["deleted"]}>0

003 ADMIN - Delete Multiple Templates
    upload valid OPT    minimal/minimal_admin.opt
    upload valid OPT    minimal/minimal_evaluation.opt
    (admin) delete all OPTs
    Status Should Be    200
    Should Be True      ${response.json()["deleted"]}>1

004a ADMIN - Delete Existing Template
    upload valid OPT    minimal/minimal_admin.opt
    (admin) delete OPT
    Status Should Be    200
    [Teardown]    (admin) delete all OPTs

005 ADMIN - Delete Non-Existing Template
    prepare new request session    XML
    Set Test Variable   ${template_id}  non_existing_template_id
    (admin) delete OPT
    Status Should Be    404
    Should Be Equal As Strings      ${response.json()["error"]}     Not Found
    Should Contain      ${response.json()["message"]}               not found.

006 ADMIN - Invalid Usage of Delete Endpoint
                        prepare new request session    XML
    ${resp}             DELETE On Session   ${SUT}  /template/
                        ...     expected_status=anything    headers=${headers}
                        Status Should Be    404
                        Should Contain      ${resp.text}
                        ...     <error>Not Found</error><message>No resource found at path: rest/openehr/v1/template</message>

007 ADMIN - Update Non-Existing Template
    generate random templade_id
    (admin) update OPT    minimal/minimal_admin_updated.opt
    validate PUT response - 404 unknown templade_id

008a ADMIN - Update Existing Template
    upload valid OPT    minimal/minimal_admin.opt
    (admin) update OPT    minimal/minimal_admin_updated.opt
    Status Should Be    200
    retrieve OPT by template_id     template_id=${template_id}
    XML.Element Text Should Be    ${actual}
    ...                           Minimal Admin UPDATED BY ROBOT
    ...                           xpath=concept
    [Teardown]    (admin) delete all OPTs

009 ADMIN - Delete Multiple Templates Where Some Are In Use
    upload valid OPT    minimal/minimal_admin.opt
    upload valid OPT    minimal/minimal_evaluation.opt
    create new EHR (XML)
    commit composition (XML)    minimal/minimal_admin.composition.extdatetimes.xml
    (admin) delete all OPTs
    Status Should Be    422
    Should Be Equal As Strings      ${response.json()["error"]}     Unprocessable Entity
    Should Be Equal As Strings      ${response.json()["message"]}
    ...     Cannot delete template minimal_admin.en.v1 since it is used by at least one composition
    [Teardown]    Run Keywords    (admin) delete composition    AND
                  ...             (admin) delete ehr    AND
                  ...             (admin) delete all OPTs

010a ADMIN - Delete Template That Is In Use
    upload valid OPT    minimal/minimal_admin.opt
    create new EHR (XML)
    commit composition (XML)    minimal/minimal_admin.composition.extdatetimes.xml
    (admin) delete OPT
    Status Should Be    422
    Should Be Equal As Strings      ${response.json()["error"]}     Unprocessable Entity
    Should Be Equal As Strings      ${response.json()["message"]}
    ...     Cannot delete template minimal_admin.en.v1 since it is used by at least one composition
    [Teardown]    Run Keywords    (admin) delete composition    AND
                  ...             (admin) delete ehr    AND
                  ...             (admin) delete all OPTs

010c ADMIN - Delete Template That Was In Use - (Admin)Deleted Composition
    [Documentation]    Composition is deleted with the admin endpoint and thus has been removed 
    ...                "physically" from database. The admin endpoint will respond with a 200
    ...                response and the template is removed.
    upload valid OPT    minimal/minimal_admin.opt
    create new EHR (XML)
    commit composition (XML)    minimal/minimal_admin.composition.extdatetimes.xml
    (admin) delete composition
    (admin) delete OPT
    #TRACE GITHUB ISSUE    438    message=see https://github.com/ehrbase/project_management/issues/382#issuecomment-777255800 for details
    Status Should Be    200
    # validate DELETE response - 200 deleted
    # check that template does not exist any more
    ${resp}     GET On Session    ${SUT}    /definition/template/adl1.4/${template_id}
                ...     expected_status=anything    headers=${headers}
                Should Be Equal As Strings    ${resp.status_code}    404
    [Teardown]    Run Keywords    (admin) delete ehr    AND     (admin) delete all OPTs

010b ADMIN - Delete Template That Is In Use - Deleted Composition
    upload valid OPT    minimal/minimal_admin.opt
    create new EHR (XML)
    commit composition (XML)    minimal/minimal_admin.composition.extdatetimes.xml
    delete composition    ${version_uid}
    (admin) delete OPT
    Status Should Be    422
    [Teardown]    Run Keywords    (admin) delete ehr    AND     (admin) delete all OPTs

011 ADMIN - Update Template That Is In Use
    [Documentation]     A template that is in use by a composition has to reject updates.
    upload valid OPT    minimal/minimal_admin.opt
    create new EHR (XML)
    commit composition (XML)    minimal/minimal_admin.composition.extdatetimes.xml
    (admin) update OPT    minimal/minimal_admin_updated.opt
    validate PUT response - 422 unprocessable entity
    Create Session      ${SUT}      ${BASEURL}      debug=2
    ...     verify=True     #auth=${CREDENTIALS}
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}
                ...     expected_status=anything    headers=${headers}
                Status Should Be    200
                Log    ${resp.content}
                XML.Element Text Should Be    ${resp.content}    Minimal admin
                ...                           xpath=concept
    [Teardown]      Run Keywords    (admin) delete composition    AND
                    ...             (admin) delete ehr    AND
                    ...             (admin) delete all OPTs

012 ADMIN - Invalid Usage of Update Endpoint
    prepare new request session     XML
    Create Session      ${SUT}     ${ADMIN_BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}
    ${resp}     PUT On Session    ${SUT}    template/   expected_status=anything
                ...     headers=${headers}
                Status Should Be    404
                Log     ${resp.text}

013 ADMIN - Invalid Usage of Update Endpoint
    prepare new request session     XML
    Create Session      ${SUT}      ${ADMIN_BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}
    ${resp}     PUT On Session    ${SUT}    template/foo   expected_status=anything
                ...     headers=${headers}
                Status Should Be    400
                Log     ${resp.text}

014 ADMIN - Invalid Usage of Update Endpoint
    prepare new request session    XML
    Create Session       ${SUT}    ${ADMIN_BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}
    &{template_dict}    Create Dictionary   foo=bar
    ${resp}     PUT On Session    ${SUT}    template/foo   json=${template_dict}
                ...     expected_status=anything
                ...     headers=${headers}
                Status Should Be    404
                Should Contain      ${resp.text}    Template with id foo does not exist

015 ADMIN - Invalid Usage of Update Endpoint
    prepare new request session    XML
    Create Session       ${SUT}    ${ADMIN_BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}
    &{template_dict}    Create Dictionary   foo=bar
    ${resp}     PUT On Session    ${SUT}    template/123   json=${template_dict}
                ...     expected_status=anything
                ...     headers=${headers}
                Status Should Be    404
                Should Contain      ${resp.text}    Template with id 123 does not exist


*** Keywords ***
#startup SUT
#    [Documentation]     Overrides `generic_keywords.startup SUT` keyword
#    ...                 to add some ENVs required by this test suite.
#
#    Set Environment Variable    ADMINAPI_ACTIVE    true
#    Set Environment Variable    ADMINAPI_ALLOWDELETEALL    true
#    Set Environment Variable    SYSTEM_ALLOWTEMPLATEOVERWRITE    true
#    generic_keywords.startup SUT

upload valid OPT
    [Arguments]           ${opt file}

    prepare new request session    XML
    ...    Prefer=return=representation
    get valid OPT file    ${opt file}
    Extract Template Id From OPT File
    upload OPT file
    Set Test Variable    ${response}    ${response}
    #server accepted OPT
    IF  '${response.status_code}' != '409'
        server accepted OPT
    ELSE
        server rejected OPT with status code 409
    END

validate PUT response - 200 updated
                        Should Be Equal As Strings    ${response.status_code}   200
                        log    ${response.content}

                        IF    '${prefer_return}'=='representation'

                              XML.Element Text Should Be    ${response.content}
                              ...                           Minimal Admin UPDATED BY ROBOT
                              ...                           xpath=concept
                        END
                        IF    '${prefer_return}'=='minimal'
                              Should Be Equal As Strings    ${response.content}    ${EMPTY}
                        END


validate PUT response - 404 unknown templade_id
                        log   ${response.content}
                        Should Be Equal As Strings    ${response.status_code}    404
                        Should Match    ${response.text}    *Template with id ${template_id} does not exist*


validate PUT response - 422 unprocessable entity
                        log   ${response.content}
                        Should Be Equal As Strings    ${response.status_code}    422
                        Should Contain    ${response.text}    is used by


validate DELETE response - 204 deleted
                        Integer    response status   204

                        IF    '${prefer_return}'=='representation'
                              Integer    response body deleted    1
                        END
                        IF    '${prefer_return}'=='minimal'
                              String     response body    ${EMPTY}
                        END


validate DELETE response - 422 unprocessable entity
                        Integer    response status   422
                        String     response body message
                        ...        pattern=Cannot delete template minimal_admin.en.v1 since the following compositions are still using it.*


validate DELETE ALL response - 204 deleted ${amount}
                        Integer    response status   200
                        Integer    response body deleted    ${amount}


validate DELETE ALL response - 422 unprocessable entity
                        Integer     response status   422
                        String      response body message
                        ...         pattern=Cannot delete template *
                        #...        pattern=Cannot delete template minimal_admin.en.v1 since the following compositions are still using it.*










# oooooooooo.        .o.         .oooooo.   oooo    oooo ooooo     ooo ooooooooo.
# `888'   `Y8b      .888.       d8P'  `Y8b  `888   .8P'  `888'     `8' `888   `Y88.
#  888     888     .8"888.     888           888  d8'     888       8   888   .d88'
#  888oooo888'    .8' `888.    888           88888[       888       8   888ooo88P'
#  888    `88b   .88ooo8888.   888           888`88b.     888       8   888
#  888    .88P  .8'     `888.  `88b    ooo   888  `88b.   `88.    .8'   888
# o888bood8P'  o88o     o8888o  `Y8bood8P'  o888o  o888o    `YbodP'    o888o
#
# [ BACKUP ]


# VARIANTS
# PUT admin_baseurl/template/{template_id}    200
# PUT admin_baseurl/template/{template_id}    404
# PUT admin_baseurl/template/{template_id}    422
# PUT admin_baseurl/template/                 404
# PUT admin_baseurl/template/123              404
# PUT admin_baseurl/template/foobar           404

# DELETE admin_baseurl/template/{template_id}    204
# DELETE admin_baseurl/template/{template_id}    422
# DELETE admin_baseurl/template/all              200
# DELETE admin_baseurl/template/all              422
# DELETE admin_baseurl/template/all              200 (ohne vorher opts hochzuladen)
# DELETE admin_baseurl/template/all              200 (nur 1 opt vorher hochgeladen)
