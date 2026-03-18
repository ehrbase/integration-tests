# EHRbase Integration Tests with Robot Framework

## Running the tests locally

Before running the tests make sure the following prerequisites are in place:
1. Robot Framework & dependencies are installed (`pip install -r requirements.txt`)
2. An EHRbase instance is running on port `8080`

This command will run all tests from `tests/robot` folder.
DB and server have to be started prior to running the tests.

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
