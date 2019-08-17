<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>通知</li>
      </ul>
    </div>
    <div class='inner'>
      <% if the_error then %>
      <div class="alert alert-error">
        <strong><%- the_error %></strong>
      </div>
      <% end %>
      <% if success then %>
      <div class="alert alert-success">
        <strong><%- success %></strong>
      </div>
      <% end %>
      <a href="<%- referer or '/' %>"><span class="span-common">返回</span></a>
    </div>
  </div>
</div>
