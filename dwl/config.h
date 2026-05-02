/* Taken from [https://github.com/djpohly/dwl/issues/466](https://github.com/djpohly/dwl/issues/466) */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }


static int log_level = WLR_ERROR;

static const int monoclegaps               = 1;
static const float fullscreen_bg[]         = {0.1f, 0.1f, 0.1f, 1.0f};

/* Appearance */
static const int sloppyfocus               = 1;
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 2; 
static const float rootcolor[]             = COLOR(0x1d2021ff); /* Gruvbox Background */
static const float default_opacity          = 0.85; 

static const int showbar                   = 1;
static const int topbar                    = 0;
static const char *fonts[]                 = {"IosevkaTerm Nerd Font:size=11:antialias=true"};

static const unsigned int gappih    = 5;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 5;       /* vert inner gap between windows */
static const unsigned int gappoh    = 5;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 5;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;       /* 1 means no outer gap when there is only one window */

static uint32_t colors[][3] = {
    /*               fg          bg          border    */
    [SchemeNorm] = { 0xebdbb2ff, 0x1d2021ff, 0x2e2345ff }, /* Gruvbox FG/BG, Gentoo Border */
    [SchemeSel]  = { 0xffffffff, 0xd65d0eff, 0xd65d0eff }, /* White FG, Orange BG/Border */
    [SchemeUrg]  = { 0xffffffff, 0xfb4934ff, 0xfb4934ff }, /* Urgent Red */
};

/* Tagging */
#define TAGCOUNT (5)
static char *tags[] = { "[main]", "[second]", "[work]", "[mail]", "[music]" };

/* Rules */
static const Rule rules[] = {
    /* app_id             title       tags mask  isfloating  opacity          monitor */
    { "librewolf",        NULL,       1 << 0,    0,          1.0,             -1 },
    { "pinentry",         NULL,       0,         1,          default_opacity, -1 },
    { "yabridge-host.exe",NULL,       0,         1,          1.0,             -1 },
    { "app-launcher",     NULL,       0,         1,          default_opacity, -1 },
};

/* Layouts */
static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },
    { "><>",      NULL },    /* floating */
    { "[M]",      monocle },
};

/* Monitors */
static const MonitorRule monrules[] = {
    /* name       mfact  nmaster scale layout       rotate/reflect                x    y */
    { "eDP-1",    0.55f, 1,      1.35,  &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
    { NULL,       0.55f, 1,      1.0,   &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

/* Keyboard */
static const struct xkb_rule_names xkb_rules = {
    .layout = "us,tr",
    .options = "grp:win_space_toggle,caps:capslock",
};

static const int repeat_rate = 60;
static const int repeat_delay = 200;

static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* Input (Touchpad settings) */
static const int tap_to_click = 1;
static const int natural_scrolling = 1;
static const int disable_while_typing = 1;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.5;

/* Define Mod4 (Super) as MODKEY */
#define MODKEY WLR_MODIFIER_LOGO

/* Helper for spawning shell commands */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* Commands */
static const char *termcmd[]      = { "foot", NULL };
static const char *browser[]      = { "librewolf", NULL };
static const char *filemanager[]  = { "foot", "-e", "ranger", NULL };
static const char *mailclient[]   = { "foot", "-e", "aerc", NULL };
static const char *musicplayer[]  = { "foot", "zsh", "-c", "~/.cargo/bin/termusic", NULL };
static const char *launcher[]     = { "dm-launch", NULL };
static const char *displaymgr[]   = { "foot", "--app-id=app-launcher", "zsh", "-c", "~/.local/bin/display-manager.sh", NULL };

/* Hardware Control */
static const char *mutecmd[]      = { "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle", NULL };
static const char *volupcmd[]     = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%", NULL };
static const char *voldowncmd[]   = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%", NULL };
static const char *brupcmd[]      = { "brightnessctl", "set", "5%+", NULL };
static const char *brdowncmd[]    = { "brightnessctl", "set", "5%-", NULL };

/* Screenshot */
static const char *screenshotcopy[] = { "bash", "-c", "grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot' 'Region copied to clipboard' -i camera-photo", NULL };
static const char *screenshotsave[] = { "bash", "-c", "FILENAME=\"screenshot-$(date +%Y%m%d-%H%M%S).png\"; FILEPATH=\"$HOME/Downloads/$FILENAME\"; grim -g \"$(slurp)\" \"$FILEPATH\" && notify-send \"Screenshot Saved\" \"Saved to ~/Downloads/$FILENAME\" -i \"camera-photo\"", NULL };

static const char *const autostart[] = {
    "dbus-update-activation-environment", "--all", NULL,
    "mako", NULL,
    "gentoo-pipewire-launcher", "restart", NULL,
    "kanshi", NULL,
    "gammastep", "-l", "41.0:28.9", "-t", "6500:3500", NULL,
    NULL /* terminate */
};

#define TAGKEYS(KEY,SKEY,TAG) \
    { MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

static const Key keys[] = {
    /* modifier                  key                 function        argument */
    /* Layout Mode Toggles */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_t,          setlayout,      {.v = &layouts[0]} }, /* Tiled: []= */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_f,          setlayout,      {.v = &layouts[1]} }, /* Floating: ><> */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_m,          setlayout,      {.v = &layouts[2]} }, /* Monocle: [M] */
    
    /* Toggle Floating for a SINGLE window (not the whole layout) */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
    { MODKEY,                    XKB_KEY_p,          spawn,          {.v = displaymgr} },
    { MODKEY,                    XKB_KEY_Return,     spawn,          {.v = termcmd} },
    { MODKEY,                    XKB_KEY_w,          spawn,          {.v = browser} },
    { MODKEY,                    XKB_KEY_n,          spawn,          {.v = filemanager} },
    { MODKEY,                    XKB_KEY_m,          spawn,          {.v = mailclient} },
    { MODKEY,                    XKB_KEY_t,          spawn,          {.v = musicplayer} },
    { MODKEY,                    XKB_KEY_d,          spawn,          {.v = launcher} },
    { 0,                         XKB_KEY_Print,      spawn,          {.v = screenshotcopy} },
    { WLR_MODIFIER_SHIFT,        XKB_KEY_Print,      spawn,          {.v = screenshotsave} },
    { MODKEY,                    XKB_KEY_i,          incnmaster,     {.i = +1} },
    { MODKEY,                    XKB_KEY_u,          incnmaster,     {.i = -1} },
    /* Navigation */
    { MODKEY,                    XKB_KEY_h,          focusdir,       {.ui = 0} }, // Left
    { MODKEY,                    XKB_KEY_l,          focusdir,       {.ui = 1} }, // Right
    { MODKEY,                    XKB_KEY_k,          focusdir,       {.ui = 2} }, // Up
    { MODKEY,                    XKB_KEY_j,          focusdir,       {.ui = 3} }, // Down
    /* Resizing the Master area (mfact) */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_H,          setmfact,       {.f = -0.05f} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_L,          setmfact,       {.f = +0.05f} },
    /* Layouts */
    { MODKEY,                    XKB_KEY_space,      setlayout,      {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
    { MODKEY,                    XKB_KEY_f,          togglefullscreen, {0} },
    
    /* Client Management */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          killclient,     {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_E,          quit,           {0} },

    /* Multimedia */
    { 0, XKB_KEY_XF86AudioMute,         spawn, {.v = mutecmd} },
    { 0, XKB_KEY_XF86AudioRaiseVolume,  spawn, {.v = volupcmd} },
    { 0, XKB_KEY_XF86AudioLowerVolume,  spawn, {.v = voldowncmd} },
    { 0, XKB_KEY_XF86MonBrightnessUp,   spawn, {.v = brupcmd} },
    { 0, XKB_KEY_XF86MonBrightnessDown, spawn, {.v = brdowncmd} },

    /* Opacity control (client-opacity patch) */
    { MODKEY,                    XKB_KEY_o,          setopacity,     {.f = +0.05f} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_O,          setopacity,     {.f = -0.05f} },

    /* Directional focus (focusdir patch) */
    { MODKEY,                    XKB_KEY_Left,       focusdir,       {.i = WLR_DIRECTION_LEFT} },
    { MODKEY,                    XKB_KEY_Right,      focusdir,       {.i = WLR_DIRECTION_RIGHT} },
    { MODKEY,                    XKB_KEY_Up,         focusdir,       {.i = WLR_DIRECTION_UP} },
    { MODKEY,                    XKB_KEY_Down,       focusdir,       {.i = WLR_DIRECTION_DOWN} },

    /* Tag Keys */
    TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
    TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                         1),
    TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                 2),
    TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                     3),
    TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                    4),
};

static const Button buttons[] = {
    /* click         event mask    button      function        argument */
    { ClkLtSymbol,   0,            BTN_LEFT,   setlayout,      {.v = &layouts[0]} },
    { ClkLtSymbol,   0,            BTN_RIGHT,  setlayout,      {.v = &layouts[2]} },
    { ClkTitle,      0,            BTN_MIDDLE, zoom,           {0} },
    { ClkStatus,     0,            BTN_MIDDLE, spawn,          {.v = termcmd} },
    { ClkClient,     MODKEY,       BTN_LEFT,   moveresize,     {.ui = CurMove} },
    { ClkClient,     MODKEY,       BTN_MIDDLE, togglefloating, {0} },
    { ClkClient,     MODKEY,       BTN_RIGHT,  moveresize,     {.ui = CurResize} },
    { ClkTagBar,     0,            BTN_LEFT,   view,           {0} },
    { ClkTagBar,     0,            BTN_RIGHT,  toggleview,     {0} },
    { ClkTagBar,     MODKEY,       BTN_LEFT,   tag,            {0} },
    { ClkTagBar,     MODKEY,       BTN_RIGHT,  toggletag,      {0} },
};

