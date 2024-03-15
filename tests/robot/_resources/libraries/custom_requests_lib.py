from RequestsLibrary import RequestsLibrary

from robot.api.deco import keyword

authorization_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9' \
                          '.eyJleHAiOjE2MDA3NzEwODYsImlhdCI6MTY' \
                          'wMDc3MDc4NiwidG50IjoiYTk1ZjAxNDktYzQ5' \
                          'Ni00NzMzLTg3MDMtMzljOTExNTc4MDkwIiwiY' \
                          'XV0aF90aW1lIjoxNjAwNzcwNzg2LCJqdGkiOiI' \
                          '3NThkYzZhNC0wMWQ5LTRkN2MtYjdhMy02YmNiY' \
                          '2ZmNTkzNTciLCJpc3MiOiJodHRwOi8vbG9jYWx' \
                          'ob3N0OjgwODEvYXV0aC9yZWFsbXMvZWhyYmFz' \
                          'ZSIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI5N' \
                          'zgzNTBkNC04NmFjLTQ2MzEtYTRjNC02Njc2Mjk' \
                          '0YWMzZmQiLCJ0eXAiOiJCZWFyZXIiLCJhenAi' \
                          'OiJlaHJiYXNlLXBvc3RtYW4iLCJzZXNzaW9uX3' \
                          'N0YXRlIjoiODI0YjhlNGYtMWIzMS00OTNiLWE2O' \
                          'WQtYjc4MzIzMWYwNGM3IiwiYWNyIjoiMSIsInJlY' \
                          'WxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2' \
                          'FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwidXN' \
                          'lciJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291' \
                          'bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiL' \
                          'CJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcH' \
                          'JvZmlsZSJdfX0sInNjb3BlIjoib3BlbmlkIGVtYWl' \
                          'sIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1Z' \
                          'SwibmFtZSI6IkVIUmJhc2UgVXNlciIsInByZWZlcnJ' \
                          'lZF91c2VybmFtZSI6InVzZXIiLCJnaXZlbl9uYW1lI' \
                          'joiRUhSYmFzZSIsImZhbWlseV9uYW1lIjoiVXNlciI' \
                          'sImVtYWlsIjoidXNlckBlaHJiYXNlLm9yZyJ9.eYLu' \
                          'vX-BlzT0FKeJI8s0MNbeJT6WtPOEH8ruwTPMB8c'


class custom_requests_lib(RequestsLibrary):

    @keyword("POST On Session")
    def post_on_session(self, alias, url, data=None, json=None,
                        expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token
        #print(kwargs['headers'])

        # Call the original implementation of POST On Session
        return super().post_on_session(alias, url, data, json, expected_status, msg, **kwargs)

    @keyword("GET On Session")
    def get_on_session(self, alias, url, params=None,
                       expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token

        return super().get_on_session(alias, url, params, expected_status, msg, **kwargs)

    @keyword("PUT On Session")
    def put_on_session(self, alias, url, data=None, json=None,
                       expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token

        return super().put_on_session(alias, url, data, json, expected_status, msg, **kwargs)

    @keyword('DELETE On Session')
    def delete_on_session(self, alias, url,
                          expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token

        return super().delete_on_session(alias, url, expected_status, msg, **kwargs)

    @keyword("PATCH On Session")
    def patch_on_session(self, alias, url, data=None, json=None,
                         expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token

        return super().patch_on_session(alias, url, data, json, expected_status, msg, **kwargs)

    @keyword("HEAD On Session")
    def head_on_session(self, alias, url,
                        expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token

        return super().head_on_session(alias, url, expected_status, msg, **kwargs)

    @keyword("OPTIONS On Session")
    def options_on_session(self, alias, url,
                           expected_status=None, msg=None, **kwargs):
        if 'headers' not in kwargs:
            kwargs['headers'] = {}

        # Check if 'Authorization' header is already present
        headers = kwargs['headers']
        if 'Authorization' not in headers:
            kwargs['headers']['Authorization'] = 'Bearer ' + authorization_token

        return super().options_on_session(alias, url, expected_status, msg, **kwargs)
