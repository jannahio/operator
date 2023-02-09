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
xcode-select --install;
python3 --version;
git --version
                    </code>
                </pre>
            </td>
            <td>
Install Apple Developer tools. i.e xcode, git, python3 etc.
            </td>
        </tr>
        <tr>
            <td>
            2_Homebrew_Cask_Github_Client
            </td>
            <td>
                <pre>
                    <code>
curl https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh;
./install.sh;
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.zprofile;
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile;
eval "$(/opt/homebrew/bin/brew shellenv)"
                    </code>
                </pre>
            </td>
            <td>
Install Homebrew, Cask, and Github.com client.
            </td>
        </tr>
        <tr>
            <td>
            3_Input_Directory_Github_Token
            </td>
            <td>
                <pre>
                    <code>
mkdir -vp ~/.jannah-operator;
echo "ghp_Your_Github_Token" > ~/.jannah-operator/git_token.txt;
source ~/.zprofile;
gh auth login --with-token < ~/.jannah-operator/git_token.txt
                    </code>
                </pre>
            </td>
            <td>
                <a 
                    href="https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token" title="Generate a Github token">
                    Generate a Github.com token
                </a> 
                and login to Github.
            </td>
        </tr>
        <tr>
            <td>
            4_Clone_Jannah_Code
            </td>
            <td>
                <pre>
                    <code>
mkdir -vp ~/working/jannahio;
source ~/.zprofile;
cd ~/working/jannahio;
gh repo clone jannahio/operator
                    </code>
                </pre>
            </td>
            <td>
Create a 'working' directory, and clone the Jannah repository.
            </td>
        </tr>
        <tr>
            <td>
            5_Install_IntelliJ_IDE
            </td>
            <td>

Download [IntelliJ IDE] 
                <pre>
                <code>
hdiutil mount ~/Downloads/ideaIC-2022.3.2-aarch64.dmg;
cp -R "/Volumes/IntelliJ IDEA CE/IntelliJ IDEA CE.app" /Applications;
hdiutil unmount "/Volumes/IntelliJ IDEA CE/IntelliJ IDEA CE.app";
rm ~/Downloads/ideaIC-2022.3.2-aarch64.dmg
                </code>
                </pre>
            </td>
            <td>
                Download, mount, and copy IntelliJ IDE 
                to your MacOS Applications folder.
            </td>
        </tr>
        <tr>
            <td>
                6_Install_VS_Code_IDE
            </td>
            <td>
                <pre>
                    <code>
cd $HOME/Downloads
curl -v -o VSCode-darwin-universal.zip [VS Code IDE]
unzip VSCode-darwin-universal.zip;
cp -R "$HOME/Downloads/Visual Studio Code.app" /Applications/;
cd $HOME/Downloads;
rm -rf "$HOME/Downloads/Visual Studio Code.app";
rm "VSCode-darwin-universal.zip"
                    </code>
                </pre>
            </td>
            <td>
Download [VS Code IDE], unzip, and copy VS Code IDE
to your MacOS Applications folder.
</td>
        </tr>
        <tr>
            <td>
            7_Install_Docker_Desktop
            </td>
            <td>
                <pre>
                    <code>

cd $HOME/Downloads
curl -v -o Docker.dmg [Docker Desktop];
hdiutil mount ~/Downloads/Docker.dmg;
cp -R "/Volumes/Docker/Docker.app" /Applications/;
rm ~/Downloads/Docker.dmg
                    </code>
                </pre>
            </td>
            <td>
                Download, mount, and copy Docker Desktop 
                to your MacOS Applications folder.
            </td>
        </tr>
        <tr>
            <td>
            8_Install_Google_Chrome
            </td>
            <td>
                <pre>   
                    <code>

cd $HOME/Downloads;
curl -v -o Docker.dmg [Google Chrome];
hdiutil mount ~/Downloads/googlechrome.dmg;
cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/;
hdiutil unmount "/Volumes/Google Chrome/Google Chrome.app";
rm ~/Downloads/googlechrome.dmg
                    </code>
                </pre>
            </td>
            <td>
Download, mount, and copy Chrome
to your MacOS Applications folder.
            </td>
        </tr>
<tr>
<td>
9_Install_Yaml_yq
</td>
<td>
<pre>   
<code>
source ~/.zprofile;
brew install yq
</code>
</pre>
</td>
<td>
Install yq for yaml command line editing.
</td>
</tr>
<tr>
<td>
10_Install_Ansible
</td>
<td>
<pre>   
<code>
source ~/.zprofile
brew install ansible
brew install virtualenv
brew install wget
brew install operator-sdk
</code>
</pre>
</td>
<td>
Installs Ansible for automation tasks.
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
    <tr>
        <td>
         <pre>
            <code>
make jannah-boot-credentials;
            </code>
         </pre>
        </td>
        <td>
<pre>
Confirms that ~/.jannah-operator/ exists.
Copies molecule.bootstrap.template.yml to ~/.jannah-operator/
Encrypts GITHUB_USERNAME as an Ansible vault variable;
Encrypts GITHUB_TOKEN as an Ansible vault variable;
Encrypts DOCKERHUB_USERNAME as an Ansible vault variable;
Encrypts DOCKERHUB_TOKEN as an Ansible vault variable;
</pre>
        </td>
    </tr>
    <tr>
        <td>
<pre>
    <code>
make jannah-python-backup;
    </code>
</pre>
        </td>
             <td>
<pre>
make jannah-boot-credentials;
Backup any previous jannah-python virtual environment.
Backup any previous molecule file.
</pre>
        </td>
    </tr>
    <tr>
        <td>
            <pre>   
                <code>
make jannah-python-clean;
                </code>
            </pre>
        </td>
            <td>
                <pre>
make jannah-python-backup;
Delete any previous jannah-python virtual environment.
Delete previous molecule configuration.
                </pre>
        </td>
    </tr>
    <tr>
        <td>
            <pre>
                <code>
make jannah-python;
                </code>
            </pre>
        </td>
        <td>    
            <pre>
make jannah-boot-credentials;
Creates a python virtual environment for working with Jannah.
Installs required Python modules for bootstrapping.
            </pre>
        </td>
    </tr>
    <tr>
        <td>
            <pre>
                <code>
make jannah-config;
                </code>
            </pre>
        </td>
        <td>
            <pre>
Generates molecule configuration files for all down stream Ansible Playbook roles.
The same molecule yaml file is used to hydrate the configuration of the Python Charm.
This keeps one source of configuration for all down stream components. 
- roles/jannahio.bootstrap/molecule/default/molecule.yml.
- operators/ansible_based/jannah-operator/molecule/default/molecule.yml.
- roles/jannahio.bootstrap/molecule/default/.env.
- operators/ansible_based/jannah-operator/molecule/default/.env.
- operators/ansible_based/jannah-operator/roles/install/defaults/main.yml.
- operators/ansible_based/jannah-operator/roles/requirements/defaults/main.yml.

Ansible role tags: 
- d1d2-generate-molecule-configurations
            </pre>
        </td>
    </tr>
    <tr>
        <td>
            <pre>
                <code>
  make jannah-day1-day2;
                </code>
            </pre>
        </td>
        <td>
            <pre>
  make jannah-config;
  brew upgrade;
  brew install --cask multipass;
            </pre>
        </td>
    </tr>
</table>



[jannah-operator]: https://github.com/jannahio/operator
[jannah-organization]: https://github.com/jannahio
[laptop-provisioning]: https://github.com/jannahio/operator/ansible/roles/jannahio.day1day2/tasks/laptop_provisioning/
[IntelliJ IDE]: https://download.jetbrains.com/idea/ideaIC-2022.3.2-aarch64.dmg?_gl=1*1m2uf1n*_ga*MTU0NTQ0NDIwMS4xNjc1NDQ4MDAy*_ga_9J976DJZ68*MTY3NTQ0ODAwMS4xLjEuMTY3NTQ0ODEyOS4wLjAuMA..&_ga=2.260209485.1373883433.1675448002-1545444201.1675448002
[VS Code IDE]: https://az764295.vo.msecnd.net/stable/e2816fe719a4026ffa1ee0189dc89bdfdbafb164/VSCode-darwin-universal.zip
[Google Chrome]: https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg
[Docker Desktop]: https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module
[Molecule Configuration]: https://molecule.readthedocs.io/en/latest/configuration.html
[Creating Encrypted Ansible Variables]: https://docs.ansible.com/ansible/latest/vault_guide/vault_encrypting_content.html#creating-encrypted-variables
[Generating Docker Tokens]: https://docs.docker.com/docker-hub/access-tokens/
