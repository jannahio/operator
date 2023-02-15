---
layout: page
title: Storage
permalink: /storage/
order: 2
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.storage.tasks %}
Task items to be completed
<table>
  <tr>
        <th>
         Task
        </th>
  </tr>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.storage.tasks %}
        <tr>
            <td><pre>
{{ task_item.name }}
               </pre>
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}