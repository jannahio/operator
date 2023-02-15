---
layout: page
title: Feedback
permalink: /feed-back/
order: 6
---
{% if provisioner.inventory.group_vars.all.Jannah.stages.feedback.tasks %}
Task items to be completed
<table>
  <tr>
        <th>
         Task
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