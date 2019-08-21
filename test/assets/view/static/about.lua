<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>关于</li>
      </ul>
    </div>
    <div class='inner topic'>
      <div class="topic_content">
        <%- markdown_file("skynetlua/about.md") %>
      </div>
    </div>
  </div>
</div>
