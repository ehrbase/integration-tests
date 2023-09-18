import yaml
import os


def get_variables():
    with open('robot/_resources/variables/additional_configs.yml', 'r') as file:
        yaml_content = yaml.safe_load(file)
        port = yaml_content['GLOBAL_PORT']
        ehrbase_baseurl = os.environ.get('EHRBASE_BASE_URL', f'http://localhost:{port}')
        json_obj = \
            {
                "GLOBAL_PORT": port,
                "BASEURL": os.environ.get('BASEURL', f'{ehrbase_baseurl}/ehrbase/rest/openehr/v1'),
                "ECISURL": os.environ.get('ECISURL', f'{ehrbase_baseurl}/ehrbase/rest/ecis/v1'),
                "ADMIN_BASEURL": os.environ.get('ADMIN_BASEURL', f'{ehrbase_baseurl}/ehrbase/rest/admin'),
                "HEARTBEAT_URL": os.environ.get('HEARTBEAT_URL', f'{ehrbase_baseurl}/ehrbase/rest/status'),
                "PLUGIN_URL": os.environ.get('PLUGIN_URL', f'{ehrbase_baseurl}/ehrbase/plugin'),
                "RABBITMQ_URL": os.environ.get('RABBITMQ_URL', "http://127.0.0.1:15672/api"),
                "KAFKA_URL": os.environ.get('KAFKA_URL', "http://127.0.0.1:8082")
            }
    return json_obj