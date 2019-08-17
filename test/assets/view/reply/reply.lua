<% if reply.ups and #reply.ups >= topic.reply_up_threshold then %>
  <div class='cell reply_area reply_item reply_highlight' reply_id="<%- reply.id %>" reply_to_id="<%- reply.reply_id or '' %>" id="<%- reply.id %>">
<% else %>
  <div class='cell reply_area reply_item' reply_id="<%- reply.id %>" reply_to_id="<%- reply.reply_id or '' %>" id="<%- reply.id %>">
<% end %>
<% local author = reply.author %>
  <div class='author_content'>
      <a href="/user/<%- author.loginname %>" class="user_avatar">
      <img src="<%- avatar(author.avatar_url) %>" title="<%- author.loginname %>"/></a>

      <div class='user_info'>
        <a class='dark reply_author' href="/user/<%- author.loginname %>"><%- author.loginname %></a>
        <a class="reply_time" href="#<%- reply.id %>"><strong><%- indexInCollection %>楼</strong></a> 
        <%- showDate(reply.create_at) %>
        <% if author.loginname == topic.author.loginname then %>
          <span class="reply_by_author">楼主</span>
        <% end %>
      </div>

      <div class='user_action'>
        <span>
          <i class="fa up_btn <%- (current_user and is_uped(current_user, reply)) and 'fa-thumbs-up uped' or 'fa-thumbs-o-up' %> <%- (not reply.ups or #reply.ups == 0) and ' invisible' or '' %>" title="喜欢"></i>
          <span class="up-count"><%- (reply.ups and #reply.ups>0) and #reply.ups or '' %></span>
        </span>
        
        <% if (current_user and current_user.is_admin) or (current_user and current_user.id == reply.author.id) then %>
        <a href='/reply/<%- reply.id %>/edit' class='edit_reply_btn'><i class="fa fa-pencil-square-o" title='编辑'></i></a>
        <a href='javascript:void(0);' class='delete_reply_btn'><i class="fa fa-trash" title='删除'></i></a>
        <% end %>

        <span>
          <% if current_user then %>
            <i class="fa fa-reply reply2_btn" title="回复"></i>
          <% end %>
        </span>
      </div>
  </div>

  <div class='reply_content from-<%- author.loginname %>'>
    <%- markdown(reply.linkedContent or reply.content) %>
  </div>

  <div class='clearfix'>
    <div class='reply2_area'>
      <% if current_user then %>
      <form class='reply2_form' action='/<%- topic.id %>/reply?_csrf=<%- csrf %>' method='post'>
        <input type='hidden' name='_csrf' value='<%- csrf %>'/>
        <input type='hidden' name='reply_id' value='<%- reply.id %>'/>
        <div class='markdown_editor in_editor'>
          <div class='markdown_in_editor'>
            <textarea class='span8 editor reply_editor' id="reply2_editor_<%- reply.id %>" name='r_content' rows='4'></textarea>
            <div class='editor_buttons'>
              <% if topic.lock == 1 then %>
              <input class='span-primary reply2_submit_btn submit_btn' type="submit" data-id='<%- reply.id %>' data-loading-text="回复中.." value="回复(此主题已锁定)" disabled="disabled"/>
              <% else %>
              <input class='span-primary reply2_submit_btn submit_btn' type="submit" data-id='<%- reply.id %>' data-loading-text="回复中.." value="回复" />
              <% end %>
            </div>
          </div>
        </div>
      </form>
      <% end %>
    </div>
  </div>
</div>
