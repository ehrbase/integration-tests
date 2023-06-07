*** Settings ***
Documentation   CHECK COMPLETE RETURN OF COMPOSITION C
Resource        ../../_resources/keywords/aql_keywords.robot


*** Test Cases ***
Test Complete Return Of Composition C
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL

    [Teardown]      Admin Delete EHR For AQL

