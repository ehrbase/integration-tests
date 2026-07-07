# EHRbase Integration Tests with Robot Framework

<details>
<summary><b>Prerequisites</b></summary>
<br>

1. **Docker installed.**
    * [Get Docker](https://docs.docker.com/get-started/get-docker/)
2. **Python 3.11.x & Pip installed:**
    * [Python Downloads](https://www.python.org/downloads/)
    * [Pip Installation Guide](https://pip.pypa.io/en/stable/installation/)

2. **Robot Framework & dependencies installed:**
    * Run the following command inside your `tests` folder:
      ```bash
      pip install -r requirements.txt
      ```

3. **An EHRbase instance running on port `8080`:**
   <details>
   <summary><i>Click to expand: Configure & run EHRbase instance</i></summary>
   <br>

    1. Create the Docker network:
       ```bash
       docker network create ehrbase-net
       ```
    2. Spin up the Postgres database:
       ```bash
       docker run --name ehrdb --network ehrbase-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 ehrbase/ehrbase-v2-postgres:16.2
       ```
    3. Change the following properties in `ehrbase/configuration/src/main/resources/application.yml`:
       ```yaml
       ehrscape.enabled: true
       tags.enabled: true
       aql.debugging-enabled: true
       aql.response.generator-details-enabled: true
       ```
       > **Note:** If you need to modify other settings, feel free to do so. However, please note that existing Robot tests are tightly coupled to the default configuration and may fail if other values are changed.

    4. Build the project (run from the root `/ehrbase` folder):
       ```bash
       mvn clean install -Dmaven.test.skip=true
       ```
    5. Start the application (run from the root `/ehrbase` folder):
       ```bash
       java -jar application/target/ehrbase.jar --server.nodename=local.ehrbase.org
       ```
    6. Wait for the confirmation message in your console:  
       `Started EhrBase in X seconds`
   </details>
</details>

### Trigger Robot tests locally
From /ehrbase root project directory, run:
```bash
cd tests
./run_local_tests.sh
```

## Running tests in Docker

<details>
<summary><b>Prerequisites</b></summary>
<br>

1. Change the following properties in `ehrbase/configuration/src/main/resources/application.yml`:
    ```yaml
    ehrscape.enabled: true
    tags.enabled: true
    aql.debugging-enabled: true
    aql.response.generator-details-enabled: true
    ```
    > **Note:** If you need to modify other settings, feel free to do so. However, please note that existing Robot tests are tightly coupled to the default configuration and may fail if other values are changed.
2. Build the project (run from the root `/ehrbase` folder):
   ```bash
   mvn clean install -Dmaven.test.skip=true
   ```
3. Build Docker image (run from the root `/ehrbase` folder):
   ```bash
   docker build -t ehrbase/ehrbase:next .
   ```
4. Set environment variable `EHRBASE_IMAGE`:
   ```bash
   SET EHRBASE_IMAGE=ehrbase/ehrbase:next
   ```
</details>

Execute a single test suite and store results in `./tests/results` (run from the root `/ehrbase` folder):
<details>
<summary><b>Expand commands to run tests in Docker</b></summary>
<br>

```bash
docker compose -f docker-compose.yml -f tests/docker-compose-int-test.yml run \
  --remove-orphans --rm ehrbase-integration-tests runRobotTest \
  --serverBase http://ehrbase:8080 \
  --name SANITY \
  --path SANITY_TESTS \
  --tags Sanity \
  --env NONE
```
For the other suites, just replace below lines (for example) in the above full command:
```bash
...
  --name STORED_QUERY \
  --path STORED_QUERY_TESTS \
  --tags stored_query \
...
```
```bash
...
  --name COMPOSITION \
  --path COMPOSITION_TESTS \
  --tags COMPOSITION \
...
```
```bash
...
  --name CONTRIBUTION \
  --path CONTRIBUTION_TESTS \
  --tags CONTRIBUTION \
...
```
```bash
...
  --name DIRECTORY \
  --path DIRECTORY_TESTS \
  --tags DIRECTORY \
...
```
```bash
...
  --name AQL \
  --path AQL_TESTS \
  --tags AQL_TESTS_PACKAGE \
...
```
```bash
...
  --name EHR_SERVICE \
  --path EHR_SERVICE_TESTS \
  --tags EHR_SERVICE \
...
```
```bash
...
  --name EHR_STATUS \
  --path EHR_STATUS_TESTS \
  --tags EHR_STATUS \
...
```
```bash
...
  --name EHRSCAPE \
  --path EHRSCAPE_TESTS \
  --tags EhrScapeTag \
...
```
```bash
...
  --name TAGS \
  --path TAGS_TESTS \
  --tags TAGS_SUITES \
...
```
```bash
...
  --name TEMPLATE \
  --path TEMPLATE_TESTS \
  --tags template \
...
```
```bash
...
  --name SWAGGER \
  --path SWAGGER_TESTS \
  --tags SWAGGER_EHRBASE \
...
```
</details>
