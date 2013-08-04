<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">${location.name} [Place in ${location.region.name}] - veekun</%block>

## XXX should link to other places in other regions with the same name

% for area, area_encounters in fudged_encounters.partition_by_area():
<% versions = area_encounters.collect_versions() %>
<section>
    % if area.name:
    <h1>${location.name}: ${area.name}</h1>
    % else:
    <h1>${location.name}</h1>
    % endif

    <table class="table-pretty pokemon-encounter-table">
        <col class="-col-version">

      % for method, method_encounters in area_encounters.partition_by_method():
      <tbody>
        <tr class="header">
            <th></th>
          % for version in versions:
            <th colspan="2">${lib.version_icon(version)}</th>
          % endfor
        </tr>

        <tr class="subheader">
            <th colspan="${1 + 2 * len(versions)}">${method.name}</th>
        </tr>

        % for (pokemon, condition_values), pokemon_encounters in method_encounters.partition_by_pokemon_condition_values():
        <% version_encounters = dict(pokemon_encounters.partition_by_version()) %>
        <tr>
            <th class="encounter-pokemon td-absolute-root">
                <div class="td-absolute-wrapper">
                <a href="${request.resource_url(pokemon)}">${pokemon.name}</a>
                <div class="cell-sprite-peek"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.species.id}.png"></div>
              ## TODO this block doesn't take into account multiple condition
              ## values, though that shouldn't happen (so far)
              % if condition_values:
                <h4>
                  % for condition_value in condition_values:
                    ${condition_value.name}
                  % endfor
                </h4>
              % endif
                </div>
            </th>

          % for version in versions:
            % if version in version_encounters:
            <% level_ranges = version_encounters[version].collect_level_ranges() %>

            <td class="rarity
                % if level_ranges.total_rarity >= 50:
                rarity-vermin
                % elif level_ranges.total_rarity >= 15:
                rarity-common
                % elif level_ranges.total_rarity >= 5:
                rarity-uncommon
                % else:
                rarity-rare
                % endif
            ">${level_ranges.total_rarity}%</td>
            <td class="-level-range">
                <% left, right = level_ranges.total_range %>
                % if left == right:
                L${left}
                % else:
                L${left}–${right}
                % endif
            </td>

            % else:
            <td colspan="2"></td>
            % endif
          % endfor
        </tr>
        % endfor
      </tbody>
      % endfor
    </table>
</section>
% endfor
