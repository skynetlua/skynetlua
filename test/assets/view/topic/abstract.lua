<div class='cell'>

  <a class="user_avatar pull-left" href="/user/<%- topic.author.loginname %>">
    <img src="<%- avatar(topic.author.avatar_url) %>" title="<%- topic.author.loginname %>" />
  </a>

  <span class="reply_count pull-left">
    <span class="count_of_replies" title="回复数"><%- topic.reply_count %></span>
    <span class="count_seperator">/</span>
    <span class="count_of_visits" title='点击数'><%- topic.visit_count %></span>
  </span>

  <% if topic.reply and topic.reply.author then %>
  <a class='last_time pull-right' href="/topic/<%- topic.id %><%- '#' .. topic.reply.id %>">
    <img class="user_small_avatar" src="<%- avatar(topic.reply.author.avatar_url) %>">
    <span class="last_active_time"><%- showDate(topic.reply.create_at) %></span>
  </a>
  <% end %>
  <% if not topic.reply then %>
    <span class='last_time pull-right'>
      <span class="last_active_time"><%- showDate(topic.create_at) %></span>
    </span>
  <% end %>

  <div class="topic_title_wrapper">
    <%- partial('./_top_good', {topic = topic}) %>
    <a class='topic_title' href='/topic/<%- topic.id %>' title='<%- topic.title %>'><%- topic.title %></a>
  </div>
</div>
