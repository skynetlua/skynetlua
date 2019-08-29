<div id="topic_list">
  <%- partial('./abstract', {collection = topics, as = 'topic'}) %>
</div>

<div class='pagination' current_page='<%- current_page %>'>
  <ul>
    <% local base_url = base .. (base:find('?', 1, true) and  '&' or  '?') .. 'tab=' .. tab .. '&page=' %>
    <% if current_page == 1 then %>
    <li class='disabled'><a>«</a></li>
    <% else %>
    <li><a href="<%- base_url %>1">«</a></li>
    <% end %>
    <% 
      local page_start = current_page - 2
      if page_start <= 0 then
        page_start = 1
      end
      local page_end = page_start + 4
      if page_end > page_num then
        page_end = page_num
      end
      if page_start > 1 then %>
      <li><a>...</a></li>
    <% end %>

    <% for i = page_start, page_end do %>
      <% if i == current_page then %>
      <li class='disabled'><a><%- i %></a></li>
      <% else %>
      <li><a href='<%- base_url .. i %>'><%- i %></a></li>
      <% end %>
    <% end %>

    <% if page_end < page_num then %>
      <li><a>...</a></li>
    <% end %>

    <% if current_page == page_num then %>
      <li class='disabled'><a>»</a></li>
    <% else %>
      <li><a href='<%- base_url .. page_num %>'>»</a></li>
    <% end %>
  </ul>
</div>

<script>
  $(document).ready(function () {
    var $nav = $('.pagination');
    var current_page = $nav.attr('current_page');
    if (current_page) {
      $nav.find('li').each(function () {
        var $li = $(this);
        var $a = $li.find('a');
        if ($a.html() == current_page) {
          $li.addClass('active');
          $a.removeAttr('href');
        }
      });
    }
  });
</script>
