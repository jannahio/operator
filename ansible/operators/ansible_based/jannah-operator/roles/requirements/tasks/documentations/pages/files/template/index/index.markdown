---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

[Jannah Get Start](/boot/)

<table>
    <tr>
        <th>
            Boot
        </th>
        <th>
            Network
        </th>
        <th>
            Storage
        </th>
        <th>
            Compute
        </th>
        <th>
            UX
        </th>
        <th>
            Feedback
        </th>
     </tr>
    <tr>
        <td>
{% for make_command in provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.laptop.make_commands %}
<pre>{{ make_command.name }}</pre>
{% endfor %}
        </td>
        <td>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.network.tasks %}
<pre>{{ task_item.name }}</pre>
{% endfor %}
        </td>
        <td>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.storage.tasks %}
<pre>{{ task_item.name }}</pre>
{% endfor %}
        </td>
        <td>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.compute.tasks %}
<pre>{{ task_item.name }}</pre>
{% endfor %}
        </td>
        <td>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.ux.tasks %}
<pre>{{ task_item.name }}</pre>
{% endfor %}
        </td>
        <td>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.feedback.tasks %}
<pre>{{ task_item.name }}</pre>
{% endfor %}
        </td>
     </tr>
</table>