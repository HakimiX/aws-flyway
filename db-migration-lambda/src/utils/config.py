import os

def get_env_variable(key, default=None, required=False):
    value = os.getenv(key, default)
    if required and value is None:
        raise EnvironmentError(f"Required environment variable '{key}' is missing.")
    return value

# AWS environment variables
AWS_PROFILE = get_env_variable('AWS_PROFILE', required=False)
AWS_REGION = get_env_variable('AWS_REGION', required=False)

# Application environment variables
LOG_LEVEL = get_env_variable('LOG_LEVEL', 'INFO').upper()