# 4A: An Animation-based Augmentation Approach for Action Recognition from Discontinuous Video

[![arXiv](https://img.shields.io/badge/arXiv-2404.06741-b31b1b.svg)](https://arxiv.org/abs/2404.06741)

**Paper:** [An Animation-based Augmentation Approach for Action Recognition from Discontinuous Video](https://arxiv.org/abs/2404.06741) (ECAI 2024)

![overall](/resources/overall.png)

4A is a dataset-generation framework that uses game-engine technology to bridge virtual and real-world action recognition. The pipeline estimates human pose from RGB video, predicts joint motion, interpolates skeletal dynamics, and renders diverse animations in varied game environments—enabling strong recognition performance with far less real-world training data, including on discontinuous and in-the-wild video.

## Pipeline Overview

| Step | Folder | Details |
|------|--------|---------|
| 1. 3D pose estimation | [`inferencer/`](inferencer/) | HRNet + JointFormer inferencers |
| 2. Action animation | [`project_code/animation_generation/`](project_code/animation_generation/) | Skeleton → animation files |
| 3. Auto-collection | [`project_code/dataset_generation/`](project_code/dataset_generation/) | FiveM-based dataset capture |
| 4. Evaluation | [`evaluation_code/`](evaluation_code/) | MMAction2 training & testing |

---

## Project Setup

Before running the pipeline, install and configure these tools:

| Tool | Purpose | Link |
|------|---------|------|
| **FiveM Server** | Game engine for rendering & capture | [fivem.net](https://fivem.net/) (requires a Rockstar account) |
| **3ds Max** | View and inspect generated animations | [autodesk.com](https://www.autodesk.com/) |
| **AnimKit** | Build custom animation dictionaries | [CFX forum](https://forum.cfx.re/t/announcing-animkit-create-your-own-custom-animations-for-fivem/4778132) |
| **CodeWalker** | Edit maps for animation presentation | [gta5-mods.com](https://www.gta5-mods.com/tools/codewalker-gtav-interactive-3d-map) |
| **OpenIV** | Manage animation libraries | [openiv.com](https://openiv.com/) |

---

## Step 1: 3D Pose Estimation

Estimate human skeleton keypoints from RGB video before animation generation.

**Recommended models:** [HRNet](https://openaccess.thecvf.com/content_CVPR_2019/html/Sun_Deep_High-Resolution_Representation_Learning_for_Human_Pose_Estimation_CVPR_2019_paper.html) for 2D whole-body pose, and [JointFormer](https://github.com/seblutz/JointFormer) for 2D-to-3D lifting.

**Training data:** [COCO-WholeBody](https://github.com/jin-s13/COCO-WholeBody) (2D) and [H3WB](https://github.com/wholebody3d/wholebody3d) (3D lifting). 4A supports both COCO-WholeBody and NTU-RGB+D skeleton layouts.

**This repo:** Ready-to-use inferencers are in [`inferencer/`](inferencer/) (`inferencer_hrnet.py`, `inferencer_jointformer.py`).

---

## Step 2: Action Animation

> Full guide: [`project_code/animation_generation/README.md`](project_code/animation_generation/README.md)

Converts skeleton coordinate sequences into animation files automatically.

- **Input:** skeleton coordinate list  
- **Output:** animation file  
- **Run:** `main.py` in `project_code/animation_generation/`

**Key parameters:**

| Parameter | Description |
|-----------|-------------|
| `input_folder_path` | Path to input skeleton data |
| `output_folder_path` | Path for generated animations |
| `frame` | Frame index to animate (`None` = all frames) |
| `animation_movement` | Include positional movement during playback (default: `False`) |
| `frame_rate` | Animation frame rate |
| `interplation_interval` | Frame interpolation interval (`1` = no interpolation) |
| `SequenceFrameLimit` | Max quaternion sequence length per frame |
| `smooth` | Enable frame smoothing |

---

## Step 3: Auto-collection (Dataset Generation)

> Full guides: [`project_code/dataset_generation/README.md`](project_code/dataset_generation/README.md) · [`project_code/fivem_scripts/README.md`](project_code/fivem_scripts/README.md)

Automates in-game video capture once animations are ready.

1. Set `animation_info_path` to your animation list in `project_code/dataset_generation/`.
2. Run `main.py` to start collection.

**FiveM scripts** (`project_code/fivem_scripts/`) control the capture environment:

| Script | Role |
|--------|------|
| `animation_menu` | Play animations from a menu list |
| `custom_animations` | Play user-generated animations |
| `change_environment` | Customize in-game weather/lighting |
| `cinematiccam` | Free-moving camera for varied viewpoints |
| `no_npc` | Remove NPCs from scenes |
| `object_spawn` | Spawn props for the character |
| `character_spawn` | Character placement |

---

## Step 4: Evaluation

> Full guide: [`evaluation_code/README.md`](evaluation_code/README.md)

Benchmark action-recognition models trained on 4A-generated data using [MMAction2](https://github.com/open-mmlab/mmaction2).

**Data policy:** Derived H36M / NTU RGB+D / H3WB datasets cannot be redistributed due to licenses. Use `data_preparation.py` to build them from originals. **4A-generated datasets** are available on [Google Drive](https://drive.google.com/drive/folders/1rZm-IZT45KjDLVDC3C_qOn7IPGVokPKH?usp=drive_link).

**Quick start:**

```bash
pip install -r evaluation_code/requirements.txt
python evaluation_code/data_preparation.py ${input_path} ${output_path}
```

Place prepared data under `mmaction2/data/` (named `Kinetics400`). Sample configs are in [`evaluation_code/config/`](evaluation_code/config/); place checkpoints in your MMAction project as described in the [evaluation guide](evaluation_code/README.md). Run evaluation with:

```bash
sh evaluation_code/run_file/test_server.sh   # server
sh evaluation_code/run_file/test_sc.sh         # supercomputer
```

**Original dataset sources:** [Human3.6M](http://vision.imar.ro/human3.6m/description.php) · [NTU RGB+D](https://rose1.ntu.edu.sg/dataset/actionRecognition/) · [H3WB](https://github.com/wholebody3d/wholebody3d)

---

## Repository Layout

```
4A/
├── inferencer/              # HRNet & JointFormer inference scripts
├── project_code/
│   ├── animation_generation/  # Skeleton → animation conversion
│   ├── dataset_generation/    # Automated dataset capture
│   └── fivem_scripts/         # In-game control scripts
├── evaluation_code/         # MMAction2 data prep, configs, and testing
└── resources/               # Figures and assets
```

## Citation

If you use 4A in your research, please cite:

```bibtex
@article{song2024animation,
  title={An Animation-based Augmentation Approach for Action Recognition from Discontinuous Video},
  author={Song, Xingyu and Li, Zhan and Chen, Shi and Cai, Xin-Qiang and Demachi, Kazuyuki},
  journal={arXiv preprint arXiv:2404.06741},
  year={2024}
}
```
