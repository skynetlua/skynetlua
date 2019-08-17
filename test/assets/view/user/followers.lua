<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>关注 <%- user.loginname %> 的人</li>
      </ul>
    </div>
    <div class='inner'>
      <% if #users > 0 then %>
      <%- partial('../user/user', { collection = users, as = 'user' }) %>
      <% else %>
      <p>还没有任何人关注他</p>
      <% end %>
    </div>
  </div>
</div>
