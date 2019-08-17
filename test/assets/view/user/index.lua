<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
      </ul>
    </div>

    <div class='inner userinfo'>
      <div class='user_big_avatar'>
        <img src="<%- avatar(user.avatar_url) %>" class="user_avatar" title="<%- user.loginname %>"/>
      </div>
      <a class='dark'><%- user.loginname %></a>

      <div class='user_profile'>
        <ul class='unstyled'>
          <span class='big'><%- user.score %></span> 积分

          <% if user.collect_topic_count then %>
          <li>
            <a class='dark' href="/user/<%- user.loginname %>/collections" target='_blank'>
              <span class='big collect-topic-count'><%- user.collect_topic_count %></span>个话题收藏
            </a>
          </li>
          <% end %>

          <% if user.url then %>
          <li>
            <i class="fa fa-lg fa-fw fa-home"></i>
            <a class='dark' href="<%- user.url %>" target='_blank'><%- user.url %></a>
          </li>
          <% end %>

          <% if user.location then %>
          <li>
            <i class="fa fa-lg fa-fw fa-map-marker"></i>
            <span class='dark'><%- user.location %></span>
          </li>
          <% end %>

          <% if user.githubUsername then %>
          <li>
            <i class="fa fa-lg fa-fw fa-github"></i>
            <a class='dark' href="https://github.com/<%- user.githubUsername %>" target='_blank'>
              @<%- user.githubUsername %>
            </a>
          </li>
          <% end %>

          <% if user.weibo then %>
          <li>
            <i class="fa fa-lg fa-fw fa-twitter"></i>
            <a class='dark' href="<%- user.weibo %>" target='_blank'><%- user.weibo %></a>
          </li>
          <% end %>
        </ul>
      </div>
      <p class='col_fade'>注册时间 <%- showDate(user.create_at) %></p>

      <% if current_user and current_user.is_admin then %>
        <% if user.is_star == 0 then %>
        <span class='span-common' id='set_star_btn' action='set_star'>设为达人</span>
        <% else %>
        <span class='span-common' id='set_star_btn' action='cancel_star'>取消达人</span>
        <% end %>

        <% if user.is_block == 0 then %>
        <span class='span-common' id='set_block_btn' action='set_block'>屏蔽用户</span>
        <% else %>
        <span class='span-common' id='set_block_btn' action='cancel_block'>取消屏蔽用户</span>
        <% end %>

        <span class="span-common" id="delete_all">删除所有发言</span>

        <br/><br/>
        Email (Seen by Administrator): <a href="mailto:<%- user.email %>"><%- user.email %></a>
        <% if user.active == 0 then %>
        <a href="/active_account?key=<%- token or '' %>&name=<%- user.loginname %>" target="_blank">
           <span class="span-common">激活账号</span>
         </a>
        <% end %>
      <% end %>
    </div>
  </div>

  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>最近创建的话题</span>
    </div>
    <% if recent_topics and #recent_topics > 0 then %>
    <%- partial('../topic/abstract', {collection = recent_topics, as = 'topic'}) %>
    <div class='cell more'>
      <a class='dark' href="/user/<%- user.loginname %>/topics">查看更多»</a>
    </div>
    <% else %>
    <div class='inner'>
      <p>无话题</p>
    </div>
    <% end %>
  </div>

  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>最近参与的话题</span>
    </div>
    <% if recent_replies and #recent_replies > 0 then %>
    <%- partial('../topic/abstract', {collection = recent_replies, as = 'topic'}) %>
    <div class='cell more'>
      <a class='dark' href="/user/<%- user.loginname %>/replies">查看更多»</a>
    </div>
    <% else %>
    <div class='inner'>
      <p>无话题</p>
    </div>
    <% end %>
  </div>
</div>

<% if current_user then %>
<script>
  $(document).ready(function () {
    $('#set_star_btn').click(function () {
      var $me = $(this);
      var action = $me.attr('action');
      var params = {
        user_id: '<%- user.id %>',
        _csrf: '<%- csrf %>'
      };
      $.post('/user/' + action, params, function (data) {
        if (data.status === 'success') {
          if (action === 'set_star') {
            $me.html('取消达人');
            $me.attr('action', 'cancel_star');
          } else {
            $me.html('设为达人');
            $me.attr('action', 'set_star');
          }
        }
      }, 'json');
    });

    $('#set_block_btn').click(function () {
      var $me = $(this);
      var action = $me.attr('action');
      var params = {
        _csrf: '<%- csrf %>',
        action: action
      };
      if (action === 'set_block' && !confirm('确定要屏蔽该用户吗？')) {
        return;
      }
      $.post('/user/<%- user.loginname %>/block', params, function (data) {
        if (data.status === 'success') {
          if (action === 'set_block') {
            $me.html('取消屏蔽用户');
            $me.attr('action', 'cancel_block');
          } else if (action === 'cancel_block') {
            $me.html('屏蔽用户');
            $me.attr('action', 'set_block');
          }
        }
      }, 'json');
    })

    $('#delete_all').click(function () {
      var $me = $(this);
      var params = {
        _csrf: '<%- csrf %>',
      };
      if (!confirm('确定要删除吗？（不会永久删除，只做标记位）')) {
        return;
      }
      $.post('/user/<%- user.loginname %>/delete_all', params, function (data) {
        if (data.status === 'success') {
          alert('操作成功');
        }
      }, 'json');
    })
  });
</script>
<% end %>
