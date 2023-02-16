---
layout: page
title: Feedback
permalink: /feed-back/
order: 6
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.feedback.tasks %}
<table>
  <tr>
        <th>
         Task items to be completed
        </th>
  </tr>
{% for task_item in provisioner.inventory.group_vars.all.Jannah.stages.feedback.tasks %}
        <tr>
            <td><pre>
{{ task_item.name }}
               </pre>
            </td>
        </tr>
{% endfor %}
</table>
{% endif %}