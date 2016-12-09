---
layout: page
title: Binaries
---

{% assign all_versions = "" %}
{% unless site.collections.binaries.docs == nil %}

There is no binary provided for this package ! 

{% else %}

Available binaries classified by version:

	{% for binary in site.binaries %}
		{% unless all_versions contains binary.version %}
## {{ binary.version }}

Available for platforms:
			{% for bin in site.binaries %}
				{% if bin.version == binary.version %}
+ {{ bin.platform }}
				{% endif %}
			{% endfor %}
			
			{% assign all_versions = all_versions | append: ";" | append: binary.version %}
		{% endunless %}
	{% endfor %}
{% endunless %}


