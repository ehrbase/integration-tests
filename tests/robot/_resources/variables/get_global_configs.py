import yaml

def get_variables():
    with open('robot/_resources/variables/additional_configs.yml', 'r') as file:
        yaml_content = yaml.safe_load(file)
        port = yaml_content['GLOBAL_PORT']
        json_obj = \
            {
                "GLOBAL_PORT":port,
                "BASEURL": f'http://localhost:{port}/ehrbase/rest/openehr/v1',
                "ECISURL": f'http://localhost:{port}/ehrbase/rest/ecis/v1',
                "ADMIN_BASEURL": f'http://localhost:{port}/ehrbase/rest/admin',
                "HEARTBEAT_URL": f'http://localhost:{port}/ehrbase/rest/status',
                "PLUGIN_URL": f'http://localhost:{port}/ehrbase/plugin',
                "RABBITMQ_URL": "http://127.0.0.1:15672/api"
             }
    return json_obj
