import os
import subprocess
from collections.abc import Callable

import libqtile.resources
from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Output, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.log_utils import logger
from libqtile.layout import Max

mod = "mod4"
mod1 = "alt"
ctl = "control"
home = os.path.expanduser("~")
terminal = guess_terminal()


class VerticalCenter(Max):
    """Maximized layout
    A simple layout that only displays one window at a time, filling the
    screen_rect. This is suitable for use on laptops and other devices with
    small screens. Conceptually, the windows are managed as a stack, with
    commands to switch to next and previous windows in the stack.
    """

    defaults = [
        ("margin", [100, 0, 100, 0], "Margin of the layout (int or list of ints [N E S W])"),
        ("border_focus", "#0000ff", "Border colour(s) for the window when focused"),
        ("border_normal", "#000000", "Border colour(s) for the window when not focused"),
        ("border_width", 0, "Border width."),
    ]

    def __init__(self, **config):
        Max.__init__(self, **config)
        self.add_defaults(VerticalCenter.defaults)

    def configure(self, client, screen_rect):
        if self.clients and client is self.clients.current_client:
            client.place(
                screen_rect.x,
                screen_rect.y,
                screen_rect.width - self.border_width * 2,
                screen_rect.height - self.border_width * 2,
                self.border_width,
                self.border_focus if client.has_focus else self.border_normal,
                margin=self.margin,
            )
            client.unhide()
        else:
            client.hide()

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "a", lazy.to_screen(1), desc="Focus on screen 0"),
    Key([mod], "s", lazy.to_screen(0), desc="Focus on screen 1"),
    Key([mod], "d", lazy.to_screen(2), desc="Focus on screen 2"),
    Key([mod], "y", lazy.spawn("feh --randomize --bg-fill /home/rhimmelbauer/Pictures/final/"), desc="Randomize Wallpapers"),

    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    Key([mod], "m", lazy.screen.next_group(), desc="Move to left group"),
    Key([mod], "n", lazy.screen.prev_group(), desc="Move to right group"),
    Key([mod], "t", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn("firefox"), desc="Launch firefox"),
    Key([mod], "v", lazy.spawn("pavucontrol")),
    Key([mod], "f", lazy.spawn("nautilus")),
    Key([mod], "space", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    # Toggle between different layouts as defined below
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    # INCREASE/DECREASE/MUTE VOLUME
    Key([mod], "i", lazy.spawn("amixer -q set Master toggle")),
    Key([mod], "u", lazy.spawn("amixer -q set Master 5%-")),
    Key([mod], "o", lazy.spawn("amixer -q set Master 5%+")),
    Key([mod], "c", lazy.spawn("speedcrunch")),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "i", lazy.spawn("firefox --new-window https://music.youtube.com")),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"], "b", lazy.spawn('brave')),
    Key([mod, "shift"], "v", lazy.spawn("brave https://m365.cloud.microsoft/chat/ https://outlook.office.com/mail/ https://outlook.office.com/calendar/view/week https://teams.microsoft.com/v2/ https://metlifelegalplans.atlassian.net/jira/polaris/projects/DPD/ideas/view/10165410/")),
    Key([ctl, "shift"], "s", lazy.spawn('flameshot gui -c ')),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "g", lazy.spawncmd(), desc="Reload the config"),
    Key([mod, "control"], "l", lazy.spawn("i3lock"), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
]

groups = []
group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",]
group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",]
# group_labels = ["Com", "Code", "Code", "Browse", "Meld", "Video", "Vb", "Files", "Music", "Config",]
group_layouts = ["max", "max", "max", "max", "max", "max", "max", "max", "max", "max",]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            # layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))

for i in groups:
    keys.extend([
        # CHANGE WORKSPACES
        Key([mod], i.name, lazy.group[i.name].toscreen()),
        Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
        Key([mod, "shift"], "Tab", lazy.prev_layout()),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name), lazy.group[i.name].toscreen()),
    ])


def init_layout_theme():
    return {"margin": 10,
            "border_width": 2,
            "border_focus": "#ff00ff",
            "border_normal": "#f4c2c2"
            }

layout_theme = init_layout_theme()

layouts = [
    # layout.Bsp(**layout_theme),
    # layout.MonadTall(align=1, ratio=0.70, margin=8, border_width=2, border_focus="#ff00ff", border_normal="#f4c2c2"),
    # layout.MonadWide(margin=8, ratio=0.55, border_width=2, border_focus="#ff00ff", border_normal="#f4c2c2"),
    layout.Max(margin=[700, 50, 700, 50], border_width=2, border_focus="#ff00ff", border_normal="#f4c2c2"),
    # layout.Max(margin=[250, 350, 250, 350], border_width=2, border_focus="#ff00ff", border_normal="#f4c2c2"),
    layout.Max(margin=[5, 5, 5, 5], border_width=2, border_focus="#ff00ff", border_normal="#f4c2c2"),
    # layout.Matrix(**layout_theme),
    # layout.Floating(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.Columns(**layout_theme),
    # layout.Stack(**layout_theme),
    # layout.Tile(**layout_theme),
    # layout.TreeTab(
    #     sections=['FIRST', 'SECOND'],
    #     bg_color = '#141414',
    #     active_bg = '#0000ff',
    #     inactive_bg = '#1e90ff',
    #     padding_y =5,
    #     section_top =10,
    #     panel_width = 280),
    layout.VerticalTile(**layout_theme),
    # layout.Zoomy(**layout_theme)
]
def init_colors():
    return [["#2F343F", "#2F343F"],  # color 0
            ["#2F343F", "#2F343F"],  # color 1
            ["#c0c5ce", "#c0c5ce"],  # color 2
            ["#ff5050", "#ff5050"],  # color 3
            ["#f4c2c2", "#f4c2c2"],  # color 4
            ["#ffffff", "#ffffff"],  # color 5
            ["#ffd47e", "#ffd47e"],  # color 6
            ["#62FF00", "#62FF00"],  # color 7
            ["#000000", "#000000"],  # color 8
            ["#c40234", "#c40234"],  # color 9
            ["#6790eb", "#6790eb"],  # color 10
            ["#ff00ff", "#ff00ff"],  # 11
            ["#4c566a", "#4c566a"],  # 12
            ["#282c34", "#282c34"],  # 13
            ["#212121", "#212121"],  # 14
            ["#e75480", "#e75480"],  # 15
            ["#2aa899", "#2aa899"],  # 16
            ["#abb2bf", "#abb2bf"],  # color 17
            ["#81a1c1", "#81a1c1"],  # 18
            ["#56b6c2", "#56b6c2"],  # 19
            ["#b48ead", "#b48ead"],  # 20
            ["#e06c75", "#e06c75"],  # 21
            ["#fb9f7f", "#fb9f7f"],  # 22
            ["#ffd47e", "#ffd47e"]]  # 23

colors = init_colors()

def base(fg='text', bg='dark'):
    return {'foreground': colors[14], 'background': colors[15]}


# WIDGETS FOR THE BAR

def init_widgets_defaults():
    return dict(font="NotoMono NF",
                fontsize=9,
                padding=2,
                background=colors[1])

widget_defaults = init_widgets_defaults()
screen_aoc_widgets = [
    widget.Image(
        filename="~/.config/qtile/icons/python-logo.png",
        iconsize=20,
        # background=colors[15],
        mouse_callbacks={'Button1': lambda : qtile.spawn('jgmenu_run')}
    ),
    widget.GroupBox(
        **base(bg=colors[15]),
        font='NotoMono NF',
        fontsize=22,
        margin_y=3,
        margin_x=2,
        padding_y=5,
        padding_x=4,
        borderwidth=3,

        active=colors[5],
        inactive=colors[6],
        rounded= True,
        highlight_method='block',
        urgent_alert_method='block',
        urgent_border=colors[16],
        this_current_screen_border=colors[20],
        this_screen_border=colors[17],
        other_current_screen_border=colors[13],
        other_creen_border=colors[17],
        disable_drag=True
    ),
    widget.CurrentLayout(
        margin_y=10,
        mode='icon',
        foreground=colors[5],
        background=colors[3]
    ),
    widget.TaskList(
        highlight_method='border', # or block
        icon_size=25,
        max_title_width=250,
        rounded=True,
        padding_x=0,
        padding_y=0,
        margin_y=0,
        fontsize=22,
        border=colors[7],
        foreground=colors[9],
        margin=2,
        txt_floating='🗗',
        txt_minimized='>_ ',
        borderwidth=1,
        background=colors[20],
        #unfocused_border='border'
    ),
    widget.Prompt(
        font="NotoMono NF",
        fontsize=22,
    ),
    widget.NetGraph(
        fill_color=colors[16],
        graph_color=colors[16],
    ),
    widget.CPUGraph(
        fill_color=colors[3],
        graph_color=colors[3],
    ),
    widget.MemoryGraph(
        fill_color=colors[22],
        graph_color=colors[22],
    ),
    widget.Clock(
        foreground=colors[9],
        background=colors[23],
        padding=0,
        fontsize=22,
        format="%Y-%m-%d %H:%M:%S",
        mouse_callbacks={'Button1': lambda : qtile.cmd_spawn(terminal + ' -e calcurse')},
    ),
    widget.Systray(
        background=0,
        fontsize=22,
        icon_size=30,
        padding=10
    ),
]
def init_screens():
    return [
        Screen(top=bar.Bar(widgets=[], size=35, opacity=0.85, background="000000")),
        Screen(top=bar.Bar(widgets=screen_aoc_widgets, size=35, opacity=0.85, background="000000")),
    ]
screens = init_screens()

@hook.subscribe.startup_once
def autostart():
    script = os.path.expanduser("/home/rhimmelbauer/.config/qtile/scripts/autostart.sh")
    subprocess.Popen([script])

@hook.subscribe.startup
def dbus_register():
    id = os.environ.get('DESKTOP_AUTOSTART_ID')
    if not id:
        return
    subprocess.Popen(['dbus-send',
                      '--session',
                      '--print-reply',
                      '--dest=org.gnome.SessionManager',
                      '/org/gnome/SessionManager',
                      'org.gnome.SessionManager.RegisterClient',
                      'string:qtile',
                      'string:' + id])
# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

@hook.subscribe.client_new
def assign_app_group(client):
    # #########################################################
    # ################ assgin apps to groups ##################
    # #########################################################
    wm_class = client.window.get_wm_class()[1]

    logger.warning(f"############# WM Class: {wm_class}")
    logger.warning(f"############# Client.Window.Name: {client.name}")
    logger.warning(f"############# Split: {client.name.split(' ')}")
    
    if wm_class == "Alacritty" and 'config' in client.name.split(' '):
        client.togroup("0")
        logger.warning("Moving .config Code to group 0")
    elif wm_class == 'firefox_firefox' and client.name.find("Apple") > 0:
        client.togroup("9")
        logger.warning("Moving Apple Music to group 9")
    elif wm_class == "Blueman-manager":
        client.togroup("9")
        logger.warning("Blueman-manager to group 9")
    elif wm_class == "Pavucontrol":
        client.togroup("9")
        logger.warning("Pavucontrol to group 9")
    elif wm_class == "firefox" and (client.name.find("Youtube") > 0 or client.name.find("roberto@willing.com") > 0):
        client.togroup("9")
        logger.warning("Moving Microsoft Home to group 1")
    elif wm_class == "firefox" and (client.name.find("Microsoft") > 0 or client.name.find("roberto@willing.com") > 0):
        client.togroup("1")
        logger.warning("Moving Microsoft Home to group 1")

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
