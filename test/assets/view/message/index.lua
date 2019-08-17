<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>新消息</li>
      </ul>
    </div>
    <% if hasnot_read_messages and #hasnot_read_messages > 0 then %>
    <%- partial('./message', {collection = hasnot_read_messages, as = 'message'}) %>
    <% else %>
    <div class='inner'>
      <p>无消息</p>
    </div>
    <% end %>
  </div>
  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>过往信息</span>
    </div>
    <% if has_read_messages and #has_read_messages > 0 then %>
    <%- partial('./message', {collection = has_read_messages, as = 'message'}) %>
    <% else %>
    <div class='inner'>
      <p>无消息</p>
    </div>
    <% end %>
  </div>
</div>
