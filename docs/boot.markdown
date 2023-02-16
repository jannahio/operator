---
layout: page
title: Boot
permalink: /boot/
order: 1
---
End to End Deployment of Jannah Infrastructor
---------------------------------------------

<h3>New Developer Onboarding</h3>
*Provision a MacBook Pro (Ventura 13.2) for Jannah Development*

Assuming a new developer joining the team.  We have created Apple Automator Scripts
to install the basic software tools to provision the laptop for developing 
Jannah code. 

You can find the Apple Automator scripts in the [laptop-provisioning] folder.
<table>
        <th>
        Provision with Applescript
        </th>
        <th>
        Description
        </th>
        <th>
        Comments
        </th>
        <tr>
            <td>
1_Apple_Developer_Tools
            </td>
            <td>
                <pre>
                    <code>
xcode-select --install;<br>python3 --version;<br>git --version<br>
                    </code>
                </pre>
            </td>
            <td>
Install Apple Developer tools. i.e xcode, git, python3 etc.<br>
            </td>
        </tr>
        <tr>
            <td>
2_Homebrew_Cask_Github_Client
            </td>
            <td>
                <pre>
                    <code>
curl https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh;<br>./install.sh;<br>/opt/homebrew/bin/brew shellenv >> ~/.zprofile;<br>/opt/homebrew/bin/brew shellenv<br>
                    </code>
                </pre>
            </td>
            <td>
Install Homebrew, Cask, and Github.com client.<br>
            </td>
        </tr>
        <tr>
            <td>
3_Input_Directory_Github_Token
            </td>
            <td>
                <pre>
                    <code>
mkdir -vp ~/.jannah-operator;<br>echo "ghp_Your_Github_Token" > ~/.jannah-operator/git_token.txt;<br>source ~/.zprofile;<br>gh auth login --with-token < ~/.jannah-operator/git_token.txt<br>
                    </code>
                </pre>
            </td>
            <td>
<a href="https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token" title="Generate a Github token"><br>Generate a Github.com token</a> and login to Github.<br>
            </td>
        </tr>
        <tr>
            <td>
4_Clone_Jannah_Code
            </td>
            <td>
                <pre>
                    <code>
mkdir -vp ~/working/jannahio;<br>source ~/.zprofile;<br>cd ~/working/jannahio;<br>gh repo clone jannahio/operator<br>
                    </code>
                </pre>
            </td>
            <td>
Create a 'working' directory, and clone the Jannah repository.<br>
            </td>
        </tr>
        <tr>
            <td>
5_Install_IntelliJ_IDE
            </td>
            <td>
                <pre>
                    <code>
hdiutil mount ~/Downloads/ideaIC-2022.3.2-aarch64.dmg;<br>cp -R '/Volumes/IntelliJ IDEA CE/IntelliJ IDEA CE.app' /Applications;<br>hdiutil unmount "/Volumes/IntelliJ IDEA CE/IntelliJ IDEA CE.app";<br>rm ~/Downloads/ideaIC-2022.3.2-aarch64.dmg;<br>
                    </code>
                </pre>
            </td>
            <td>
Download, mount, and copy IntelliJ IDE<br>to your MacOS Applications folder.<br>
            </td>
        </tr>
        <tr>
            <td>
6_Install_VS_Code_IDE
            </td>
            <td>
                <pre>
                    <code>
cd $HOME/Downloads<br>curl -v -o VSCode-darwin-universal.zip [VS Code IDE]<br>unzip VSCode-darwin-universal.zip;<br>cp -R "$HOME/Downloads/Visual Studio Code.app" /Applications/;<br>cd $HOME/Downloads;<br>rm -rf "$HOME/Downloads/Visual Studio Code.app";<br>rm "VSCode-darwin-universal.zip"<br>
                    </code>
                </pre>
            </td>
            <td>
Download [VS Code IDE], unzip, and copy<br>to your MacOS Applications folder.<br>
            </td>
        </tr>
        <tr>
            <td>
7_Install_Docker_Desktop
            </td>
            <td>
                <pre>
                    <code>
cd $HOME/Downloads;<br>curl -v -o Docker.dmg [Docker Desktop];<br>hdiutil mount ~/Downloads/Docker.dmg;<br>cp -R "/Volumes/Docker/Docker.app" /Applications/;<br>rm ~/Downloads/Docker.dmg<br>
                    </code>
                </pre>
            </td>
            <td>
Download, mount, and copy Docker Desktop<br>to your MacOS Applications folder.<br>
            </td>
        </tr>
        <tr>
            <td>
8_Install_Google_Chrome
            </td>
            <td>
                <pre>
                    <code>
cd $HOME/Downloads;<br>curl -v -o Docker.dmg [Google Chrome];<br>hdiutil mount ~/Downloads/googlechrome.dmg;<br>cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/;<br>hdiutil unmount "/Volumes/Google Chrome/Google Chrome.app";<br>rm ~/Downloads/googlechrome.dmg<br>
                    </code>
                </pre>
            </td>
            <td>
Download, mount, and copy Chrome<br>to your MacOS Applications folder.<br>
            </td>
        </tr>
        <tr>
            <td>
9_Install_Yaml_yq
            </td>
            <td>
                <pre>
                    <code>
source ~/.zprofile;<br>brew install yq<br>
                    </code>
                </pre>
            </td>
            <td>
Install yq for yaml command line editing.<br>
            </td>
        </tr>
        <tr>
            <td>
10_Install_Ansible
            </td>
            <td>
                <pre>
                    <code>
source ~/.zprofile;<br>brew install ansible<br>brew install virtualenv<br>brew install wget<br>brew install operator-sdk<br>
                    </code>
                </pre>
            </td>
            <td>
Installs Ansible and related tooling for automation tasks.<br>
            </td>
        </tr>
</table>


You can find the source code for Jannah Operator at GitHub:
[jannah-operator] 



<h3>Make Jannah</h3>
*Using Make commands to startup Jannah Operator*

Jannah needs Github.com and Dockerhub.com credentials
to bootstrap itself. See [Generating Docker Tokens].

Export your credentials as environment variables. Jannah will encrypt them as 
Ansible vault secrets at runtime.
<pre>
    <code>
export GITHUB_USERNAME="YOUR_GITHUB_USERNAME";
export GITHUB_TOKEN="YOUR_GITHUB_TOKEN";
export DOCKERHUB_USERNAME="YOUR_DOCKERHUB_USERNAME";
export DOCKERHUB_TOKEN="dckr_YOUR_DOCKER_TOKEN";
export ANSIBLE_VAULT_DEFAULT_PASSWORD="YOUR_VAULT_DEFAULT_PASSWORD"; 
    </code>
</pre>
For more detail on ANSIBLE_VAULT_DEFAULT_PASSWORD, see [Creating Encrypted Ansible Variables].


On the same shell terminal change into the Jannah
working directory:
<pre>
    <code>
cd ~/working/jannahio/operator;
    </code>
</pre>

For day 1 day 2 operations type:
<pre>
make jannah-day1-day2;
</pre>
_'make jannah-day1-day2'_ will execute the following command sequence (top to bottom), to prepare your laptop for Jannah Development.



Note: This will install multipass for managing
local cloud instances on your laptop. It will prompt you for your user password.
<table>
  <tr>
        <th>
         Command Sequence
        </th>
        <th>
        Description
        </th>
  </tr>
        <tr><td><pre>
make jannah-boot-credentials;
                </pre>
            </td>
            <td><pre>
Confirms that ~/.jannah-operator/ exists;<br>Copies molecule.bootstrap.template.yml to ~/.jannah-operator/;<br>Encrypts GITHUB_USERNAME as an Ansible vault variable;<br>Encrypts GITHUB_TOKEN as an Ansible vault variable;<br>Encrypts DOCKERHUB_USERNAME as an Ansible vault variable;<br>Encrypts DOCKERHUB_TOKEN as an Ansible vault variable;<br>
                </pre>
            </td>
        </tr>
        <tr><td><pre>
make jannah-python-backup;
                </pre>
            </td>
            <td><pre>
make jannah-boot-credentials;<br>Backup any previous jannah-python virtual environment.<br>Backup any previous molecule file.<br>
                </pre>
            </td>
        </tr>
        <tr><td><pre>
make jannah-python-clean;
                </pre>
            </td>
            <td><pre>
jannah-python-backup;<br>Backup and remove the dev python virtual environment<br>
                </pre>
            </td>
        </tr>
        <tr><td><pre>
make jannah-python;
                </pre>
            </td>
            <td><pre>
make jannah-boot-credentials;<br>Creates a python virtual environment for working with Jannah.<br>Installs required Python modules for bootstrapping.<br>
                </pre>
            </td>
        </tr>
        <tr><td><pre>
make jannah-config;
                </pre>
            </td>
            <td><pre>
Generates molecule configuration files for all down stream Ansible Playbook roles.<br>The same molecule yaml file is used to hydrate the configuration of the Python Charm.<br>This keeps one source of configuration for all down stream components. <br>- roles/jannahio.bootstrap/molecule/default/molecule.yml.<br>- operators/ansible_based/jannah-operator/molecule/default/molecule.yml.<br>- roles/jannahio.bootstrap/molecule/default/.env.<br>- operators/ansible_based/jannah-operator/molecule/default/.env.<br>- operators/ansible_based/jannah-operator/roles/install/defaults/main.yml.<br>- operators/ansible_based/jannah-operator/roles/requirements/defaults/main.yml.<br><br>Ansible role tags: <br>- d1d2-generate-molecule-configurations<br>
                </pre>
            </td>
        </tr>
        <tr><td><pre>
make jannah-day1-day2;
                </pre>
            </td>
            <td><pre>
brew upgrade;<br>brew install --cask multipass;<br>brew install kdoctor  cocoapods;<br>
                </pre>
            </td>
        </tr>
</table>
