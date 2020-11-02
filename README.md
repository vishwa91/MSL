# Code to simulate Micro-baseline Structured Light code on synthetic data.

## Files
1. `msl.m` -- Micro-baseline Strctured Light function. Type help(msl) to get more info
2. `get_pattern.m` -- Creates sinusoid or triangular pattern
3. `demo.m` -- Run this to test MSL

You will need to download a scene image (albedo) and a corresponding disparity image
to run this code. We recommend the [Middlebury dataset](http://vision.middlebury.edu/stereo/data/).

Please download the scene image and name it `albedo.png` and the disparity image as `disparity.png`.

Cite:
```
@inproceedings{saragadam2019micro,
  title={Micro-Baseline Structured Light},
  author={Saragadam, Vishwanath and Wang, Jian and Gupta, Mohit and Nayar, Shree},
  booktitle={Proceedings of the IEEE International Conference on Computer Vision},
  pages={4049--4058},
  year={2019}
}
```