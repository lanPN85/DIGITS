# Copyright (c) 2015-2017, NVIDIA CORPORATION.  All rights reserved.
from __future__ import absolute_import

from .framework import Framework
from digits.config import config_value

__all__ = [
    'Framework',
    'TorchFramework',
]

if config_value('tensorflow')['enabled']:
    from .tensorflow_framework import TensorflowFramework
    __all__.append('TensorflowFramework')

if config_value('caffe')['enabled']:
    from .caffe_framework import CaffeFramework
    __all__.append('CaffeFramework')

if config_value('torch')['enabled']:
    from .torch_framework import TorchFramework
    __all__.append('TorchFramework')

#
#  create framework instances
#

# torch is optional
torch = TorchFramework() if config_value('torch')['enabled'] else None

# tensorflow is optional
tensorflow = TensorflowFramework() if config_value('tensorflow')['enabled'] else None

# caffe is mandatory
caffe = CaffeFramework() if config_value('caffe')['enabled'] else None

#
#  utility functions
#


def get_frameworks():
    """
    return list of all available framework instances
    there may be more than one instance per framework class
    """
    frameworks = []
    if torch:
        frameworks.append(torch)
    if tensorflow:
        frameworks.append(tensorflow)
    if caffe:
        frameworks.append(caffe)
    return frameworks


def get_framework_by_id(framework_id):
    """
    return framework instance associated with given id
    """
    for fw in get_frameworks():
        if fw.get_id() == framework_id:
            return fw
    return None
