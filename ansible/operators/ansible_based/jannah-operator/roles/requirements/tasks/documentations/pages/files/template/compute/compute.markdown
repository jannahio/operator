---
layout: page
title: Compute
permalink: /compute/
order: 4
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.compute.tasks %}
<table>
  <tr>
        <th>
         Task items to be completed
        </th>
  </tr>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.compute.tasks %}
        <tr>
            <td><pre>
{{ task_item.name }}
               </pre>
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}