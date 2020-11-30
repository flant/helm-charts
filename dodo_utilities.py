import glob, os.path

def get_all_chart_names(charts_root_dir):
  possible_chart_paths = glob.glob(os.path.join(charts_root_dir, "*"))
  chart_paths = list(filter(lambda path: os.path.isdir(path), possible_chart_paths))
  return list(map(lambda path: os.path.basename(path), chart_paths))
