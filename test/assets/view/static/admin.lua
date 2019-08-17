<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>管理后台</li>
      </ul>
    </div>
    <div class='inner topic'>
      <div class="topic_content">
        <%- markdown([[

## 管理后台正在开发中，近期发布，敬请期待。

        推荐在centos7系统运行
目前适配的系统：centos7,ubuntu。其他系统尚未适配过。

centos7安装git工具
```
sudo yum install -y git
```
]]) %>
      </div>
    </div>
  </div>
</div>