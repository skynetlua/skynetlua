<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'><%- user.loginname %> 收藏的话题</li>
      </ul>
    </div>
    <div class='inner no-padding'>
      <% if type(topics) == "table" and #topics > 0 then %>
      <%- partial('../topic/list', {topics = topics, pages = pages, current_pages = current_page, base = '/user/' .. user.loginname .. '/collections' }) %>
      <% else %>
      <p>找不到话题 (T_T)</p>
      <% end %>
    </div>
  </div>
</div>
