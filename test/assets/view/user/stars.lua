<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>社区达人</li>
      </ul>
    </div>
    <div class='inner'>
      <% if stars and #stars > 0 then %>
      <%- partial('./user',{collection = stars, as = 'user'}) %>
      <% else %>
      <p>还没有社区达人</p>
      <% end %>
    </div>
  </div>
</div>
