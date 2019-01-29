# Copyright (c) 2014-2017, NVIDIA CORPORATION.  All rights reserved.
from __future__ import absolute_import

from .train import TrainTask

__all__ = [
    'TrainTask'
]

from digits.config import config_value  # noqa

if config_value('tensorflow')['enabled']:
    from .tensorflow_train import TensorflowTrainTask  # noqa
    __all__.append('TensorflowTrainTask')

if config_value('caffe')['enabled']:
    from .caffe_train import CaffeTrainTask
    __all__.append('CaffeTrainTask')

if config_value('torch')['enabled']:
    from .torch_train import TorchTrainTask
    __all__.append('TorchTrainTask')
