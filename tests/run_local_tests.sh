#!/usr/bin/env bash

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



# Set desired loglevel: NONE, INFO, DEBUG, TRACE (most details)
export LOG_LEVEL=TRACE


# # UNCOMMENT NEXT LINE & COMMENT-OUT ALL OTHERS BELOW TO RUN ONLY 'XXX' TESTS
# robot --include XXX --outputdir results -L $LOG_LEVEL robot/


# RUN SANITY TESTS
robot -i Sanity -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/SANITY_TESTS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name SANITY \
      robot/SANITY_TESTS/

# RUN CONTRIBUTION SERVICE TESTS
robot -i CONTRIBUTION -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/CONTRIBUTION_SERVICE \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name CONTRI \
      robot/CONTRIBUTION_TESTS/

# RUN SWAGGER TESTS
robot -i SWAGGER_EHRBASE -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/SWAGGER_TESTS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name SWAGGER \
      robot/SWAGGER_TESTS/

# RUN TEMPLATE TESTS
robot -i template -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/TEMPLATE_TESTS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name TEMPLATE \
      robot/TEMPLATE_TESTS/

# RUN STORED QUERY TESTS
robot -i stored_query -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/STORED_QUERY_TESTS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name STORED_QUERY \
      robot/STORED_QUERY_TESTS/

# RUN TAGS TESTS
robot -i TAGS_SUITES -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/TAGS_TESTS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name TAGS \
      robot/TAGS_TESTS/

# RUN COMPOSITION SERVICE TESTS
robot -i COMPOSITION -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/COMPOSITION_SERVICE \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name COMPO \
      robot/COMPOSITION_TESTS/

# RUN DIRECTORY SERVICE TESTS
robot -i DIRECTORY -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/DIRECTORY_SERVICE \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name DIR \
      robot/DIRECTORY_TESTS/

# RUN AQL TESTS
robot -i AQL_TESTS_PACKAGE -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/AQL_TESTS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name AQL \
      robot/AQL_TESTS/

# RUN EHR SERVICE TESTS
robot -i EHR_SERVICE -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/EHR_SERVICE \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name EHR \
      robot/EHR_SERVICE_TESTS/

# RUN EHR STATUS TESTS
robot -i EHR_STATUS -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/EHR_STATUS \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name EHR \
      robot/EHR_STATUS_TESTS/

# RUN KNOWLEDGE SERVICE TESTS
robot -i KNOWLEDGE -e circleci -e EHRSCAPE -e obsolete -e libtest \
      --outputdir results/test-suites/KNOWLEDGE_SERVICE \
      --skiponfailure not-ready \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --loglevel $LOG_LEVEL \
      --name KNOWLEDGE \
      robot/KNOWLEDGE_TESTS/


# POST PROCESS & MERGE OUTPUTS

# Create Log/Report with ALL DETAILS
rebot --outputdir results \
      --name EHRbase \
      --exclude TODO -e future -e obsolete -e libtest \
      --removekeywords for \
      --removekeywords wuks \
      --loglevel TRACE \
      --skiponfailure not-ready \
      --timestampoutputs \
      --output EHRbase-output.xml \
      --log EHRbase-log.html \
      --report EHRbase-report.html \
      results/test-suites/*/*.xml







#   ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗
#   ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗
#   ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝
#   ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝
#   ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║
#   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝
#
#   [ BACKUP ]
#
# NOTE: below stuff not usable with the recent pre/postcondition implementation
# # Run with Docker | no need to install anything
# docker run --rm -it --env HOST_UID=$(id -u) --env HOST_GID=$(id -g) --network host \
# --volume "$PWD/robot":/home/robot/tests \
# --volume "$PWD/results":/home/robot/results \
# robod0ck/robod0ck --skiponfailure not-ready -e BDD -L TRACE tests/

# # CLEANUP after test run
# ## 1. Remove all containers and volumes
# docker container rm --force $(docker container ls -q)
# docker wait $(docker container ls -q)
# docker system prune --volumes --force
#
# ## 2. Restart PostgreSQL DB container
# docker run -e POSTGRES_USER=postgres \
#            -e POSTGRES_PASSWORD=postgres \
#            -d -p 5432:5432 ehrbase/ehrbase-postgres:11.10
