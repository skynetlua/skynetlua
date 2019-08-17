<%- partial('../sign/sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>找回密码</li>
      </ul>
    </div>
    <div class='inner'>
      <% if the_error then %>
      <div class="alert alert-error">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <strong><%- the_error %></strong>
      </div>
      <% end %>
      <form id='search_pass_form' class='form-horizontal' action='/search_pass?_csrf=<%- csrf %>' method='post'>
        <div class='control-group'>
          <label class='control-label' for='email'>电子邮箱</label>
          <div class='controls'>
            <% if email then %>
            <input class='input-xlarge' id='email' name='email' size='30' type='text' value='<%- email %>'/>
            <% else %>
            <input class='input-xlarge' id='email' name='email' size='30' type='text'/>
            <% end %>
            <p class='help-block'>请输入您注册帐户时使用的电子邮箱</p>
          </div>
          <input type='hidden' name='_csrf' value='<%- csrf %>'/>
        </div>
        <div class='form-actions'>
          <input type='submit' class='span-primary' value='提交'/>
        </div>
      </form>
    </div>
  </div>
</div>
