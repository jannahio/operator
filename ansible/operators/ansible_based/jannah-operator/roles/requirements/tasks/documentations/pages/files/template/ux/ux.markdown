---
layout: page
title: UX
permalink: /ux/
order: 5
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.ux.tasks %}
Task items to be completed
<table>
  <tr>
        <th>
         Task
        </th>
  </tr>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.ux.tasks %}
        <tr>
            <td><pre>
{{ task_item.name }}
               </pre>
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}
