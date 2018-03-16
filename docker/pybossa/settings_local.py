DEBUG = False
PORT = 5000
SECRET = 'foobar'
SECRET_KEY = 'my-session-secret'
SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:postgres@postgres-master/postgres'
ITSDANGEROUSKEY = 'its-dangerous-key'

BRAND = 'StuffCo'
TITLE = 'Thing Tagger'
DESCRIPTION = 'For Thing Tagging'

ENFORCE_PRIVACY = False

REDIS_SENTINEL = [('redis-sentinel', 26379)]
REDIS_MASTER = 'mymaster'
REDIS_DB = 0
REDIS_KEYPREFIX = 'pybossa_cache'

UPLOAD_METHOD = 'local'
UPLOAD_FOLDER = 'uploads'

ACCOUNT_CONFIRMATION_DISABLED = True

LIMIT = 1000000
