<%- partial('../editor_sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ol class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>编辑回复</li>
      </ol>
    </div>

    <div class='inner post'>
      <% if edit_error then %>
      <div class="alert alert-error">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <strong><%- edit_error %></strong>
      </div>
      <% end %>

      <% if the_error then %>
      <div class="alert alert-error">
        <strong><%- the_error %></strong>
      </div>
      <% else %>
      <form id='edit_reply_form' action='/reply/<%- reply_id %>/edit?_csrf=<%- csrf %>' method='post'>
        <fieldset>
          <div class='markdown_editor in_editor'>
            <div class='markdown_in_editor'>
              <textarea class='editor' name='t_content' rows='20' placeholder='回复支持 Markdown 语法, 请注意标记代码' autofocus ><%- content or '' %></textarea>
              <div class='editor_buttons'>
                <input type="submit" class='span-primary submit_btn' data-loading-text="提交中.." value="提交">
              </div>
            </div>
          </div>
          <input type='hidden' name='_csrf' value='<%- csrf %>'/>
        </fieldset>
      </form>
      <% end %>
    </div>
  </div>
</div>

<!-- markdown editor -->
<%- partial('../includes/editor') %>
<script>
  (function () {
    var editor = new Editor();
    editor.render($('.editor')[0]);
  })();
</script>
