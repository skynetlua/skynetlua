<%- partial('../sign/sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>登录</li>
      </ul>
    </div>
    <div class='inner'>
      <% if the_error then %>
      <div class="alert alert-error">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <strong><%- the_error %></strong>
      </div>
      <% end %>
      <form id='signin_form' class='form-horizontal' action='/signin?_csrf=<%- csrf %>' method='post'>
        <div class='control-group'>
          <label class='control-label' for='name'>用户名</label>
          <div class='controls'>
            <input class='input-xlarge' id='name' name='name' size='30' type='text'/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='pass'>密码</label>
          <div class='controls'>
            <input class='input-xlarge' id='pass' name='pass' size='30' type='password'/>
          </div>
        </div>

        <input type='hidden' name='_csrf' value='<%- csrf %>'/>

        <div class='form-actions'>
          <input type='submit' class='span-primary' value='登录'/>
          <a href="/auth/github"><span class="span-info">通过 GitHub 登录</span></a>
          <a id="forgot_password" href='/search_pass'>忘记密码了?</a>
        </div>
      </form>
    </div>
  </div>
</div>
