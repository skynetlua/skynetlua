<div id='sidebar'>
  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>作者</span>
    </div>
    <div class='inner'>
      <%- partial('../user/card', {user = topic.author}) %>
    </div>
  </div>

  <% if not current_user or not current_user.isAdvanced then %>
    <%- partial('../_ads') %>
  <% end %>

  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>作者其它话题</span>
    </div>
    <div class='inner'>
      <% if author_other_topics and #author_other_topics > 0 then %>
      <ul class='unstyled'>
        <%- partial('../topic/small', {collection = author_other_topics, as = 'topic'}) %>
      </ul>
      <% else %>
      <p>无</p>
      <% end %>
    </div>
  </div>

  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>无人回复的话题</span>
    </div>

    <div class='inner'>
      <% if no_reply_topics and #no_reply_topics > 0 then %>
      <ul class='unstyled'>
      <%- partial('../topic/small', {collection = no_reply_topics, as = 'topic'}) %>
      </ul>
      <% else %>
      <p>无</p>
      <% end %>
    </div>
  </div>
</div>


<div id='content'>
  <div class='panel'>
    <div class='header topic_header'>

      <span class="topic_full_title">
        <%- partial('./_top_good', {topic = topic}) %><%- topic.title %>
      </span>

      <div class="changes">
        <strong>作者：</strong><a href="/user/<%- topic.author.loginname %>"><%- topic.author.loginname %></a>
        <% if topic.tab and tabName(topic.tab) then %>
        &nbsp;&nbsp;<strong>版块：</strong><a href="/?tab=<%- topic.tab %>"><%- tabName(topic.tab) %></a>
        <% end %>
        &nbsp;&nbsp;<strong>浏览：</strong><%- topic.visit_count %>
        &nbsp;&nbsp;<strong>时间：</strong><%- showDate(topic.create_at) %>

        <% if current_user then %>
          <% if is_collect then %>
            <input class="span-common pull-right collect_btn" type="submit" value="取消收藏" action="de_collect">
          <% else %>
            <input class="span-common span-success pull-right collect_btn" type="submit" value="收藏" action="collect">
          <% end %>
        <% end %>
      </div>

      <% if current_user then %>
      <div id="manage_topic">
        <% if current_user.is_admin then %>
          <a href='/topic/<%- topic.id %>/top?_csrf=<%- csrf %>' data-method="post">
            <% if topic.top == 1 then %>
              <i class="fa fa-lg fa-star" title='取消置顶'></i>
            <% else %>
              <i class="fa fa-lg fa-star-o" title='置顶'/></i>
            <% end %>
          </a>

          <a href='/topic/<%- topic.id %>/good?_csrf=<%- csrf %>' data-method="post">
            <% if topic.good == 1 then %>
              <i class="fa fa-lg fa-heart" title="取消精华"></i>
            <% else %>
              <i class="fa fa-lg fa-heart-o" title="加精华"></i>
            <% end %>
          </a>

          <a href='/topic/<%- topic.id %>/lock?_csrf=<%- csrf %>' data-method="post">
            <% if topic.lock == 1 then %>
              <i class="fa fa-lg fa-lock" title='取消锁定'></i>
            <% else %>
              <i class="fa fa-lg fa-unlock" title='锁定（不可再回复）'/></i>
            <% end %>
          </a>

          <a href='/topic/<%- topic.id %>/edit'>
            <i class="fa fa-lg fa-pencil-square-o" title='编辑'></i>
          </a>

          <a href='javascript:;' data-id="<%- topic.id %>" class='delete_topic_btn'>
             <i class="fa fa-lg fa-trash" title='删除'></i>
          </a>
        <% else %>
          <% if current_user.id == topic.author_id then %>
          <a href='/topic/<%- topic.id %>/edit'>
            <i class="fa fa-lg fa-pencil-square-o" title='编辑'></i>
          </a>

          <a href='javascript:;' data-id="<%- topic.id %>" class='delete_topic_btn'>
             <i class="fa fa-lg fa-trash" title='删除'></i>
          </a>
          <% end %>
        <% end %>
      </div>
      <% end %>
    </div>

    <div class='inner topic'>
      <div class='topic_content'>
        <%- markdown(topic.linkedContent or topic.content) %>
      </div>
    </div>
  </div>

  <% if topic.replies and #topic.replies > 0 then %>
  <div class='panel'>
    <div class='header'>
      <span class='col_fade'><%- #topic.replies %> 回复</span>
    </div>
    <%- partial('../reply/reply', {collection = topic.replies, as = 'reply'}) %>
  </div>
  <% end %>
  
  <% if current_user and topic then %>
  <div class='panel'>
    <div class='header'>
      <span class='col_fade'>添加回复</span>
    </div>
    <div class='inner reply'>
      <form id='reply_form' action='/<%- topic.id %>/reply?_csrf=<%- csrf %>' method='post'>
        <div class='markdown_editor in_editor'>
          <div class='markdown_in_editor'>
            <textarea class='editor' name='r_content' rows='8'></textarea>
            <div class='editor_buttons'>
              <% if topic.lock == 1 then %>
                <input class='span-primary submit_btn' type="submit" data-loading-text="回复中.." value="回复(此主题已锁定)" disabled="disabled" />
              <% else %>
                <input class='span-primary submit_btn' type="submit" data-loading-text="回复中.." value="回复" />
              <% end %>
            </div>
          </div>
        </div>
        <input type='hidden' name='_csrf' id="_csrf" value='<%- csrf %>'/>
      </form>
    </div>
  </div>
  <% end %>
</div>

<div class="replies_history">
  <div class="inner_content"></div>
  <div class="anchor"></div>
</div>

<!-- 预览模态对话框 -->
<div class="modal fade" id="preview-modal">
  <div class="modal-body" style="max-height: initial;">
    <img src="" alt="点击内容或者外部自动关闭图片预览" id="preview-image">
  </div>
</div>

<% if current_user and topic then %>
<%- partial('../includes/editor') %>

<script type="text/javascript">
  $(document).ready(function() {
    // 获取所有回复者name
    var allNames = $('.reply_author').map(function(idx, ele) {
      return $(ele).text().trim();
    }).toArray();
    allNames.push($('.user_card .user_name').text())
    allNames = _.uniq(allNames);
    // END 获取所有回复者name

    // 编辑器相关
    $('textarea.editor').each(function(){
      var editor = new Editor({
        status: []
      });
      var $el = $(this);

      editor.render(this);
      //绑定editor
      $(this).data('editor', editor);

      var $input = $(editor.codemirror.display.input);
      $input.keydown(function(event){
        if (event.keyCode === 13 && (event.ctrlKey || event.metaKey)) {
          event.preventDefault();
          $el.closest('form').submit();
        }
      });

      // at.js 配置
      var codeMirrorGoLineUp = CodeMirror.commands.goLineUp;
      var codeMirrorGoLineDown = CodeMirror.commands.goLineDown;
      var codeMirrorNewlineAndIndent = CodeMirror.commands.newlineAndIndent;
      $input.atwho({
        at: '@',
        data: allNames
      })
      .on('shown.atwho', function () {
        CodeMirror.commands.goLineUp = _.noop;
        CodeMirror.commands.goLineDown = _.noop;
        CodeMirror.commands.newlineAndIndent = _.noop;
      })
      .on('hidden.atwho', function () {
        CodeMirror.commands.goLineUp = codeMirrorGoLineUp;
        CodeMirror.commands.goLineDown = codeMirrorGoLineDown;
        CodeMirror.commands.newlineAndIndent = codeMirrorNewlineAndIndent;
      });
      // END at.js 配置

    });
    // END 编辑器相关

    // 评论回复
    $('#content').on('click', '.reply2_btn', function (event) {
      var $btn = $(event.currentTarget);
      var parent = $btn.closest('.reply_area');
      var editorWrap = parent.find('.reply2_form');
      var display = editorWrap.css('display');
      if(display != 'none'){
        editorWrap.hide();
        return;
      }
      parent.find('.reply2_area').prepend(editorWrap);
      var textarea = editorWrap.find('textarea.editor');
      var user = $btn.closest('.author_content').find('.reply_author').text().trim();
      var editor = textarea.data('editor');
      editorWrap.show('fast', function () {
        var cm = editor.codemirror;
        cm.focus();
        if(cm.getValue().indexOf('@' + user) < 0){
          editor.push('@' + user + ' ');
        }
      });
    });

    $('#content').on('click', '.reply2_at_btn', function (event) {
      var $btn = $(event.currentTarget);
      var editorWrap = $btn.closest('.reply2_area').find('.reply2_form');
      $btn.closest('.reply2_item').after(editorWrap);
      var textarea = editorWrap.find('textarea.editor');
      var user = $btn.closest('.reply2_item').find('.reply_author').text().trim();
      var editor = textarea.data('editor');
      editorWrap.show('fast', function () {
        var cm = editor.codemirror;
        cm.focus();
        if(cm.getValue().indexOf('@' + user) < 0){
          editor.push('@' + user + ' ');
        }
      });
    });
    // END 评论回复

    // 加入收藏
    $('.collect_btn').click(function () {
      var $me = $(this);
      var action = $me.attr('action');
      var data = {
        topic_id: '<%- topic.id %>',
        _csrf: '<%- csrf %>'
      };
      var $countSpan = $('.collect-topic-count');
      $.post('/topic/' + action, data, function (data) {
        if (data.status === 'success') {
          if (action == 'collect') {
            $me.val('取消收藏');
            $me.attr('action', 'de_collect');
          } else {
            $me.val('收藏');
            $me.attr('action', 'collect');
          }
          $me.toggleClass('span-success');
        }
      }, 'json');
    });
    // END 加入收藏

    // 删除回复
    $('#content').on('click', '.delete_reply_btn, .delete_reply2_btn', function (event) {
      var $me = $(event.currentTarget);
      if (confirm('确定要删除此回复吗？')) {
        var reply_id = null;
        if ($me.hasClass('delete_reply_btn')) {
          reply_id = $me.closest('.reply_item').attr('reply_id');
        }
        if ($me.hasClass('delete_reply2_btn')) {
          reply_id = $me.closest('.reply2_item').attr('reply_id');
        }
        var data = {
          reply_id: reply_id,
          _csrf: "<%- csrf %>"
        };
        $.post('/reply/' + reply_id + '/delete', data, function (data) {
          if (data.status === 'success') {
            if ($me.hasClass('delete_reply_btn')) {
              $me.closest('.reply_item').remove();
            }
            if ($me.hasClass('delete_reply2_btn')) {
              $me.closest('.reply2_item').remove();
            }
          }
        }, 'json');
      }
      return false;
    });
    // END 删除回复

    // 删除话题
    $('.delete_topic_btn').click(function () {
      var topicId = $(this).data('id');
      if (topicId && confirm('确定要删除此话题吗？')) {
        $.post('/topic/' + topicId + '/delete', { _csrf: $('#_csrf').val() }, function (result) {
          if (!result.success) {
            alert(result.message);
          } else {
            location.href = '/';
          }
        });
      }
      return false;
    });
    // END 删除话题

    // 用户 hover 在回复框时才显示点赞按钮
    $('.reply_area').hover(
      function () {
        $(this).find('.up_btn').removeClass('invisible');
      },
      function () {
        var $this = $(this);
        if ($this.find('.up-count').text().trim() === '') {
          $this.find('.up_btn').addClass('invisible');
        }
      });
    // END 用户 hover 在回复框时才显示点赞按钮

  });

</script>
<% end %>

<script type="text/javascript">
  (function(){
    var timer = null; //对话框延时定时器
    // 初始化 $('.replies_history')
    var $repliesHistory = $('.replies_history');
    var $repliesHistoryContent = $repliesHistory.find('.inner_content');
    $repliesHistory.hide();
    // END
    // 鼠标移入对话框清除隐藏定时器；移出时隐藏对话框
    $repliesHistory.on('mouseenter', function(){
      clearTimeout(timer);
    }).on('mouseleave', function(){
      $repliesHistory.fadeOut('fast');
    });
    // 显示被 at 用户的本页评论
    if ($('.reply2_item').length === 0) {
      // 只在流式评论布局中使用

      $('#content').on('mouseenter', '.reply_content a', function (e) {
        clearTimeout(timer);
        var $this = $(this);
        if ($this.text()[0] === '@') {
          var thisText = $this.text().trim();
          var loginname = thisText.slice(1);
          var offset = $this.offset();
          var width = $this.width();
          var mainOffset = $('#main').offset();
          $repliesHistory.css('left', offset.left-mainOffset.left+width+10); // magic number
          $repliesHistory.css('top', offset.top-mainOffset.top-10); // magic number
          $repliesHistory.css({
            'z-index': 1,
          });
          $repliesHistoryContent.empty();
          var chats = [];
          var replyToId = $this.closest('.reply_item').attr('reply_to_id');
          while (replyToId) {
            var $replyItem = $('.reply_item[reply_id=' + replyToId + ']');
            var replyContent = $replyItem.find('.reply_content').text().trim();
            if (replyContent.length > 0) {
              chats.push([
                $($replyItem.find('.user_avatar').html()).attr({
                  height: '30px',
                  width: '30px',
                }), // avatar
                (replyContent.length>300?replyContent.substr(0,300)+'...':replyContent), // reply content
                '<a href="#'+replyToId+'" class="scroll_to_original" title="查看原文">↑</a>'
              ]);
            }
            replyToId = $replyItem.attr('reply_to_id');
          }
          if(chats.length > 0) {
            chats.reverse();

            $repliesHistoryContent.append('<div class="title">查看对话</div>');
            chats.forEach(function (pair, idx) {
              var $chat = $repliesHistoryContent.append('<div class="item"></div>');
              $chat.append(pair[0]); // 头像
              $chat.append($('<span>').text(pair[1])); // 内容
              $chat.append(pair[2]); // 查看原文 anchor
            });
            $repliesHistory.fadeIn('fast');
          }else{
            $repliesHistory.hide();
          }
        }
      }).on('mouseleave', '.reply_content a', function (e) {
        timer = setTimeout(function(){
          $repliesHistory.fadeOut('fast');
        }, 500);
      });
    }
    // END 显示被 at 用户的本页评论
  })();

  // 点赞
  $('.up_btn').click(function (e) {
    var $this = $(this);
    var replyId = $this.closest('.reply_area').attr('reply_id');
    $.ajax({
      url: '/reply/' + replyId + '/up',
      method: 'POST',
      data: {_csrf: "<%- csrf %>"}
    }).done(function (data) {
      if (data.success) {
        $this.removeClass('invisible');
        var currentCount = Number($this.next('.up-count').text().trim()) || 0;
        if (data.action === 'up') {
          $this.next('.up-count').text(currentCount + 1);
          $this.addClass('uped');
        } else {
          if (data.action === 'down') {
            $this.next('.up-count').text(currentCount - 1);
            $this.removeClass('uped');
          }
        }
      } else {
        alert(data.message);
      }
    }).fail(function (xhr) {
      if (xhr.status === 403) {
        alert('请先登录，登陆后即可点赞。');
      }
    });
  });
  // END 点赞
  // 图片预览
  (function(){
    var $previewModal = $('#preview-modal');
    var $previewImage = $('#preview-image');
    var $body = $('body'); // cache

    $(document).on('click', '.markdown-text img', function(e) {
      var $img = $(this);
      // 图片被a标签包裹时，不显示弹层
      if ($img.parent('a').length > 0) {
        return;
      }
      showModal($img.attr('src'));
    });

    $previewModal.on('click', hideModal);

    $previewModal.on('hidden.bs.modal', function() {
      // 在预览框消失之后恢复 body 的滚动能力
      $body.css('overflow-y', 'scroll');
    })

    $previewModal.on('shown.bs.modal', function() {
      // 修复上次滚动留下的痕迹,可能会导致短暂的闪烁，不过可以接受
      // TODO: to be promote
      $previewModal.scrollTop(0);
    })

    function showModal(src) {
      $previewImage.attr('src', src);
      $previewModal.modal('show');
      // 禁止 body 滚动
      $body.css('overflow-y', 'hidden');
    }

    function hideModal() {
      $previewModal.modal('hide');
    }

  })()
  // END 图片预览
</script>
