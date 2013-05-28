<%def name="field_select_one(datum)">
<ul class="browse-filter-options">
    % for identifier, obj in datum.iter_options():
    <li><label class="browse-pill"><input type="checkbox" name="${datum.key}" value="${identifier}"><span>${caller.body(obj)}</span></label></li>
    % endfor
</ul>
</%def>

<%def name="field_select_several(name, values)">
<ul class="browse-filter-options">
    % for identifier, obj in values:
    <li><label class="browse-pill"><input type="checkbox" name="${name}" value="${identifier}"
        % if identifier in request.GET.getall(name):
        checked="checked"
        % endif
        ><span>${caller.body(obj)}</span>
    </label></li>
    % endfor
</ul>
</%def>
