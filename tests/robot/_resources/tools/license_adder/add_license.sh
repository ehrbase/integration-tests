#!/usr/bin/env bash

# make sure licenseheaders is installed: pip install licenseheaders
# usage: . add_license.sh
#
# NOTE: applies to .py and .robot files
#       add license manually to .yaml .md and files that are commented out below

licenseheaders -t license_template -d ../helpers --additional-extensions robot=[.robot]
licenseheaders -t license_template -d ../../keywords --additional-extensions robot=[.robot]
licenseheaders -t license_template -d ../../libraries --additional-extensions robot=[.robot]
#licenseheaders -t license_template -d ../../status_report.robot --additional-extensions robot=[.robot]
#licenseheaders -t license_template -d ../../suite_settings.robot --additional-extensions robot=[.robot]
#licenseheaders -t license_template -d ../../../ci_test_dummy.robot

licenseheaders -t license_template -d ../../../COMPOSITION/ --additional-extensions robot=[.robot]
licenseheaders -t license_template -d ../../../CONTRIBUTION/ --additional-extensions robot=[.robot]
licenseheaders -t license_template -d ../../../EHR_SERVICE/ --additional-extensions robot=[.robot]
licenseheaders -t license_template -d ../../../KNOWLEDGE/ --additional-extensions robot=[.robot]
licenseheaders -t license_template -d ../../../QUERY_SERVICE/ --additional-extensions robot=[.robot]
