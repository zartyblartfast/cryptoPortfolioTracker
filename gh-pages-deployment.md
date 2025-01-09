# GitHub Pages Deployment Guide

This guide outlines the steps to update the gh-pages branch after making changes to the main branch.

## Deployment Steps

1. **Build the Web App**
   ```bash
   flutter build web --release --web-renderer html --base-href "/cryptoPortfolioTracker/"
   ```

2. **Switch to gh-pages Branch**
   ```bash
   git stash  # Save any uncommitted changes
   git checkout gh-pages
   ```

3. **Copy Build Files**
   - Copy all files from `build/web/` to the root directory
   - Ensure you copy all assets, js files, and the index.html

4. **Commit and Push**
   ```bash
   git add .
   git commit -m "Update GitHub Pages deployment"
   git push origin gh-pages
   ```

5. **Return to Main Branch**
   ```bash
   git checkout main
   git stash pop  # If you stashed changes
   ```

The site will be available at: https://zartyblartfast.github.io/cryptoPortfolioTracker/
