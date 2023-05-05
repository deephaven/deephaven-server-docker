import re
import sys
from auditwheel.main import main
from auditwheel.policy import _POLICIES

for policy in _POLICIES:
  policy['lib_whitelist'].append('libarrow_python.so')
  policy['lib_whitelist'].append('libarrow.so.1200')

if __name__ == '__main__':
  sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
  sys.exit(main())
