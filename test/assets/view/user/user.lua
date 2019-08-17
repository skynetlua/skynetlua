<div class='user'>
  <div>
    <a href="/user/<%- user.loginname %>">
      <img class='user_avatar' src="<%- avatar(user.avatar_url) %>" title="<%- user.loginname %>"/>
    </a>
    
    <span class='user_name'><a class='dark' href="/user/<%- user.loginname %>"><%- user.loginname %></a></span>

    <div class='space'></div>
    <span class='col_fade'><%- user.follower_count %> 粉丝 </span>
    <span class='space'></span>
    <span class='col_fade'><%- user.following_count %> 关注 </span>
  </div>
  <div>

    <% if type(user.email) == 'string' and #user.email > 0 then %>
		<span>
			<a href='mailto:<%- user.email %>'>
        <i class="fa fa-envelope-o" title='电子邮箱'></i>
      </a>
		</span>
    <% end %>

    <% if type(user.url) == 'string' and #user.url > 0 then %>
		<span>
			<a href="<%- user.url %>" target='_blank'>
        <i class="fa fa-home" title='个人网站'></i>
      </a>
		</span>
    <% end %>

    <% if type(user.weibo) == 'string' and #user.weibo > 0 then %>
		<span>
			<a href="<%- user.weibo %>" target='_blank'>
        <i class="fa fa-weibo" title='微博'></i>
      </a>
		</span>
    <% end %>
  </div>
</div>
