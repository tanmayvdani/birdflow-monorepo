# BirdFlow Monorepo

This repository serves as a centralized hub for the **BirdFlow** project, a suite of tools and models for analyzing and predicting bird migration patterns.

## 📦 Project Structure

This monorepo utilizes **Git Submodules** to manage multiple independent components of the BirdFlow ecosystem. Each submodule tracks its respective upstream repository:

- **[BirdFlowExtras](https://github.com/birdflow-science/BirdFlowExtras)**: Utility functions and extra tools for BirdFlow.
- **[BirdFlowModels](https://github.com/birdflow-science/BirdFlowModels)**: Pre-trained models and data for various bird species.
- **[BirdFlowPipeline](https://github.com/birdflow-science/BirdFlowPipeline)**: The data processing and training pipeline.
- **[BirdFlowPy](https://github.com/birdflow-science/BirdFlowPy)**: Python implementation and interface for BirdFlow.
- **[BirdFlowR](https://github.com/birdflow-science/BirdFlowR)**: The primary R package for working with BirdFlow models.

## 🔄 Automatic Updates

This repository is configured with a **GitHub Action** that runs daily at midnight. This workflow:
1. Checks each submodule for new commits in their respective `main` branches.
2. Automatically updates the submodule references in this monorepo.
3. Commits and pushes the updates back to this repository, ensuring it always points to the latest stable versions.

## 🚀 Getting Started

To clone this repository along with all its submodules, use the `--recursive` flag:

```bash
git clone --recursive https://github.com/tanmayvdani/birdflow-monorepo.git
```

If you have already cloned the repository and need to initialize the submodules:

```bash
git submodule update --init --recursive
```

## 🛠 Maintenance

To manually update all submodules to their latest remote versions:

```bash
git submodule update --remote --merge
```

---
*Maintained by [tanmayvdani](https://github.com/tanmayvdani)*
