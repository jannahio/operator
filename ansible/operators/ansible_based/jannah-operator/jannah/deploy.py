# :maintainer:    Osman Jalloh <Os@jallohmedia>
# :maturity:      new
# :depends:       xxxxxx
# :platform:      all
from __future__ import absolute_import
from __future__ import print_function


class JannahDeploy(object):
    def __init__(self):
        pass

   def execute(self):
       _status = "Deployed"
       print(_status)
       return _status

def main():
    _deployer: JannahDeploy = JannahDeploy()
    _deployer.execute()

if __name__ == '__main__':
    main()
