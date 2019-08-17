<% if topic.top == 1 then %>
<span class='put_top'>置顶</span>
<% elseif topic.good == 1 then %>
<span class='put_good'>精华</span>
<% elseif tab == 'all' and topic.tabName then %>
<span class="topiclist-tab"><%- topic.tabName %></span>
<% end %>