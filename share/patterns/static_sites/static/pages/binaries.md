---
layout: page
title: Binaries
---


{{site.collections.binaries.docs }}

{% assign all_versions = "" %}
{% unless site.collections.binaries.docs == nil %}

	There is no binary provided for this package ! 

{% else %}

	Here are the binaries provided for this package, classified by version :

	{% for binary in site.collections.binaries.docs %}

		{{ binary.platform }}

		{% assign curr_version = binary.version %}
		{% unless all_versions contains curr_version %}

## {{ curr_version }}: 
			{% for bin in site.collections.binaries.docs %}
				{% if bin.version == curr_version %}
 + {{ bin.platform }}
				{% endif %}
			{% endfor %}
			
			{% assign all_versions = "all_versions ; curr_version" %}

		{% endunless %}
	{% endfor %}
{% endunless %}




