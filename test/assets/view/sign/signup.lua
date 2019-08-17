<%- partial('../sign/sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>注册</li>
      </ul>
    </div>
    <div class='inner'>
      <% if the_error then %>
      <div class="alert alert-error">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <strong><%- the_error %></strong>
      </div>
      <% end %>
      <% if success then %>
      <div class="alert alert-success">
        <strong><%- success %></strong>
      </div>
      <% else %>
      <form id='signup_form' class='form-horizontal' action='/signup?_csrf=<%- csrf %>' method='post'>

        <div class='control-group'>
          <label class='control-label' for='loginname'>用户名</label>
          <div class='controls'>
            <% if loginname then %>
            <input class='input-xlarge' id='loginname' name='loginname' size='30' type='text' value='<%- loginname %>'/>
            <% else %>
            <input class='input-xlarge' id='loginname' name='loginname' size='30' type='text' value=''/>
            <% end %>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='pass'>密码</label>
          <div class='controls'>
            <input class='input-xlarge' id='pass' name='pass' size='30' type='password'/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='re_pass'>确认密码</label>
          <div class='controls'>
            <input class='input-xlarge' id='re_pass' name='re_pass' size='30' type='password'/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='email'>电子邮箱</label>
          <div class='controls'>
            <% if email then %>
            <input class='input-xlarge' id='email' name='email' size='30' type='text' value='<%- email %>'/>
            <% else %>
            <input class='input-xlarge' id='email' name='email' size='30' type='text'/>
            <% end %>
          </div>
        </div>
        <input type='hidden' name='_csrf' value='<%- csrf %>'/>

        <div class='form-actions'>
          <input type='submit' class='span-primary' value='注册'/>
          <a href="/auth/github"><span class="span-info">通过 GitHub 登录</span></a>
        </div>
      </form>
      <% end %>
    </div>
  </div>
</div>