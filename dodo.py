#!/usr/bin/env python3
import sys
from doit.cmd_base import ModuleTaskLoader
from doit.doit_cmd import DoitMain

import werf_chart_repo_doit_tasks.tasks
sys.exit(DoitMain(ModuleTaskLoader(werf_chart_repo_doit_tasks.tasks)).run(sys.argv[1:]))
