<style>
.tbox-container {
    --tbox-border-color: #24292e;
    border: 1px solid var(--tbox-border-color);
    border-radius: 2px;
    overflow: hidden;
    padding: 1em;
    margin: 2em 0;
}

:root.dark .tbox-container {
    --tbox-border-color: #fff;
}

.tbox-header {
    font-size: 1.2rem;
    margin: 0.5em 0 1em 0;
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
