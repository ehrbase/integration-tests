*** Settings ***
Metadata    Author    *Vladislav Ploaia*

Documentation    AUTHENTICATION TYPE TESTS
...
...              Based on requirements from https://vitagroup-ag.atlassian.net/browse/CDR-1401
...              \nDO NOT ENABLE THEM IF PIPELINE IS NOT SETTING FOR TESTS *AUTH_TYPE:BASIC*
...              \nREQUIRES EHRBASE to be started with *security.authType=BASIC*

Resource    ${EXECDIR}/robot/_resources/suite_settings.robot


Force Tags    AUTH_TYPE_TESTS_BASIC