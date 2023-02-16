---
layout: page
title: Storage
permalink: /storage/
order: 2
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.storage.tasks %}
<table>
  <tr>
        <th>
         Task items to be completed
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