import sys
import os

sys.path.insert(0, os.path.abspath(''))

master_doc = 'doc/monitoring/grafana_dashboard'

source_suffix = '.rst'

project = u'Grafana-dashboard'

exclude_patterns = [
    'doc/locale',
    'doc/output',
    'doc/README.md',
    'doc/cleanup.py',
    'doc/requirements.txt',
]

language = 'en'
locale_dirs = ['./doc/locale']
gettext_compact = False
gettext_location = True
