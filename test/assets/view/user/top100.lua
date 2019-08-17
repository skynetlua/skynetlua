<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>Top100 积分榜</li>
      </ul>
    </div>
    <div class='inner'>
      <% if type(users) == 'table' and #users > 0 then %>
      <table class='table table-condensed table-striped'>
        <thead>
          <th>#</th><th>用户名</th><th>积分</th><th>主题数</th><th>评论数</th>
        </thead>
        <tbody>
        <%- partial('./top100_user',{collection = users, as = 'user'}) %>
        </tbody>
      </table>
      <% else %>
      <p>还没有用户</p>
      <% end %>
    </div>
  </div>
</div>
