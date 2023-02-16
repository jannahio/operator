---
layout: post
title:  "Introducing Jannah Operator!"
date:   2023-01-23 21:47:49 -0800
categories: jekyll update
---
Introducing Jannah.io Operator.

Jannah.io is a lab for developing cloud native software solutions.

Jannah.io itself, is implemented as a software application.  Software applications developed
on the Jannah platform would be somewhat feature clones of Jannah itself.

This  kubernetes operator is tooling to manage end to end
lifecycle management of Jannah infrastructure between public, and
private clouds.

Join us on this journey into software development, and the business of data.

{% if provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.url_artifacts %}
{% for url_artifact in provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.url_artifacts %}
{{ url_artifact.name }}: {{ url_artifact.url }}
{% endfor %}
{% endif %}