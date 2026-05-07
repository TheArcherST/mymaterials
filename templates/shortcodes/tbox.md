<style>
.tbox-container {
    border: 1px solid white; 
    border-radius: 2px;
    overflow: hidden;
    padding: 1em;
    margin: 2em 0;
}

.tbox-header {
    font-size: 1.2em;
}

</style>

{% set anchor = id | default(value=header | slugify) %}

<div id="{{ anchor }}" class="tbox-container">
<div class="tbox-header">
<a class="tbox-anchor" href="#{{ anchor }}" aria-label="Ссылка на этот блок">
<span class="tbox-title">{{ header | safe }}</span>
</a>
</div>
<div class="tbox-body">

{{ body | safe }}

</div>
</div>

