<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>开发手册</li>
      </ul>
    </div>
    <div class='inner topic'>
      <div class="topic_content">
        <%- markdown([[
## 开发手册正在开发中，近期发布，敬请期待。
]]) %>
      </div>
    </div>
  </div>
</div>
