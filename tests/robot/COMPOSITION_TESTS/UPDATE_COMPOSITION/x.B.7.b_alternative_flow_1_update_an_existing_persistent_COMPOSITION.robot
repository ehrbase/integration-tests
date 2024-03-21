# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Pablo Pazos (Hannover Medical School).
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
Documentation   Composition Integration Tests
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests

Force Tags



*** Test Cases ***
Alternative flow 1 update an existing persistent COMPOSITION

    Upload OPT    minimal_persistent/persistent_minimal.opt

    create EHR    XML

    commit composition (XML)    minimal_persistent/persistent_minimal.composition.extdatetime.xml
    check content of composition (XML)

    update composition (XML)    minimal_persistent/persistent_minimal.composition.extdatetime.v2.xml
    check content of updated composition (XML)

    [Teardown]    Run Keywords      (admin) delete ehr      AND     (admin) delete all OPTs
