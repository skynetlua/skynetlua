
local config = {
    name = 'skynetlua', 
    description = 'skynetlua开源社区', 
    keywords = 'skynet lua web skynetlua',
    site_headers = {
        '<meta name="linyouhappy" content="linyouhappy@foxmail.com" />'
    },
    site_logo = '/public/images/skynet_metro.jpg',
    site_icon = '/public/images/skynet_icon.png',
    site_navs = {
        -- 格式 {path, title}
        {'/handbook', '开发手册'},
        {'/admin',    '管理后台'},
        {'/project',  '开源项目'},
        {'/about',    '关于'}
    },

    tabs = {
        {'techhelp', '技术求助'},
        {'gamedev',  '游戏开发'},
        {'webdev',   'web开发'},
        {'skynet',   'skynet'},
        {'meiru',    '美茹框架'},
        {'game',     '独立游戏'},
        {'develop',  '共享开发'},
    },
    site_static_host = '', -- 静态文件存储域名
    static_path = "./test/assets/static/",
    host = 'www.skynetlua.com',

    session_secret = 'meiru_session_secret',
    auth_cookie_name = 'user_id',

    list_topic_count = 20,

    mail_opts = {
        -- host  = 'smtp.qq.com',
        -- port  = 465,
        -- user  = '',
        -- token = '',
        -- name  = 'skynetlua'
    },

    admins = {
        ['linyou'] = true
    },
    GITHUB_OAUTH = {
        clientID = 'your GITHUB_CLIENT_ID',
        clientSecret = '',
        callbackURL = 'http://www.skynetlua.com/auth/github/callback'
    },
    allow_sign_up = true,

    -- upload: {
    --   path: path.join(__dirname, 'public/upload/'),
    --   url: '/public/upload/'
    -- },
    file_limit = '1MB',
 
    create_post_per_day = 1000, 
    create_reply_per_day = 1000,
    create_user_per_ip = 1000, 
    visit_per_day = 1000,
}

return config
