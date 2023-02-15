---
layout: page
title: Network
permalink: /network/
order: 3
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.network.tasks %}
Task items to be completed
<table>
  <tr>
        <th>
         Task
        </th>
  </tr>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.network.tasks %}
        <tr>
            <td><pre>
{{ task_item.name }}
               </pre>
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}
