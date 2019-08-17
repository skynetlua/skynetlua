<% if message.has_read then %>
<div class='cell' message_id='<%- message.id %>'>
<% else %>
<div class='cell message' message_id='<%- message.id %>'>
<% end %>
	<% if message.type == 'reply' then %>
		<span>
			<a href="/user/<%- message.author.loginname %>" target='_blank'><%- message.author.loginname %></a>
			回复了你的话题
			<a href="/topic/<%- message.topic.id .. (message.reply and '#' .. message.reply.id or '') %>" target='_blank'><%- message.topic.title %></a>
		</span>
	<% end %>

	<% if message.type == 'reply2' then %>
		<span>
			<a href="/user/<%- message.author.loginname %>" target='_blank'><%- message.author.loginname %></a>
			在话题
			<a href="/topic/<%- message.topic.id .. (message.reply and '#' .. message.reply.id or '') %>" target='_blank'><%- message.topic.title %></a>
			中回复了你的回复
		</span>
	<% end %>

	<% if message.type == 'follow' then %>
	<span>
		<a href="/user/<%- message.author.loginname %>" target='_blank'><%- message.author.loginname %></a>
		关注了你
	</span>
	<% end %>

	<% if message.type == 'at' then %>
		<span>
			<a href="/user/<%- message.author.loginname %>" target='_blank'><%- message.author.loginname %></a>
			在话题
			<a href="/topic/<%- message.topic.id .. (message.reply and '#' .. message.reply.id or '') %>" target='_blank'><%- message.topic.title %></a>
			中@了你
		</span>
	<% end %>
</div>
