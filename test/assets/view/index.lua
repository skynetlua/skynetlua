<%- partial('sidebar', {
    user = user,
    tops = tops,
    current_user = current_user,
    no_reply_topics = no_reply_topics,
    }) %>

<div id="content">
    <div class="panel">
        <div class="header">
            <% 
            local all_tabs = {{'all', '全部'}}
            for _,pair in ipairs(tabs) do
                table.insert(all_tabs, pair)
            end
            for _,pair in ipairs(all_tabs) do
                local value = pair[1]
                local text = pair[2]
            %>
            <a href="<%- '/?tab=' .. value %>" class="topic-tab <%- value == tab and 'current-tab' or '' %>"><%- text %></a>
            <% end %>
        </div>

        <% if topics and #topics > 0 then %>
            <div class="inner no-padding">
                <%- partial('topic/list', {
                    topics       = topics,
                    page_num     = page_num,
                    current_page = current_page,
                    base_path    = '/'
                }) %>
            </div>
        <% else %>
            <div class="inner">
                <p>无话题</p>
            </div>
        <% end %>
    </div>
</div>
