from doit.action import CmdAction

from dodo_utilities import *

DEFAULT_WERF_VERSION = "1.1 ea"
DEFAULT_WERF_COLOR_MODE = "on"
DEFAULT_WERF_ENVS = ["test", "prod"]
DEFAULT_WERF_EXTRA_ARGS = ["--set 'global.ci-url=example.org'"]

CHARTS_ROOT_DIR = ".helm/charts"

COMMON_WERF_PARAMS = [
  {
    "name": "charts",
    "short": "c",
    "long": "chart",
    "type": list,
    "default": get_all_chart_names(CHARTS_ROOT_DIR),
    "help": f"Chart name, can be specified multiple times. Default: {get_all_chart_names(CHARTS_ROOT_DIR)}",
    },
  {
    "name": "envs",
    "long": "env",
    "type": list,
    "default": DEFAULT_WERF_ENVS,
    "help": f"Werf environment, can be specified multiple times. Default: {DEFAULT_WERF_ENVS}",
    },
  {
    "name": "werf_version",
    "short": "v",
    "long": "werf-version",
    "type": str,
    "default": DEFAULT_WERF_VERSION,
    "help": f"Werf version and release channel. Default: {DEFAULT_WERF_VERSION}",
    },
  {
    "name": "werf_color_mode",
    "long": "werf-color-mode",
    "type": str,
    "default": DEFAULT_WERF_COLOR_MODE,
    "help": f"Werf color mode. Default: {DEFAULT_WERF_COLOR_MODE}",
    },
  {
    "name": "extra_args",
    "short": "a",
    "long": "extra-arg",
    "type": list,
    "default": DEFAULT_WERF_EXTRA_ARGS,
    "help": f"Extra arg for werf command, can be specified multiple times. Default: {DEFAULT_WERF_EXTRA_ARGS}",
    },
  {
    "name": "extra_env_vars",
    "short": "v",
    "long": "extra-env-var",
    "type": list,
    "default": [],
    "help": f'Extra env vars for werf command, can be specified multiple times. Example: "--extra-env-var ENV_VAR=env_val".',
    },
]

################################################################################
# Actions generators
################################################################################

def action_prepare_werf(werf_version, werf_color_mode):
  return [
    f'export WERF_LOG_COLOR_MODE="{werf_color_mode}"',
    f'source <(multiwerf use {werf_version})',
  ]

def action_export_env_vars(env_vars):
  result = []
  for env_var in env_vars:
    env_var = env_var.split("=", 1)
    result.append(f'export {env_var[0]}="{env_var[1]}"')
  return result

def action_werf_lint(env, chart, extra_args):
  return [
    f'werf helm lint --env "{env}" --set "{chart}._enabled=true" {" ".join(extra_args)}'
  ]

def action_werf_render(env, chart, extra_args):
  return [
    (
      f'werf helm render --env "{env}" --set "{chart}._enabled=true" {" ".join(extra_args)}'
      f' | tail -n +6 | grep -vE "(^\#)|(werf.io/version)"'
      f' | yq -sy --indentless "sort_by(.apiVersion,.kind,.metadata.name)[]"'
    )
  ]

################################################################################
# Tasks
################################################################################

def task_werf_lint_charts():
  def werf_lint_charts(
    charts, envs, werf_version, werf_color_mode, extra_args, extra_env_vars
  ):
    commands = []
    commands += action_export_env_vars(extra_env_vars)
    commands += action_prepare_werf(werf_version, werf_color_mode)
    for chart in charts:
      for env in envs:
        commands += action_werf_lint(env, chart, extra_args)
    return " && ".join(commands)

  return {
    "actions": [
      CmdAction(werf_lint_charts, executable="/bin/bash"),
    ],
    "basename": "werf-lint",
    "verbosity": 2,
    "params": COMMON_WERF_PARAMS,
  }

def task_werf_render_charts():
  def werf_render_charts(
    charts, envs, werf_version, werf_color_mode, extra_args, extra_env_vars
  ):
    commands = []
    commands += action_export_env_vars(extra_env_vars)
    commands += action_prepare_werf(werf_version, werf_color_mode)
    for chart in charts:
      for env in envs:
        commands += action_werf_render(env, chart, extra_args)
    return " && ".join(commands)

  return {
    "actions": [
      CmdAction(werf_render_charts, executable="/bin/bash"),
    ],
    "basename": "werf-render",
    "verbosity": 2,
    "params": COMMON_WERF_PARAMS,
  }
