import string
import random
import sys

if len(sys.argv) != 2:
    print("usage: " + sys.argv[0] + " secretfile")
    sys.exit(1)

with open(sys.argv[1], 'w') as f:
    key = ''.join([random.SystemRandom().choice(string.ascii_letters + string.digits + string.punctuation) for _ in range(50)])
    f.write(key)
    f.close()
