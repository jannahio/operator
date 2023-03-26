multipass delete --all -p
multipass launch -n jannah-charm-operator-amd64 -m 15g -c 8 -d 800G  charm-dev
multipass mount /Users/osmanjalloh/IdeaProjects jannah-charm-operator-amd64:/home/ubuntu/IdeaProjects
multipass exec jannah-charm-operator-amd64 -- sudo apt -y update
multipass exec jannah-charm-operator-amd64 -- sudo apt install -y make \
python3-dev \
python3-pip \
virtualenv
multipass exec jannah-charm-operator-amd64 -- sudo snap install yq
#multipass exec jannah-charm-operator-amd64 -- ls -lrt /home/ubuntu/
#multipass exec jannah-charm-operator-amd64 -- pip3 install --user -r /home/ubuntu/IdeaProjects/operator/charm/requirements.txt
#multipass exec jannah-charm-operator-amd64 -- cd /home/ubuntu/IdeaProjects/operator && make jannah-config
#multipass shell jannah-charm-operator-amd64
