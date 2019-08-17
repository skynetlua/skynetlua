<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'><%- user.loginname %> 关注的人</li>
      </ul>
    </div>
    <div class='inner'>
      <% if #users > 0 then %>
      <%- partial('../user/user', {collection = users, as = 'user'}) %>
      <% else %>
      <p>没有关注任何人</p>
      <% end %>
    </div>
  </div>
</div>
