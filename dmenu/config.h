/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
    "IosevkaTerm Nerd Font:size=13"
};
static const char *prompt      = "λ ";      /* -p  option; prompt to the left of input field */
static const char *colors[SchemeLast][2] = {
    /*               fg         bg       */
    [SchemeNorm] = { "#ebdbb2", "#282828" }, /* Gruvbox fg (fg0) and bg (bg0) */
    [SchemeSel]  = { "#282828", "#fb4934" }, /* Dark bg on Red selection for high contrast */
    [SchemeOut]  = { "#ebdbb2", "#8ec07c" }, /* Aqua for multi-select/output */
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
