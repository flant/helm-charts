import glob, os.path, sys


def get_chart_paths(chart_names, chart_root_dir):
  chart_paths = []
  for chart_name in chart_names:
    chart_paths += (os.path.join(chart_root_dir, chart_name))
  return chart_paths


def get_all_chart_paths(chart_root_dir):
  possible_chart_dirs = glob.glob(os.path.join(chart_root_dir, "*"))
  return list(filter(lambda path: os.path.isdir(path), possible_chart_dirs))


def get_all_chart_names(chart_root_dir):
  chart_dirs = get_all_chart_paths(chart_root_dir)
  return list(map(lambda dir: os.path.basename(dir), chart_dirs))


def get_chart_package_paths(chart_package_filenames, chart_package_dir):
  package_paths = []
  for package_filename in chart_package_filenames:
    package_paths += (os.path.join(chart_package_dir, package_filename))
  return package_paths


def get_all_chart_package_paths(chart_package_dir):
  return glob.glob(os.path.join(chart_package_dir, "*.tgz"))


def abort_if_param_undefined(params):
  for param_name, param_value in params.items():
    if param_value is None:
      print(f'[ERROR] Required parameter "{param_name}" is not specified. Aborting.')
      sys.exit(1)
