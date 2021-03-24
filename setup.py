#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) 2008-2021 The pip developers
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# SPDX-License-Identifier: MIT


import setuptools


# Generate the version number
def get_version():
    def clean_scheme(version):
        from setuptools_scm.version import get_local_node_and_date
        return get_local_node_and_date(version) if version.dirty else ''

    return {
        'write_to': 'requirements/version.py',
        'version_scheme': 'post-release',
        'local_scheme': clean_scheme,
    }


# Read in the module description from the README.md file.
with open("README.md", "r") as fh:
    long_description = fh.read()


setuptools.setup(
    # Package human readable information
    name="requirements.py",
    use_scm_version=get_version(),
    author="Tim 'mithro' Ansell",
    author_email="me@mith.ro",
    description="Package for querying Python `requirements.txt` files.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    license="MIT",
    license_files=["LICENSE"],
    classifiers=[
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Topic :: Software Development :: Build Tools",
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    url="https://github.com/mithro/requirements.py",
    project_urls={
        "Bug Tracker": "https://github.com/mithro/requirements.py/issues",
        "Source Code": "https://github.com/mithro/requirements.py",
    },
    # Package contents control
    packages=setuptools.find_packages(),
    include_package_data=True,
    # Requirements
    python_requires=">=3.7",
    setup_requires=[],
    install_requires=[],
)
