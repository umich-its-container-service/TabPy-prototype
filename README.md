# TabPy prototype

This README section contains notes for the ITS containerized TabPy prototype. The original README (from the [original TabPy repo](https://github.com/tableau/TabPy)) begins further down the page, as annotated.

## Overview

Attempting to build a TabPy image with Podman, then run and test a container from that image.

## Various problems

### Broken base image configuration

As of commit `bdb53ac` (and tag `2.12.0`, `2.11.0`, etc.) from the original repo, an image does not build successfully from the Dockerfile. Root cause and workaround:
* The Dockerfile uses base image `python:3` which (as of this writing) refers to Python v3.13.
* Attempts to build the image results in errors that the `cmake` package is not found.
* Installing `cmake` with apt resolves this; but the image still does not build.
* The next problem is related to the Python Arrow library, which is not trivial to resolve.
* Notably, in the original repo, the Dockerfile and associated start.sh script have not been modified since Aug. 2021 (commit `9b13f67`).

Tracing that 2021 timeline back against the [Python support matrix](https://endoflife.date/python), it appears likely that the last time the Dockerfile was tested the base image `python:3` would have referred to Python v3.10 (or even v3.9).

Modifying `FROM` in the Dockerfile to use base image `python:3.10` results in a successful image build.

### Broken service startup

After resolving the Dockerfile base image problem, the next problem is with the container at runtime. The TabPy service fails to start due to being unable to find a password file (per container logs). Attempted to address this issue by referring to documentation in [TabPy server configuration instructions](./docs/server-config.md). Workaround:
* Generated and committed `password-file.txt`, by running the command: `tabpy-user add -u someguy -p fake.secret.fxAuibc0Ru -f password-file.txt` [^not_secret]
* Added new `ENV` and `COPY` instructions to the Dockerfile.

[^not_secret]:
    The credentials in `password-file.txt` are not sensitive as they are **not** real secrets. As such, they should not be used in any live environment.

This workaround resolved the problem with the password file not being found. However, there is a new problem (observed in container logs) with the TabPy service getting an HTTP 401. This needs to be investigated further, possibly in the TabPy Python code.

### Broken config detection

In an attempt to resolve the HTTP 401 at TabPy service startup, a custom configuration file was added as `its-configs/custom.conf`. This custom config contains the following variable override:

```
TABPY_PWD_FILE = /its-configs/password-file.txt
```

The `its-configs/custom.conf` file is being fed to the TabPy service (per [TabPy server configuration instructions](./docs/server-config.md)) using the `--config` option in the Dockerfile. But TabPy is ignoring it and instead reading the default configuration.

### Ongoing broken authentication

Was able to work around the broken config detection by completely removing the TabPy service call in the Dockerfile, and instead adding the `--config` option to `start.sh`. Following that change, the container logs show the custom config is being read properly:

```
2024-10-24T10:15:29.294378000-04:00 Waiting for tabpy server
2024-10-24T10:15:29.905754000-04:00 2024-10-24,14:15:29 [INFO] (app.py:app:316): Parsing config file /its-configs/custom.conf
2024-10-24T10:15:29.908729000-04:00 2024-10-24,14:15:29 [INFO] (util.py:util:51): Parsing passwords file /its-configs/password-file.txt...
2024-10-24T10:15:29.909239000-04:00 2024-10-24,14:15:29 [INFO] (util.py:util:87): Authentication is enabled
```

However, even with this custom configuration (which supplies the custom password file and enables authentication), the HTTP 401 persists:

```
2024-10-24T10:15:32.310226000-04:00 2024-10-24,14:15:32 [INFO] (web.py:web:2348): 200 HEAD / (127.0.0.1) 3.83ms
2024-10-24T10:15:33.049729000-04:00 2024-10-24,14:15:33 [INFO] (base_handler.py:base_handler:115): Authorization header not found
2024-10-24T10:15:33.050031000-04:00 2024-10-24,14:15:33 [ERROR] (base_handler.py: base_handler:115): Failing with 401 for unauthorized request
2024-10-24T10:15:33.050248000-04:00 2024-10-24,14:15:33 [ERROR] (base_handler.py: base_handler:115): Responding with status=401, message="Invalid credentials provided.", info="Unauthorized request."
```

It is not clear how to feed authentication credentials to the Python programs named above.

Despite the HTTP 401 error logging, the TabPy service continues running, with this command appearing in the container process table:

```
/usr/local/bin/python3 /usr/local/bin/tabpy --config=/its-configs/custom.conf
```

Unsure how to proceed from here.

******

Original README notes below

******

# TabPy

[![Tableau Supported](https://img.shields.io/badge/Support%20Level-Tableau%20Supported-53bd92.svg)](https://www.tableau.com/support-levels-it-and-developer-tools)
[![GitHub](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://raw.githubusercontent.com/Tableau/TabPy/master/LICENSE)

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/tableau/tabpy/Test%20Run%20on%20Push)](https://github.com/tableau/TabPy/actions?query=workflow%3A%22Test+Run+on+Push%22)
[![Coverage Status](https://coveralls.io/repos/github/tableau/TabPy/badge.svg?branch=master)](https://coveralls.io/github/tableau/TabPy?branch=master)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/tableau/TabPy/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/tableau/TabPy/?branch=master)

![PyPI - Python Version](https://img.shields.io/pypi/pyversions/tabpy?label=PyPI%20Python%20versions)
[![PyPI version](https://badge.fury.io/py/tabpy.svg)](https://pypi.python.org/pypi/tabpy/)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/tableau/tabpy)

TabPy (the Tableau Python Server) is an Analytics Extension implementation which
expands Tableau's capabilities by allowing users to execute Python scripts and
saved functions via Tableau's table calculations.

Consider reading TabPy documentation in the following order:

* [About TabPy](docs/about.md)
* [TabPy Installation Instructions](docs/server-install.md)
* [TabPy Server Configuration Instructions](docs/server-config.md)
* [Running TabPy in Virtual Environment](docs/tabpy-virtualenv.md)
* [Running TabPy on Heroku](docs/deploy-to-heroku.md)
* [Authoring Python calculations in Tableau](docs/TableauConfiguration.md).
* [TabPy Tools](docs/tabpy-tools.md)

Important security note:

* By default, TabPy is configured without username/password authentication.
We strongly advise using TabPy only with authentication enabled. For more
information, see
[TabPy Server Configuration Instructions](docs/server-config.md#authentication).
Without authentication in place, if the TABPY_EVALUATE_ENABLE feature is
enabled (as it is by default), there is the possibility that unauthenticated
individuals could remotely execute code on the machine running TabPy.
Leaving these two settings in their default states together is highly
discouraged.

Troubleshooting:

* [TabPy Wiki](https://github.com/tableau/TabPy/wiki)

More technical topics:

* [Contributing Guide](CONTRIBUTING.md) for TabPy developers
* [TabPy REST API](docs/server-rest.md)
* [TabPy Security Considerations](docs/security.md)

Other useful resources:

* [Tableau Sci-Fi Blog](http://tabscifi.golovatyi.info/) provides tips, tricks, under
  the hood, useful resources, and technical details for how to extend
  Tableau with data science.
* [Known Issues for the Tableau Analytics Extensions API](https://tableau.github.io/analytics-extensions-api/docs/ae_known_issues.html).
* For all questions not related to the TabPy code (installation, deployment,
  connections, Python issues, etc.) and requests use the
  [Analytics Extensions Forum](https://community.tableau.com/community/forums/analyticsextensions)
  on [Tableau Community](https://community.tableau.com).
* [Building advanced analytics applications with TabPy](https://www.tableau.com/about/blog/2017/1/building-advanced-analytics-applications-tabpy-64916)
* [Building Data Science Applications with TabPy Video Tutorial](https://youtu.be/nRtOMTnBz_Y)
* [TabPy Tutorial on TabWiki](https://community.tableau.com/docs/DOC-10856)

![GitHub commit activity](https://img.shields.io/github/commit-activity/m/tableau/TabPy.svg)
