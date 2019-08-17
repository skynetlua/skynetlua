<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'><a href="/user/<%- user.loginname %>"><%- user.loginname %>的主页</a></li>
      </ul>
    </div>
  </div>
  <div class='panel'>
    <div class="header"><%- user.loginname %> 参与的话题</div>
    <div class="inner padding">
    <% if topics and #topics > 0 then %>
    <%- partial('../topic/list', {topics = topics,pages = pages,current_pages = current_page,base = '/user/'..user.loginname..'/replies'}) %>
    <% else %>
    <div class='inner'>
      <p>无话题</p>
    </div>
    <% end %>
  </div>
  </div>
</div>

