<tr>
  <td><b><%- indexInCollection %></b></td>
  <td>
    <a class='user_avatar' href="/user/<%- user.loginname %>">
      <img src="<%- avatar(user.avatar_url) %>" title="<%- user.loginname %>"/>
    </a>
    <span class='sp10'></span>
    <a href='/user/<%- user.loginname %>'><%- user.loginname %></a></td>
  <td><%- user.score %></td>
  <td><%- user.topic_count %></td>
  <td><%- user.reply_count %></td>
</tr>
