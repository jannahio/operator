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

{% if provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.laptop.provision_scripts %}
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
{% for provision_script in provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.laptop.provision_scripts %}
        <tr>
            <td>
{{ provision_script.name | replace("\n","<br>") }}
            </td>
            <td>
                <pre>
                    <code>
{{ provision_script.description | replace("\n","<br>") }}
                    </code>
                </pre>
            </td>
            <td>
{{ provision_script.comments | replace("\n","<br>")}}
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}


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



{% if provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.laptop.make_commands %}
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
{% for make_command in provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.laptop.make_commands %}
        <tr><td><pre>
{{ make_command.name }}
                </pre>
            </td>
            <td><pre>
{{ make_command.description | replace("\n","<br>") }}
                </pre>
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}
