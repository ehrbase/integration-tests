# EHRbase Integration Tests with Robot Framework

Please refer to https://docs.ehrbase.org/en/latest/03_development/02_testing/index.html

## Running the tests locally

This command will run all tests from `tests/robot` folder.
DB and server have to be started prior to running the tests.

> NOTE: Make sure you meet the PREREQUISITES mentioned in the [documentation](https://docs.ehrbase.org/en/latest/03_development/02_testing/index.html) prior to test execution.

```bash
cd tests
./run_local_tests.sh
```

## Running the test using docker

Execute a single test suite and store results in `./results`: 
```bash
docker run -ti -v ./results:/integration-tests/results ehrbase/integration-tests:build runRobotTest \
  --serverBase http://ehrbase:8080 \
  --name SANITY \
  --path SANITY_TESTS \
  --tags Sanity 
```

Collect results of multiple tests into a single report
```bash
docker run -ti -v ./results:/integration-tests/results -v ./report:/integration-tests/report ehrbase/integration-tests:build collectRebotResults
```
