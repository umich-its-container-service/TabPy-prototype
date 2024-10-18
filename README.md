# TabPy prototype

NB: This README section contains notes for the ITS containerized TabPy prototype. The original README (from the original TabPy repo) begin below as annotated.

## Overview

Attempting to build a TabPy image with Podman, then run and test a container from that image.

## Various problems

### Broken base image configuration

As of commit `bdb53ac` (and tag `2.12.0`, `2.11.0`, etc.) from the original repo, an image does not build successfully from the Dockerfile. Root cause and workaround:
* The Dockerfile uses base image `python:3` which (as of this writing) refers to Python v3.13.
* Attempts to build the image result in errors the `cmake` package not being found. Installing `cmake` does not resolve this. The next problem is related to the Arow library, which is not trivial to resolve.
* Notably, in the original repo, the Dockerfile and associated start.sh script have not been modified since Aug. 2021 (commit `9b13f67`).

Tracing that timeline back against the [Python support matrix](https://endoflife.date/python), it appears likely that the last time the Dockerfile was tested the base image `python:3` would have referred to Python v3.10 (or even v3.9).

As such, attempting to work around the broken image build by using base image `python:3.10`.

### Broken service startup

After resolving the base image problem, the service fails to start due to being unable to find a password file (per container logs). Attempted to address this issue by referring to documentation in [TabPy server configuration instructions](./docs/server-config.md). Workaround:
* Generated and committed `password-file.txt`, per the above instructions. [^not_secret]
* Added new `ENV` and `COPY` instructions to the Dockerfile.

[^not_secret]:
    The credentials in `password-file.txt` are not sensitive as they are **not** real secrets. As such, they should not be used in any live environment.

This workaround resolved the problem with the password file not being found. However, there is a new problem (observed in container logs) with the service getting an HTTP 401. This needs to be investigated further, possibly in the TabPy Python code.

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
