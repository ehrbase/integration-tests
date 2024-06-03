#!/bin/bash
set -u

base=$(pwd)
dirResults="$base/results"


############################################################
# Help                                                     #
############################################################
showHelp()
{
   # Display Help
   echo "Run a given robot integration tests suite."
   echo
   echo "Syntax:  runRobotTests [h|-n|-p|-t|-s]"
   echo
   echo "Example: runRobotTests --name SANITY --path SANITY_TESTS --tags Sanity -t TEST"
   echo
   echo "options:"
   echo "n|name         Name of the suite also used as result sub directory."
   echo "p|path         Path of the suite to run."
   echo "t|tags         Include tags."
   echo "s|suite        SUT param defaults to 'TEST'."
   echo "serverBase     Ehrbase server base, defaults to env var EHRBASE_BASE_URL or fallback to http://ehrbase:8080"
   echo "serverNodeName Ehrbase server node name, defaults to env var SERVER_NODENAME or fallback to local.ehrbase.org"
   echo
}

name=0
path=0
tags=0
env=0
suite='TEST'
serverBase=${EHRBASE_BASE_URL:-http://ehrbase:8080}
serverNodeName=${SERVER_NODENAME:-local.ehrbase.org}
keycloakBase=${KEYCLOAK_BASE_URL:-http://localhost:8081}
POSITIONAL_ARGS=()

############################################################
# parse command line args                                  #
############################################################

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showHelp
      exit
      ;;
    -n|--name)
      name="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--path)
      path="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--tags)
      tags="$2"
      shift # past argument
      shift # past value
      ;;
    -e|--env)
      env="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--suite)
      suite="$2"
      shift # past argument
      shift # past value
      ;;
    --serverBase)
      serverBase="$2"
      shift # past argument
      shift # past value
      ;;
    --serverNodeName)
      serverNodeName="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      echo "Error: Invalid option [$1]"
      exit -1;;
  esac
done


############################################################
# Checks given parameters                                  #
############################################################

if [ $name == 0 ]; then
    echo "Option [name] not specified"
    exit -1
fi
if [ $path == 0 ]; then
    echo "Option [path] not specified"
    exit -1
fi
if [ $path == 0 ]; then
    echo "Option [path] not specified"
    exit -1
fi


############################################################
# Ensures we are in a clean result directory               #
############################################################

rm -Rf ${dirResults}/${name}


############################################################
# Run tests                                                #
############################################################

echo "---------------------------------------------------------------------------------------"
echo "Running Robot Test-Suite [name: ${name}, path: ${path}, tags: ${tags}, env=${env}, suite: ${suite}]"
echo "---------------------------------------------------------------------------------------"

cd tests
echo "Robot Command:"
echo "robot --include ${tags} \
      --skip TODO \
      --skip future \
      --loglevel INFO \
      -e SECURITY \
      -e AQL_DEBUG_OPTS \
      --dotted \
      --console quiet \
      --skiponfailure not-ready -L TRACE \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --flattenkeywords \"name:composition_keywords.Load Json File With Composition\" \
      --flattenkeywords \"name:template_opt1.4_keywords.upload OPT file\" \
      --removekeywords \"name:JSONLibrary.Load Json From File\" \
      --removekeywords \"name:Change Json KeyValue and Save Back To File\" \
      --removekeywords \"name:JSONLibrary.Update Value To Json\" \
      --removekeywords \"name:JSONLibrary.Convert JSON To String\" \
      --removekeywords \"name:JSONLibrary.Get Value From Json\" \
      --report NONE \
      --name ${name} \
      --outputdir ${dirResults}/${name} \
      -v SUT:${suite} \
      -v NODOCKER:False \
      -v AUTH_TYPE:${env} \
      -v NODENAME:${serverNodeName} \
      -v KEYCLOAK_URL:${keycloakBase}/auth \
      -v BASEURL:${serverBase}/ehrbase/rest/openehr/v1 \
      robot/${path}"

robot --include ${tags} \
      --skip TODO \
      --skip future \
      --loglevel INFO \
      -e SECURITY \
      -e AQL_DEBUG_OPTS \
      --dotted \
      --console quiet \
      --skiponfailure not-ready -L TRACE \
      --flattenkeywords for \
      --flattenkeywords foritem \
      --flattenkeywords name:_resources.* \
      --flattenkeywords "name:composition_keywords.Load Json File With Composition" \
      --flattenkeywords "name:template_opt1.4_keywords.upload OPT file" \
      --removekeywords "name:JSONLibrary.Load Json From File" \
      --removekeywords "name:Change Json KeyValue and Save Back To File" \
      --removekeywords "name:JSONLibrary.Update Value To Json" \
      --removekeywords "name:JSONLibrary.Convert JSON To String" \
      --removekeywords "name:JSONLibrary.Get Value From Json" \
      --report NONE \
      --name ${name} \
      --outputdir ${dirResults}/${name} \
      -v SUT:${suite} \
      -v NODOCKER:False \
      -v AUTH_TYPE:${env} \
      -v NODENAME:${serverNodeName} \
      -v KEYCLOAK_URL:${keycloakBase}/auth \
      -v BASEURL:${serverBase}/ehrbase/rest/openehr/v1 \
      robot/${path}
