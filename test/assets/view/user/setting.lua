<%- partial('../sidebar') %>

<div id='content'>
  <div class='panel'>

    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>设置</li>
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
      <% end %>

      <form id='setting_form' class='form-horizontal' action='/setting?_csrf=<%- csrf %>' method='post'>
        <div class='control-group'>
          <label class='control-label' for='name'>用户名</label>
          <div class='controls'>
            <input class='input-xlarge readonly' id='name' name='name' size='30' type='text' readonly='true' value="<%- loginname %>"/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='email'>电子邮件</label>
          <div class='controls'>
            <input class='input-xlarge readonly' id='email' name='email' size='30' type='text' readonly='true' value="<%- email %>"/>
            <!-- <p>同时决定了 Gravatar 头像</p> -->  
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='url'>个人网站</label>
          <div class='controls'>
            <input class='input-xlarge' id='url' name='url' size='30' type='text' value="<%- url or '' %>"/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='location'>所在地点</label>
          <div class='controls'>
            <input class='input-xlarge' id='location' name='location' size='30' type='text' value="<%- location or '' %>"/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='github'>GitHub</label>
          <div class='controls'>
            <input class='input-xlarge' id='github' name='github' size='30' type='text'
                   value="<%- githubUsername and '@' .. githubUsername or '' %>" placeholder="@username" readonly="readonly" />
            <p>请通过 GitHub 登陆 skynetlua 来修改此处</p>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='signature'>个性签名</label>
          <div class='controls'>
            <textarea class='input-xlarge' id='signature' name='signature' size='30'><%- signature and signature or "" %></textarea>
          </div>
        </div>

        <input type='hidden' id='action' name='action' value='change_setting'/>
        <input type='hidden' name='_csrf' value='<%- csrf %>'/>
        <div class='form-actions'>
          <input type='submit' class='span-primary submit_btn' data-loading-text="保存中.." value='保存设置'/>
        </div>
      </form>
    </div>
  </div>

  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>更改密码</span>
    </div>
    <div class='inner'>
      <form id='change_pass_form' class='form-horizontal' action='/setting?_csrf=<%- csrf %>' method='post'>
        <div class='control-group'>
          <label class='control-label' for='old_pass'>当前密码</label>
          <div class='controls'>
            <input class='input-xlarge' type='password' id='old_pass' name='old_pass' size='30'/>
          </div>
        </div>
        <div class='control-group'>
          <label class='control-label' for='new_pass'>新密码</label>
          <div class='controls'>
            <input class='input-xlarge' type='password' id='new_pass' name='new_pass' size='30'/>
          </div>
        </div>
        <input type='hidden' id='action' name='action' value='change_password'/>
        <input type='hidden' name='_csrf' value='<%- csrf %>'/>
        <div class='form-actions'>
          <input type='submit' class='span-primary submit_btn' data-loading-text="更改中.." value='更改密码'/>
        </div>
      </form>
    </div>
  </div>

  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>Access Token</span>
    </div>
    <div class='inner'>
      <div>
        <input type='button' class='span-primary refreshToken' value='刷新Token'/>
      </div>
      <div>
        <span>字符串：</span>
        <span id="accessToken"><%- accessToken %></span>
      </div>
      <div>
        <span>二维码：</span>
        <span id="access-token-qrcode"></span>
      </div>
    </div>
  </div>
</div>

<script type="text/javascript">
  $(function() {
    // qrcode generate
    var accessToken = "<%- accessToken %>";
    var qrcode = new QRCode(document.getElementById("access-token-qrcode"), {
      text: accessToken,
      width: 200,
      height: 200,
    });
    // END qrcode generate

    // refreshToken
    $(".refreshToken").on("click", function() {
      $.post("/user/refresh_token?_csrf=<%- csrf %>", "_csrf=<%- csrf %>", function(result) {
        if (result.status === 'success') {
          $("#accessToken").text(result.accessToken);
          qrcode.makeCode(result.accessToken)
        } else {
          alert(result.message);
        }
      })
    })
   });
</script>
