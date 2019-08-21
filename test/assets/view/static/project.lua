<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>开源项目</li>
      </ul>
    </div>
    <div class='inner topic'>
      <div class="topic_content">
        <%- markdown_file("skynetlua/project.md") %>
      </div>
    </div>
  </div>
</div>
